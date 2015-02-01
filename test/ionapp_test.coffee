chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'ionapp', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/ionapp')(@robot)

  it 'registers a respond listener for "who\'s absent"', ->
    expect(@robot.respond).to.have.been.calledWithMatch sinon.match( (val) ->
      val.test "who's absent"
    )

  it 'registers a respond listener for "who\'ll be absent on Friday"', ->
    expect(@robot.respond).to.have.been.calledWithMatch sinon.match( (val) ->
      val.test "who'll be absent on Friday"
    )
