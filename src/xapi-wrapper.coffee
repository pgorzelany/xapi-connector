Connector = require('./xapi-connector.js')

class Wrapper extends Connector
  constructor: (server_url, conn_port, stream_port, username, password) ->
    super(server_url, conn_port, stream_port, username, password)
    @handlers = {}
    @stream_handlers = {}
    @env =
      indicators: {}
      symbols: {}
      quotes: {}
      orders: {}
      trades: {}
      messages: {}
    return

  onOpen: () =>
    @env.conn_status = true
    @env.last_conn = new Date().getTime()
    @handlers.open() if @handlers.open?
    return

  onMessage: (msg) ->
    msg = JSON.parse(msg)
    if @handlers[@env.messages[msg.customTag].command]?
      if msg.status == true
        @handlers[@env.messages[msg.customTag].command](msg)
      else
        @onApiError(msg)
    else
      throw new Error("There is no handler for the message")
    return

  onError: (err) =>
    #console.log(JSON.stringify(@env,null, 4))
    @env.conn_status = false
    console.log(err)
    @reconnect()
    return

  reconnect: () ->
    now = new Date().getTime()
    if @env.conn_status == false and (now - @env.last_conn >= 2000 or @env.last_conn == undefined)
      console.log('Connection lost, reconnecting...')
      @resetState()
      @connect()
      @env.last_conn = new Date().getTime()
    else
      setTimeout(@reconnect.bind(this), 2000 - (now - @env.last_conn))
    return

  onClose: () =>
    @env.conn_status = false
    console.log('Connection closed')
    return

  onStreamMessage: (msg) ->
    msg = JSON.parse(msg)
    if @stream_handlers[msg.command]?
      @stream_handlers[msg.command](msg)
    else
      throw new Error('There is no handler for this msg')
    return

  onStreamOpen: () =>
    @env.stream_status = true
    @stream_handlers.open() if @stream_handlers.open?
    return

  onStreamError: (err) =>
    @env.stream_status = false
    console.log(err)
    return

  onStreamClose: () =>
    @env.stream_status = false
    console.log('Stream closed')
    return

  onApiError: (msg) ->
    if msg.redirect?
      @disconnect()
      @resetState()
      @server_url = msg.redirect.address
      @conn_port = msg.redirect.mainPort
      @stream_port = msg.redirect.streamingPort
      @connect()
    else
      console.log("The response for command #{@env.messages[msg.customTag].command} has status false: #{JSON.stringify(msg,null, 4)}")
      return

  resetState: () ->
    super()
    @env =
      indicators: {}
      symbols: {}
      quotes: {}
      orders: {}
      trades: {}
      messages: {}
    return

  on: (event, callback) ->
    @handlers[event] = callback

  onStream: (event, callback) ->
    @stream_handlers[event] = callback

  login: (args) ->
    @conn.send(@buildCommand('login', args))
    return

  logout: () ->
    @conn.send(@buildCommand('logout'))
    return

  addOrder: (args) ->
    @conn.send(@buildCommand('addOrder', args))
    return

  closePosition: (args) ->
    @conn.send(@buildCommand('closePosition', args))
    return

  closePositions: (args) ->
    @conn.send(@buildCommand('closePositions', args))
    return

  deletePending: (args) ->
    @conn.send(@buildCommand('deletePending', args))
    return

  getAccountIndicators: () ->
    @conn.send(@buildCommand('getAccountIndicators'))
    return

  getAccountInfo: (args) ->
    @conn.send(@buildCommand('getAccountInfo', args))
    return

  getAllSymbols: (args) ->
    @conn.send(@buildCommand('getAllSymbols', args))
    return

  getCalendar: (args) ->
    @conn.send(@buildCommand('getCalendar', args))
    return

  getCashOperationsHistory: (args) ->
    @conn.send(@buildCommand('getCashOperationsHistory', args))
    return

  getCommisionsDef: (args) ->
    @conn.send(@buildCommand('getCommisionsDef', args))
    return

  getlbsHistory: (args) ->
    @conn.send(@buildCommand('getlbsHistory', args))
    return

  getMarginTrade: (args) ->
    @conn.send(@buildCommand('getMarginTrade', args))
    return

  getNews: (args) ->
    @conn.send(@buildCommand('getNews', args))
    return

  getOrderStatus: (args) ->
    @conn.send(@buildCommand('getOrderStatus', args))
    return

  getProfitCalculations: (args) ->
    @conn.send(@buildCommand('getProfitCalculations', args))
    return

  getServerTime: (args) ->
    @conn.send(@buildCommand('getServerTime', args))
    return

  getStepRules: (args) ->
    @conn.send(@buildCommand('getStepRules', args))
    return

  getSymbol: (args) ->
    @conn.send(@buildCommand('getSymbol', args))
    return

  getTickPrices: (args) ->
    @conn.send(@buildCommand('getTickPrices', args))
    return

  getTradeRecords: (args) ->
    @conn.send(@buildCommand('getTradeRecords', args))
    return

  getTrades: (args) ->
    @conn.send(@buildCommand('getTrades', args))
    return

  getTradesHistory: (args) ->
    @conn.send(@buildCommand('getTradesHistory', args))
    return

  getTradingHours: (args) ->
    @conn.send(@buildCommand('getTradingHours', args))
    return

  getVersion: (args) ->
    @conn.send(@buildCommand('getVersion', args))
    return

  modifyPending: (args) ->
    @conn.send(@buildCommand('modifyPending', args))
    return

  modifyPosition: (args) ->
    @conn.send(@buildCommand('modifyPosition', args))
    return

  ping: (args) ->
    @conn.send(@buildCommand('ping', args))
    return

  subscribeAccountIndicators: (stream_session_id) ->
    @stream.send(@buildStreamCommand('getAccountIndicators', stream_session_id))

  subscribeCandles: (stream_session_id) ->
    @stream.send(@buildStreamCommand('getCandles', stream_session_id))

  subscribeKeepAlive: (stream_session_id) ->
    @stream.send(@buildStreamCommand('getKeepAlive', stream_session_id))

  subscribeNews: (stream_session_id) ->
    @stream.send(@buildStreamCommand('getNews', stream_session_id))

  subscribeOrderStatus: (stream_session_id) ->
    @stream.send(@buildStreamCommand('getOrderStatus', stream_session_id))

  subscribeProfits: (stream_session_id) ->
    @stream.send(@buildStreamCommand('getProfits', stream_session_id))

  subscribeTickPrices: (stream_session_id, symbols) ->
    @stream.send(@buildStreamCommand('getTickPrices', stream_session_id, symbols))

  subscribeTrades: (stream_session_id) ->
    @stream.send(@buildStreamCommand('getTrades', stream_session_id))


module.exports = Wrapper
