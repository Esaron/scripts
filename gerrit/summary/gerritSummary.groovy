#!/usr/bin/groovy

import java.net.MalformedURLException
import java.io.File
import java.io.Console
import java.io.PrintWriter
import java.security.KeyStore
import java.text.SimpleDateFormat
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.SSLSession
import org.apache.http.conn.scheme.Scheme
import org.apache.http.conn.ssl.SSLSocketFactory
import org.apache.http.conn.ssl.TrustSelfSignedStrategy
import org.apache.http.conn.ssl.AllowAllHostnameVerifier
import groovy.util.CliBuilder
import groovy.json.JsonSlurper
import groovyx.net.http.RESTClient
import groovyx.net.http.HttpResponseException
import static groovyx.net.http.ContentType.URLENC

String result = ""
Console console = System.console()
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy_MM_dd")

CliBuilder cli = new CliBuilder(usage:'gerritCommits [options] [target]', header:'Options:')
cli.h(longOpt: 'help', 'show usage information and quit')
cli.u(longOpt: 'user', args:1, valueSeparator:'=', argName:'username', 'username to authenticate with gerrit', required: false)
cli.p(longOpt: 'project', args:1, valueSeparator:'=', argName:'project', 'project to query for changes', required: false)
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
FileOutputStream outFileStream

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
    println('Gerrit Server URL:')
    targets = [console.readLine()]
}
if (targets.size() != 1) {
    println('You can only provide 1 target url')
    System.exit(1)
}
if (!options.u) {
    println('Username:')
    username = console.readLine()
}
println('Password:')
password = new String(console.readPassword())

String target = targets[0]
URL targetUrl

try {
    targetUrl = new URL(target)
}
catch (MalformedURLException e) {
    println("Unparseable URL or unknown protocol: $target")
    throw e
}

try {
    println("Target URL: $targetUrl")
    println("Username: $username")
    println("Password: *****")
    if (options.o) {
        println("Output file: $options.o")
        println("  Force output: $options.f")
    }
    RESTClient gerritRest = new RESTClient(targetUrl)
    //KeyStore keystore = KeyStore.getInstance(KeyStore.defaultType)
    //getClass().getResource("/lib/gerritSummary.jks").withInputStream {
    //    keystore.load(it, "changeit".toCharArray())
    //}
    gerritRest.client.connectionManager.schemeRegistry.register(new Scheme(targetUrl.getProtocol(), new SSLSocketFactory(new TrustSelfSignedStrategy(), new AllowAllHostnameVerifier()), targetUrl.getPort()))
    gerritRest.auth.basic(username, password)
    String changes = '/a/changes/'
    String projectQuery = options.p ? "project:$options.p+" : ''
    String openParam = "q=${projectQuery}status:open"
    println("Retrieving open changes...")
    def open = gerritRest.get(path: changes, queryString: openParam, contentType: 'text/plain')
    String openChanges = open.data.text
    result += '{"open":' + openChanges.substring(openChanges.indexOf('[')) + ','
    String mergedParam = "q=${projectQuery}status:merged"
    println("Retrieving merged changes...")
    def merged = gerritRest.get(path: changes, queryString: mergedParam, contentType: 'text/plain')
    String mergedChanges = merged.data.text
    result += '"merged":' + mergedChanges.substring(mergedChanges.indexOf('[')) + '}'
    JsonSlurper slurper = new JsonSlurper()
    def changeJson = slurper.parseText(result)
    String comments
    String reviewComments
    def review
    def jsonResult = []
    changeJson.each { status ->
        for (int i = 0; i < status.value.size(); i++) {
            comments = changes + "${changeJson[status.key][i].change_id}/detail/"
            try {
                review = gerritRest.get(path: comments, contentType: 'text/plain')
                reviewComments = review.data.text.substring(4)
                jsonResult.push(reviewComments)
                changeJson[status.key][i].comments = reviewComments
            }
            catch (HttpResponseException e) {
                println("Bad response for change ${changeJson[status.key][i].change_id}. Continuing...")
            }
        }
    }
    File outFile = new File(dateFormat.format(new Date()) + "_changes.json")
    outFileStream = new FileOutputStream(outFile)
    outFileStream.write(jsonResult.toString().getBytes())
    printStreams(jsonResult.toString())
}
catch (Exception e) {
    println("Unknown exception encountered: $e")
    throw e
}
finally {
    if (outputFileStream) {
        outputFileStream.close()
    }
    if (outFileStream) {
        outFileStream.close()
    }
}
