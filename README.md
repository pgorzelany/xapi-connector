##Overview

Simple [xAPI 3.0](http://developers.xstore.pro/) wrapper for [Node.js](http://nodejs.org/) written in [Coffeescript](http://coffeescript.org/).

##Prerequisites

Node version 0.10 or higher (testes on Node v0.10.30)

##Instalation

`npm install xapi-connector`

##Example connector usage

![](src/connector-example.litcoffee)

##Connector Docs (Draft)

Notice: This is a DRAFT of how the API should look like, not the actual docs. The API will probably look like this for version 1.0.

###Class: Connector(server_url, conn_port, stream_port, username, password, [options])

The main Connector class. By using it you initialize the client. Example:

    client = new Connector(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

You can then use the Connector methods and properties to interact with xapi

###Connector.connect()

Connects to the specified server and conn port

###Connector.disconnect()

Disconnects from the server

###Connector.send(msg)

Sends a message through the normal connection

###Connector.on(event, callback)

Registeres a callback for a given event. You can register multiple callback per event

Events:
- open
- close
- error
- message

###Connector.connectStream()

Connects to the specified stream server

###Connector.disconnectStream()

Disconnects from the stream server

###Connector.sendStream(msg)

Sends a message to the stream server

###Connector.onStream(event, callback)

Registeres a callback for a given stream event. You can register multiple callback per event

Events:
- open
- close
- error
- message

###Connector.buildCommand(command, [args], [tag])

Helper function for building xAPI compliant commands. Returns a JSON object.

###Connector.buildStreamCommand(command, stream_session_id, [symbols])

Helper function for building xAPI compliant commands. Returns a JSON object.

###Connector.getQue()

Return the current que of messages to be send by the Connector

###Connector.getStreamQue()

Return the current que of messages to be send by the Connector stream

###Connector.server_url

###Connector.conn_port

###Connector.stream.port

###Connector.username

###Connector.password
