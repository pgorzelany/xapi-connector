##Example usage

This is a simple example showing how to connect and use the api wrapper.

Import the xapi-connector

    Connector = require('./xapi-connector.js')

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

    api = new Connector(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)


    api.connect()
    setTimeout(() ->
      api.conn.send(api.buildCommand('logout', null))
    ,10000)
