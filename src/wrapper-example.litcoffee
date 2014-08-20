##Example wrapper usage

The socket provided by xAPI is not certified but for now lets ignore it

    process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

Import the wrapper.

    Wrapper = require('../lib/xapi-wrapper.js')

Define statics

    SERVER_URL = 'xapia.x-station.eu'
    CONN_PORT = '5144' #provide port
    STREAM_PORT = '5145' #provide stream port
    USERNAME = '177509' #provide a valid username
    PASSWORD = 'ystk7C' #provide a valid password

Helper functions

    print = (msg) ->
      console.log(msg)
      return

Create a client.

    client = new Wrapper(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

Add event handlers for the normal connection.

    client.on('open', () ->
      print("Successfuly connected, loging in.")
      client.login({userId: client.username, password: client.password})
      )

    client.on('login', (msg) ->
      print("successfully logged in.")
      client.env.stream_session_id = msg.streamSessionId
      client.connectStream()
      )

    client.on('logout', (msg) ->
      print("Successfuly loged out")
      client.disconnect()
      )

Add event handlers for stream.

    client.onStream('open', () ->
      print("Successfuly connected to stream. Subscribing to EURUSD.")
      client.subscribeTickPrices(client.env.stream_session_id, ['EURUSD'])
      )


    client.onStream('tickPrices', (msg) ->
      #print("Received tick prices: #{JSON.stringify(msg.data, null, 4)}")
      )

Connect the client.

    client.connect()
    setTimeout(()->
        client.logout()
      ,100000)
