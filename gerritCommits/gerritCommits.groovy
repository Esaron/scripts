#!/usr/bin/groovy

import java.net.MalformedURLException
import java.io.File
import java.io.Console
import java.io.PrintWriter
import java.security.KeyStore
import java.text.SimpleDateFormat
import java.awt.*
import java.awt.image.BufferedImage
import javax.swing.WindowConstants as WC
import javax.imageio.ImageIO
import org.apache.http.conn.scheme.Scheme
import org.apache.http.conn.ssl.SSLSocketFactory
import org.jfree.chart.JFreeChart
import org.jfree.chart.ChartFactory
import org.jfree.chart.ChartPanel
import org.jfree.chart.plot.CategoryPlot
import org.jfree.chart.plot.PlotOrientation
import org.jfree.data.category.DefaultCategoryDataset
import org.jfree.chart.axis.CategoryAxis
import org.jfree.chart.axis.CategoryLabelPositions
import groovy.swing.SwingBuilder
import groovy.util.CliBuilder
import groovy.json.JsonSlurper
import groovyx.net.http.RESTClient
import static groovyx.net.http.ContentType.URLENC

String result = ""
Console console = System.console()
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy_MM_dd")

CliBuilder cli = new CliBuilder(usage:'gerritCommits [options] [target]', header:'Options:')
cli.h(longOpt: 'help', 'show usage information and quit')
cli.u(longOpt: 'user', args:1, valueSeparator:'=', argName:'username', 'username to authenticate with gerrit', required: false)
cli.o(longOpt: 'outputFile', args:1, valueSeparator:'=', argName:'output file', 'use this file to log commands and results', required: false)
cli.f(longOpt: 'force', 'force execution (overwriting file specified by -o)', required: false)
// Target is gerrit url

def options = cli.parse(args)
if (!options) {
    System.exit(1)
}
if (options.h) {
    cli.usage()
    return
}

PrintWriter outputFileStream
def printStreams = { content ->
    println content
    if (outputFileStream) {
        outputFileStream.println(content)
        outputFileStream.flush()
    }
}

if (options.o) {
    File output = new File(options.o)
    if (output.exists() && (!options.f || output.isDirectory())) {
        throw new IOException("$options.o already exists and -f is not present or $options.o is a directory")
    }
    else {
        if (output.exists()) {
            output.delete()
        }
        output.createNewFile()
        outputFileStream = new PrintWriter(output)
    }
}

def targets = options.arguments()
String username = options.u
String password
if (!targets) {
    printStreams('Gerrit Server URL:')
    targets = [console.readLine()]
}
if (targets.size() != 1) {
    printStreams('You can only provide 1 target url')
    System.exit(1)
}
if (!options.u) {
    printStreams('Username:')
    username = console.readLine()
}
printStreams('Password:')
password = new String(console.readPassword())

String target = targets[0]
URL targetUrl

try {
    targetUrl = new URL(target)
}
catch (MalformedURLException e) {
    printStreams("Unparseable URL or unknown protocol: $target")
    throw e
}

try {
    printStreams("Target URL: $targetUrl")
    printStreams("Username: $username")
    printStreams("Password: *****")
    if (options.o) {
        printStreams("Output file: $options.o")
        printStreams("  Force output: $options.f")
    }
    RESTClient gerritRest = new RESTClient(targetUrl)
    KeyStore keystore = KeyStore.getInstance(KeyStore.defaultType)
    getClass().getResource("/lib/gerritCommits.jks").withInputStream {
        keystore.load(it, "changeit".toCharArray())
    }
    gerritRest.client.connectionManager.schemeRegistry.register(new Scheme(targetUrl.getProtocol(), new SSLSocketFactory(keystore), targetUrl.getPort()))
    gerritRest.auth.basic(username, password)
    String suffix = 'a/changes/'
    String openParam = 'q=status:open'
    printStreams("Open changes:")
    def open = gerritRest.get(path: suffix, queryString: openParam, contentType: 'text/plain')
    if (open.status != 200) {
        throw new Exception("status of query GET ${targetUrl+suffix}?$openParam: $open.status")
    }
    String openChanges = open.data.text
    printStreams(openChanges)
    result += '{"open":' + openChanges.substring(openChanges.indexOf('[')) + ','
    String mergedParam = 'q=status:merged'
    printStreams("Merged changes:")
    def merged = gerritRest.get(path: suffix, queryString: mergedParam, contentType: 'text/plain')
    if (merged.status != 200) {
        throw new Exception("status of query GET ${targetUrl+suffix}?$mergedParam: $merged.status")
    }
    String mergedChanges = merged.data.text
    printStreams(mergedChanges)
    result += '"merged":' + mergedChanges.substring(mergedChanges.indexOf('[')) + '}'
    JsonSlurper slurper = new JsonSlurper()
    def changeJson = slurper.parseText(result)
    DefaultCategoryDataset bardataset = new DefaultCategoryDataset()
    String openSeries = "Open Changes"
    String mergedSeries = "Merged Changes"
    def nameToCommits = ["open":[:], "merged":[:]]
    for (def change : changeJson.open) {
        def owner = change.owner.name
        if (nameToCommits.open[owner]) {
            nameToCommits.open[owner] += 1
        }
        else {
            nameToCommits.open[owner] = 1
        }
    }
    for (def change : changeJson.merged) {
        def owner = change.owner.name
        if (nameToCommits.merged[owner]) {
            nameToCommits.merged[owner] += 1
        }
        else {
            nameToCommits.merged[owner] = 1
        }
    }
    for (status in nameToCommits) {
        for (owner in status.value) {
            bardataset.addValue(owner.value, status.key, owner.key)
        }
    }
    JFreeChart chart = ChartFactory.createBarChart("Commits by Owner",
                                            "Owner",
                                            "# Commits",
                                            bardataset,
                                            PlotOrientation.VERTICAL,
                                            true,
                                            true,
                                            false)
    chart.backgroundPaint = Color.white
    SwingBuilder swing = new SwingBuilder()
    CategoryPlot plot = chart.getCategoryPlot()
    CategoryAxis domainAxis = plot.getDomainAxis()
    domainAxis.setCategoryLabelPositions(CategoryLabelPositions.createUpRotationLabelPositions(Math.PI/3.0))
    ChartPanel chartPanel = new ChartPanel(chart)
    GraphicsEnvironment graphicsEnv = GraphicsEnvironment.getLocalGraphicsEnvironment()
    GraphicsDevice[] devices = graphicsEnv.getScreenDevices()
    GraphicsDevice monitor
    int width = 0
    int height = 0
    for (GraphicsDevice device : devices) {
        DisplayMode mode = device.getDisplayMode()
        if (mode.getWidth() > width) {
            monitor = device
            width = mode.getWidth()
            height = mode.getHeight()
        }
    }
    chartPanel.setPreferredSize(new Dimension((int)(width*0.9), (int)(height*0.9)))
    def frame = swing.frame(title:'Commit Bar Chart', defaultCloseOperation:WC.EXIT_ON_CLOSE) {
        panel(id:'canvas') {
            widget(chartPanel)
        }
    }
    Component chartComp = frame.contentPane.getComponent(0)
    frame.pack()
    BufferedImage chartImage = new BufferedImage(chartComp.width, chartComp.height, BufferedImage.TYPE_INT_RGB)
    Graphics2D chartGraphics = chartImage.createGraphics()
    chartComp.print(chartGraphics)
    chartGraphics.dispose()
    File chartFile = new File(dateFormat.format(new Date()) + "_commits.png")
    ImageIO.write(chartImage, "png", chartFile)
    frame.show()
}
catch (Exception e) {
    printStreams("Unknown exception encountered: $e")
    throw e
}
finally {
    if (outputFileStream) {
        outputFileStream.close()
    }
}
