##Overview

Simple [xAPI 3.0](http://developers.xstore.pro/) wrapper for [Node.js](http://nodejs.org/) written in [Coffeescript](http://coffeescript.org/).

##Prerequisites

Node version 0.10 or higher (testes on Node v0.10.30)

##Instalation

`npm install`

##Example usage

This is a simple example showing how to connect and use the api wrapper.

Import the xapi-connector

    Connector = require('./xapi-connector.js')

The socket provided by xAPI is not certified but for now lets ignore it

    process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

Define some helpful static variables

    SERVER_URL = 'xapia.x-station.eu'
    CONN_PORT = '5144' #provide port
    STREAM_PORT = '5145' #provide stream port
    USERNAME = '177509' #provide a valid username
    PASSWORD = 'ystk7C' #provide a valid password

Define some helpful helper functions

    print = (msg) ->
      console.log(msg + '\n')
      return

Create new API connector and connect.

    api = new Connector(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

Define neccesary methods.
For the sake of this example, we will login to the provided account once the connection is open.
We will then define what to do when we receive a message.

    api.onOpen = (msg) ->
      print('Successfuly connected to market server, login in.')
      api.conn.send(api.buildCommand('login', {userId: api.username, password: api.password}, 'login'))
      return

    ###lets just forward the message to an appropriate handler defined later
    we will use the customTag to know which handler we should forward to###

    api.onMessage = (msg) ->
      print("Received a stream message, #{msg}")
      msg = JSON.parse(msg)
      print("Received response to command: #{msg.customTag}")
      if api.handlers[msg.customTag]?
        api.handlers[msg.customTag](msg)
      else
        throw new Error('There is no handler for this msg')
      return

    api.onError = (err) ->
      print(err)
      return

    api.onClose = () ->
      print('Successfuly closed the connection')
      return

Since the connector is asynchronous, we have to make sure that we are sending commands in the right order.
Lets create the handlers object and its methods to which we are forwarding messages.
We will wait for confirmation on successful login and then send a command to get information on all symbols and then we will open the stream.

    api.handlers =
      #handler for the login response
      login: (msg) =>
        print('Entering login handler')
        if msg.status == true
          #save the stream_session_id in the environment object
          api.env.stream_session_id = msg.streamSessionId
          print('The login was succesfull. Lets get the information on the available symbols')
          api.conn.send(api.buildCommand('getAllSymbols', null, 'getAllSymbols'))
        else
          print('There was an error login in')
        return

      #handler for the getAllSymbols response
      getAllSymbols: (msg) =>
        print('Entering getAllSymbols handler')
        print('We successfully received data on the available symbols. Now lets connect to the stream')
        api.connectStream()
        return

      #handler for logout rensponse
      logout: (msg) =>
        print('Entering logout handler, closing sockets')
        if msg.status == true
          api.conn.end()
        return

We have now defined handlers to retrieve some trading data.
Notice that we send the getAllSymbols command only after we made sure that our login was succesfull.

Lets now define the neccesary stream methods. For the sake of this example we will subscribe to indicator and EURUSD tick prices once the stream is open.

    api.onStreamOpen = (msg) ->
      print('Successfuly connected to stream server, subscribing to indicators.')
      api.stream.send(api.buildStreamCommand("getAccountIndicators", api.env.stream_session_id))
      print('Lets also subscribe to EURUSD tick prices')
      api.stream.send(api.buildStreamCommand("getTickPrices", api.env.stream_session_id, ['EURUSD']))
      return

    ###lets just forward the message to an appropriate stream handler defined later
    we will use the customTag to know which handler we should forward to###

    api.onStreamMessage = (msg) ->
      msg = JSON.parse(msg)
      print("Received response to command: #{msg.command}")
      if api.stream_handlers[msg.command]?
        api.stream_handlers[msg.command](msg)
      else
        throw new Error('There is no handler for this msg')
      return

    api.onStreamError = (err) ->
      print(err)
      return

    api.onStreamClose = () ->
      print('Successfuly closed the stream')
      return

Lets create the stream_handler object and its methods to which we are forwarding our stream messages.
We can now define how do we want to handle the responses from each command. For now lets just print them.

    api.stream_handlers =
      indicators: (msg) =>
        print(JSON.stringify(msg))
        return

      tickPrices: (msg) =>
        print(JSON.stringify(msg))
        return

And there you go. We have connected and issued some commands and handled the responses. Lets connect and run the code!
We will logout and close the connections after 20 sec

    api.connect()
    setTimeout(() ->
      api.conn.send(api.buildCommand('logout', null, 'logout'))
    ,20000)

This example is provided with this module, just run:

`node ./lib/example.js`

You don't have to follow the approach presented in this example and you can play with the xapi-connector to search for your own style.

Have fun!
