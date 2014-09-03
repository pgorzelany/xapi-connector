##Overview

Simple [xAPI 3.0](http://developers.xstore.pro/) wrapper for [Node.js](http://nodejs.org/) written in [Coffeescript](http://coffeescript.org/).

##Prerequisites

Node version 0.10 or higher (testes on Node v0.10.30)

##Instalation

`npm install xapi-connector`

##Example wrapper usage

[See wrapper example](src/wrapper-example.litcoffee)

##Example connector usage

[See connector example](src/connector-example.litcoffee)

##Wrapper Docs (Draft)

###Class: Wrapper(server_url, conn_port, stream_port, username, password, [options])

The main wrapper class. By using it you initialize the client. Example:

    client = new Wrapper(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

You can then use the client methods and properties to interact with xapi

###Client.connect()

###Client.disconnect()

#Client.send(command, [args])

#Client.on(event, callback(req, res))

#Client.connectStream()

#Client.disconnectStream()

#Client.subscribe(command, [args])

#Client.unsubscribe(command, [args])

#Client.onStream(even, callback(msg))

#Client.conn_status

#Client.stream_status

#Client.que

#Client.session_id
