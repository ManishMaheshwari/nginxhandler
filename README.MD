#Demo on multiple ways to dynamically route, using NginX

This project demonstrates use of:

* Routing using header values in NginX
* Routing using Rewrite Handler written in Java
* Response building using in-line Clojure script, using a handler type of Clojure 
* Response building using in-line Groovy script, using a handler type of Groovy
* Response building using Java class

*Note:*

* Nginx daemon is turned off. This is for the ease of testing, and viewing the console as the tests are run.
* To build Java Handlers, run `gradle assemble copyJarToBin`
* Starting nginx: `./nginx-clojure-0.4.4/nginx-macosx`


More documenttaion at: <https://nginx-clojure.github.io/quickstart.html>

###Testing
#####Running TCP servers as backends, to receive requests
nc -k -l 9000
nc -k -l 10000
nc -k -l 11000

#####Various curl commands to validate the routing
curl -i http://localhost:8080
curl -i http://localhost:8080/groovy
curl -i http://localhost:8080/clojure
curl -i http://localhost:8080/java

curl -i http://localhost:8080/router
curl -i -H 'X-Server-Choose: default' http://localhost:8080/router
curl -i -H 'X-Server-Choose: 1' http://localhost:8080/router
curl -i -H 'X-Server-Choose: 2' http://localhost:8080/router
curl -i -H 'X-Server-Choose: 3' http://localhost:8080/router
curl -i -H 'X-Server-Choose: 4' http://localhost:8080/router

curl -i http://localhost:8080/boss
curl -i -H 'X-Server-Select: default' http://localhost:8080/boss
curl -i -H 'X-Server-Select: staging' http://localhost:8080/boss
curl -i -H 'X-Server-Select: dev' http://localhost:8080/boss
