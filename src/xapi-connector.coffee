#Copyright (c) Piotr Gorzelany 2014

tls = require('tls')
dispatcher = require('./dispatcher.js')

print = (msg) ->
  console.log(msg + '\n')
  return

class Connector
  constructor: (@server_url, @conn_port, @stream_port, @username, @password) ->
    @msg = '' #this is required since data comes in chunks
    @stream_msg = '' #this is for the stream
    @env = {}

  buildCommand: (command,args, tag) ->
    com =
      command: if command? then command else throw new Error('Missing command')
    com.arguments = args if args?
    com.customTag = tag if tag?
    return JSON.stringify(com)

  buildStreamCommand: (command, stream_session_id, symbols) ->
    com =
      command: if command? then command else throw new Error('Missing command')
    com.streamSessionId = stream_session_id if stream_session_id?
    com.symbols = symbols if symbols?
    return JSON.stringify(com)

  connect: () ->
    #establish tls connection and handlers
    @conn = tls.connect(@conn_port, @server_url, @onOpen)
    @conn.setEncoding('utf-8')
    @conn.dispatcher = new dispatcher(@conn, 205)
    @conn.send = (msg) =>
      @conn.dispatcher.add(msg)
    @conn.addListener('data', @onChunk)
    @conn.addListener('error', @onError)
    @conn.addListener('close', @onClose)
    return

  onChunk: (data) =>
    #since it is possible to receive multiple responses in one chunk, we have to split it
    #if the response is a partial msg we just add it to the @msg
    responses = data.split('\n\n')
    if responses.length == 1
      @msg += responses[0]
    else
      #if the responses contains multiple messages we send them to handler one by one
      responses = (res for res in data.split('\n\n') when res != '')
      for res in responses
        @msg += res
        @onMessage(@msg)
        @msg = ''
    return

  connectStream: () ->
    @stream = tls.connect(@stream_port, @server_url, @onStreamOpen)
    @stream.setEncoding('utf-8')
    @stream.dispatcher = new dispatcher(@stream, 205)
    @stream.send = (msg) =>
      @stream.dispatcher.add(msg)
    @stream.addListener('data', @onStreamChunk)
    @stream.addListener('error', @onStreamError)
    @stream.addListener('close', @onStreamClose)
    return

  onStreamChunk: (data) =>
    #since it is possible to receive multiple responses in one chunk, we have to split it
    responses = data.split('\n\n')
    #partial response, just add the chunk
    if responses.length == 1
      @stream_msg += responses[0]
    #multiple responses, handle one by one
    else
      responses = (res for res in responses when res != '')
      for res in responses
        @stream_msg += res
        @onStreamMessage(@stream_msg)
        @stream_msg = ''
    return

    #fill in onOpen, onMessage, onStreamOpen, onStreamMessage, onError and onStreamError handlers

module.exports = Connector
