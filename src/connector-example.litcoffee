##Example usage

This is a simple example showing how to connect and use the api connector.

Import the xapi-connector

    #Connector = require('xapi-connector')
    Connector = require('../lib/xapi-connector.js')

The socket provided by xAPI is not certified but for now lets ignore it

    process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

Define some helpfull static variables

    SERVER_URL = 'xapia.x-station.eu'
    CONN_PORT = '5144' #provide port
    STREAM_PORT = '5145' #provide stream port
    USERNAME = '201870' #provide a valid username
    PASSWORD = 'rz3smI' #provide a valid password

Helper functions

    print = (msg) ->
      console.log(msg)

Create new API connector

    client = new Connector(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

You now have to register callbacks for the events that will be emitted by the Connector. First lets register a callback
that will handle the 'open' event emitted when connection with the server is established.
Once connected we will send a login command.

    client.on('open', () ->
      print('Successfuly connected, login in')
      msg = client.buildCommand('login', {userId: client.username, password: client.password}, 'login')
      client.send(msg)
    )

Now we have to register a callback that will handle the 'message' event, triggered once the Connector receives a message
from the server. We can use the customTag to identify the login command. Once loged in, we will connect to the stream.

    client.on('message', (msg) ->
      print("Received a message: #{msg}")
      msg = JSON.parse(msg)
      if msg.customTag == 'login'
        if msg.status == true
          print('Successfuly loged in, connecting to stream')
          client.stream_session_id = msg.streamSessionId
          client.connectStream()
        else
          print('Login failed')
      else if msg.customTag == 'logout'
        client.disconnectStream()
        client.disconnect()
    )

Additionaly we can register callbacks to handle the 'error' and 'close events.'

    client.on('error', (err) ->
      print("Connection error: #{err}")
    )

    client.on('close', () ->
      print('Connection closed')
    )

Now lets handle the stream. First register a handler for the 'open' event.

    client.onStream('open', () ->
      print('Successfuly connected to stream, subscribing to indicators')
      msg = client.buildStreamCommand('getAccountIndicators', client.stream_session_id)
      client.sendStream(msg)
    )

Now lets handle the incoming messages.

    client.onStream('message', (msg) ->
      print("Received a message from the stream: #{msg}")
    )

Additionaly we can register callbacks to handle the 'error' and 'close events.'

    client.onStream('error', (err) ->
      print("Stream error: #{err}")
    )

    client.onStream('close', () ->
      print('Stream closed')
    )

Connect the client and check the results! After successful login the client will log out of the service after 10s.

    client.connect()
    setTimeout(() ->
      print('login out')
      msg = client.buildCommand('logout', null, 'logout')
      client.send(msg)
    ,10000)
