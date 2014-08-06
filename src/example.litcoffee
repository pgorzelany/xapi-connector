##Example usage

This is a simple example showing how to connect and use the api wrapper.

Import the xapi-connector and debug-js for easier debuging

    Connector = require('./xapi-connector.js')
    Debugger = require('debug-js')

The socket provided by xAPI is not certified but for now lets ignore it

    process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

Define some helpfull static variables

    SERVER_URL = 'xapia.x-station.eu'
    CONN_PORT = '5144' #provide port
    STREAM_PORT = '5145' #provide stream port
    USERNAME = '177509' #provide a valid username
    PASSWORD = 'ystk7C' #provide a valid password

Create debuggers

    s = new Debugger('Stream', 'blue') #debugger for stream
    c = new Debugger('Conn', 'yellow') #debugger for normal connection

Create new API connector

    api = new Connector(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

Define neccesary methods.
For the sake of this example, we will login to the provided account once the connection is open.
We will then define what to do when we receive a message.

    api.onOpen = (msg) ->
      c.debug('Successfuly connected to market server, login in.')
      api.conn.send(api.buildCommand('login', {userId: api.username, password: api.password}, 'login'))
      return

    ###lets just forward the message to an appropriate handler defined later
    we will use the customTag to know which handler we should forward to###

    api.onMessage = (msg) ->
      c.debug("Received a  message, #{msg}")
      msg = JSON.parse(msg)
      c.debug("Received response to command: #{msg.customTag}")
      if api.handlers[msg.customTag]?
        api.handlers[msg.customTag](msg)
      else
        throw new Error('There is no handler for this msg')
      return

    api.onError = (err) ->
      c.debug(err)
      return

    api.onClose = () ->
      c.debug('Successfuly closed the connection')
      return

Since the connector is asynchronous, we have to make sure that we are sending commands in the right order.
Lets create the handlers object and its methods to which we are forwarding messages.
We will wait for confirmation on successful login and then send a command to check the API version and if its 3.0 we will open the stream.

    api.handlers =
      #handler for the login response
      login: (msg) =>
        c.debug('Entering login handler')
        if msg.status == true
          #save the stream_session_id in the environment object
          api.env.stream_session_id = msg.streamSessionId
          c.debug('The login was succesfull. Lets check if the API version is 3.0')
          api.conn.send(api.buildCommand('getVersion', null, 'getVersion'))
        else
          c.debug('There was an error login in')
        return

      #handler for the getVersion response
      getVersion: (msg) =>
        c.debug('Entering getVersion handler')
        if msg.returnData.version == '3.0'
          c.debug('The API version is OK. Now lets connect to the stream')
          api.connectStream()
        else
          c.debug('The version of the API has changed. This wrapper is outdated')
        return

      #handler for logout rensponse
      logout: (msg) =>
        c.debug('Entering logout handler, closing sockets')
        if msg.status == true
          api.conn.end()
        return

We have now defined handlers to retrieve some trading data.
Notice that we send the getAllSymbols command only after we made sure that our login was succesfull.

Lets now define the neccesary stream methods. For the sake of this example we will subscribe to indicator and EURUSD tick prices once the stream is open.

    api.onStreamOpen = (msg) ->
      s.debug('Successfuly connected to stream server, subscribing to indicators.')
      api.stream.send(api.buildStreamCommand("getAccountIndicators", api.env.stream_session_id))
      s.debug('Lets also subscribe to EURUSD tick prices')
      api.stream.send(api.buildStreamCommand("getTickPrices", api.env.stream_session_id, ['EURUSD']))
      return

    ###lets just forward the message to an appropriate stream handler defined later
    we will use the customTag to know which handler we should forward to###

    api.onStreamMessage = (msg) ->
      msg = JSON.parse(msg)
      s.debug("Received response to command: #{msg.command}")
      if api.stream_handlers[msg.command]?
        api.stream_handlers[msg.command](msg)
      else
        throw new Error('There is no handler for this msg')
      return

    api.onStreamError = (err) ->
      s.debug(err)
      return

    api.onStreamClose = () ->
      s.debug('Successfuly closed the stream')
      return

Lets create the stream_handler object and its methods to which we are forwarding our stream messages.
We can now define how do we want to handle the responses from each command. For now lets just print them.

    api.stream_handlers =
      indicators: (msg) =>
        s.debug(JSON.stringify(msg))
        return

      tickPrices: (msg) =>
        s.debug(JSON.stringify(msg))
        return

And there you go. We have connected and issued some commands and handled the responses. Lets connect and run the code!
We will logout and close the connections after 10 sec

    api.connect()
    setTimeout(() ->
      api.conn.send(api.buildCommand('logout', null, 'logout'))
    ,10000)

You don't have to follow the approach presented in this example and you can play with the Connector to search for your own stile.

Have fun!
