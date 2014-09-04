#Copyright (c) Piotr Gorzelany 2014

tls = require('tls')
dispatcher = require('./dispatcher.js')
Emitter = require('events').EventEmitter

print = (msg) ->
  console.log(msg + '\n')
  return


class Connector
  constructor: (@server_url, @conn_port, @stream_port, @username, @password) ->
    @_msg = '' #this is required since data comes in chunks
    @_stream_msg = '' #this is for the stream
    @_conn = {}
    @_stream = {}
    @_emitter = new Emitter()
    @_streamEmitter = new Emitter()

  buildCommand: (command, args, tag) ->
    com =
      command: if command? then command else throw new Error('Missing command')
      arguments: args if args?
    #myCustomTag = JSON.stringify(com)
    if tag? then com.customTag = tag
    #if tag? then com.customTag = tag else com.customTag = myCustomTag
    return JSON.stringify(com)

  buildStreamCommand: (command, stream_session_id, symbols) ->
    com =
      command: if command? then command else throw new Error('Missing command')
    com.streamSessionId = stream_session_id if stream_session_id?
    com.symbols = symbols if symbols?
    return JSON.stringify(com)

  connect: () ->
    #establish tls connection and handlers
    @_conn.socket = tls.connect(@conn_port, @server_url, () =>
      @_emitter.emit('open'))
    @_conn.socket.setEncoding('utf-8')
    @_conn.dispatcher = new dispatcher(@_conn.socket, 200)
    @send = (msg) =>
      #console.log("Sending message: #{msg}")
      @_conn.dispatcher.add(msg)
    @_conn.socket.addListener('data', @_onChunk)
    @_conn.socket.addListener('error', () =>
      @_emitter.emit('error'))
    @_conn.socket.addListener('close', () =>
      @_emitter.emit('close'))
    return

  _onChunk: (data) =>
    #since it is possible to receive multiple responses in one chunk, we have to split it
    #if the response is a partial msg we just add it to the @_msg
    responses = data.split('\n\n')
    if responses.length == 1
      @_msg += responses[0]
    else
      #if the responses contains multiple messages we send them to handler one by one
      responses = (res for res in data.split('\n\n') when res != '')
      for res in responses
        @_msg += res
        @_emitter.emit('message', @_msg)
        @_msg = ''
    return

  disconnect: () ->
    @_conn.socket.end() if @_conn.socket?
    return

  connectStream: () ->
    @_stream.socket = tls.connect(@stream_port, @server_url, () =>
      @_streamEmitter.emit('open'))
    @_stream.socket.setEncoding('utf-8')
    @_stream.dispatcher = new dispatcher(@_stream.socket, 200)
    @sendStream = (msg) =>
      #console.log("Sending message: #{msg}")
      @_stream.dispatcher.add(msg)
    @_stream.socket.addListener('data', @_onStreamChunk)
    @_stream.socket.addListener('error', () =>
      @_streamEmitter.emit('error'))
    @_stream.socket.addListener('close', () =>
      @_streamEmitter.emit('close'))
    return

  _onStreamChunk: (data) =>
    #since it is possible to receive multiple responses in one chunk, we have to split it
    responses = data.split('\n\n')
    #partial response, just add the chunk
    if responses.length == 1
      @_stream_msg += responses[0]
    #multiple responses, handle one by one
    else
      responses = (res for res in responses when res != '')
      for res in responses
        @_stream_msg += res
        @_streamEmitter.emit('message', @_stream_msg)
        @_stream_msg = ''
    return

  disconnectStream: () ->
    @_stream.socket.end() if @_stream.socket?
    return

  on: (event, callback) ->
    @_emitter.on(event, callback)
    return

  onStream: (event, callback) ->
    @_streamEmitter.on(event, callback)
    return

    #fill in onOpen, onMessage, onStreamOpen, onStreamMessage, onError and onStreamError handlers

module.exports = Connector
