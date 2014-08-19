###
The Dispatcher class.
It takes asynchronous requests to send something through the stream
and sends it asynchronously in intervals.
###


class Dispatcher
  constructor: (@stream, @delay = 0, @que = [], @last = 0, @clearing_que = false, @max_sins = 0) ->
    @sins = 0

  add: (msg) ->
    @que.push(msg)
    @clearQue() if @clearing_que == false

  clearQue: () ->
    @clearing_que = true
    diff = new Date().getTime() - @last
    if diff > @delay or @sins < @max_sins
      @stream.write(msg = @que.shift())
      @last = new Date().getTime()
      if diff > @delay
        @sins -= 1 if @sins > 0 #substract a sin but not below 0
      else
        @sins += 1
      if @que.length > 0 then @clearQue() else @clearing_que = false
    else
      setTimeout(@clearQue.bind(@), @delay + 1 - diff)

module.exports = Dispatcher
