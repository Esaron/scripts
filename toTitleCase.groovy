def input = ""

def list = new groovy.json.JsonSlurper().parseText(input)

def toTitleCase = { input1 ->
    String input = input1
    StringBuilder titleCase = new StringBuilder()
    boolean nextTitleCase = true

    for (char c : input.toCharArray()) {
        if (Character.isSpaceChar(c)) {
            nextTitleCase = true
        } else if (nextTitleCase) {
            c = Character.toUpperCase(c)
            nextTitleCase = false
        }
        else {
            c = Character.toLowerCase(c)
        }

        titleCase.append(c)
    }

    return titleCase.toString()
}

list.each { obj ->
    if (obj.userType == "EXTERNAL") {
        println "|" + toTitleCase( obj.firstName.trim() ) + " " + toTitleCase( obj.lastName.trim() ) + "|" + obj.title +"|"+toTitleCase(obj.companyName.trim())+"|"+obj.workPhone+"|"+obj.workEmailAddress+"|"+"commodity|"
    }
}
