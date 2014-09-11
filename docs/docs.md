###Class: Connector(server_url, conn_port, stream_port, username, password, [options])

The main Connector class. By using it you initialize the client. Example:

    connector = new Connector(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

You can then use the Connector methods and properties to interact with xapi

###Connector.connect()

Connects to the specified server and conn port

###Connector.disconnect()

Disconnects from the server

###Connector.send(msg)

Sends a message through the normal connection

###Connector.on(event, callback)

Registeres a callback for a given event. You can register multiple callbacks per event

Events:
- open: this event is triggered when connection is successfuly established
- close: triggered when the connection is closed
- error: triggered when there is an error in the connection
- message: triggered when the connector received a message from the server. the callback should take one argument (msg) which is a JSON object

      connector.on('message', (msg) ->
        console.log("Received a message: #{msg}")
      )

###Connector.connectStream()

Connects to the specified stream server

###Connector.disconnectStream()

Disconnects from the stream server

###Connector.sendStream(msg)

Sends a message to the stream server

###Connector.onStream(event, callback)

Registeres a callback for a given stream event. You can register multiple callback per event

Events:

- open: emitted on stream open
- close: emitted on stream close
- error: emitted on stream error
- message: emitted on stream message

###Connector.buildCommand(command, [args], [tag])

Helper function for building xAPI compliant commands. Returns a JSON object.

###Connector.buildStreamCommand(command, stream_session_id, [symbols])

Helper function for building xAPI compliant commands. Returns a JSON object.

###Connector.getQue()

Return the current que (array) of messages to be send by the Connector

###Connector.getStreamQue()

Return the current que (array) of messages to be send by the Connector stream

###Connector.server_url

Returns the instance server url

###Connector.conn_port

Returns the insance port for the normal socket connection

###Connector.stream.port

Returns the instance port for the stream connection

###Connector.username

Returns the instance username. Username is used to login to xapi

###Connector.password

Returns the instance password. Password is used to login to xapi
