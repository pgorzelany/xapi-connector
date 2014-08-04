###
The Dispatcher class.
It takes asynchronous requests to send something through the stream
and sends it asynchronously in intervals
###

class Dispatcher
  constructor: (@stream, @delay = 0, @que = [], @last = 0, @clearing_que = false) ->

  add: (msg) ->
    @que.push(msg)
    @clearQue() if @clearing_que == false

  clearQue: () ->
    @clearing_que = true
    diff = new Date().getTime() - @last
    if diff > @delay
      console.log("Sending message: #{msg = @que.shift()} \n")
      @stream.write(msg)
      @last = new Date().getTime()
      if @que.length > 0 then setTimeout(@clearQue.bind(@), @delay + 1) else @clearing_que = false
    else
      setTimeout(@clearQue.bind(@), @delay + 1 - diff)

module.exports = Dispatcher
