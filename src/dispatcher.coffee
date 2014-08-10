###
The Dispatcher class.
It takes asynchronous requests to send something through the stream
and sends it asynchronously in intervals.
To maximize the speed of sending the messages to the API, we will take advantage
of the fact that we can send 5 requests in less than 200ms intervals.
The API measures how many times we send messages in <200ms intervals.
If we send a message in <200ms interval the API counts this as a 'sin'.
The API counts our sins and we can't have more than 6 of those.
Each time we send a message in >200ms one sin is substrated
###

Debugger = require('debug-js')
d = new Debugger('Dispatcher', 'green')

class Dispatcher
  constructor: (@stream, @delay = 0, @que = [], @last = 0, @clearing_que = false, @max_sins = 5) ->
    @sins = 0

  add: (msg) ->
    @que.push(msg)
    @clearQue() if @clearing_que == false

  clearQue: () ->
    @clearing_que = true
    diff = new Date().getTime() - @last
    if diff > @delay or @sins < @max_sins
      d.debug("Sending message: #{msg = @que.shift()} \n")
      @stream.write(msg)
      @last = new Date().getTime()
      if diff > @delay
        @sins -= 1 if @sins > 0 #substract a sin but not below 0
      else
        @sins += 1
      if @que.length > 0 then @clearQue() else @clearing_que = false
    else
      setTimeout(@clearQue.bind(@), @delay + 1 - diff)

module.exports = Dispatcher
