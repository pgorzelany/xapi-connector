###
The Dispatcher class.
It takes asynchronous requests to send something through the stream
and sends it asynchronously in intervals.
###


class Dispatcher
  constructor: (@stream, @delay = 0, @max_sins = 0) ->
    @_que = []
    @_last = 0
    @_clearing_que = false
    @_sins = 0

  add: (msg) ->
    @_que.push(msg)
    @_clearQue() if @_clearing_que == false

  getQue: () ->
    return @_que

  _clearQue: () ->
    @_clearing_que = true
    diff = new Date().getTime() - @_last
    if diff > @delay or @_sins < @max_sins
      @stream.write(msg = @_que.shift())
      @_last = new Date().getTime()
      if diff > @delay
        @_sins -= 1 if @_sins > 0 #substract a sin but not below 0
      else
        @_sins += 1
      if @_que.length > 0 then @_clearQue() else @_clearing_que = false
    else
      setTimeout(@_clearQue.bind(@), @delay + 1 - diff)

module.exports = Dispatcher
