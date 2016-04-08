http = require 'http'
CheckWhitelistConfigureSent = require '../'

describe 'CheckWhitelistConfigureSent', ->
  beforeEach ->
    @whitelistManager =
      checkConfigureSent: sinon.stub()

    @sut = new CheckWhitelistConfigureSent
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureSent.yields null, true
        job =
          metadata:
            auth:
              uuid: 'subscriber'
            fromUuid: 'emitter'
            toUuid: 'subscriber'
            responseId: 'yellow-green'
        @sut.do job, (error, @newJob) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkConfigureSent).to.have.been.calledWith
          emitter: 'emitter'
          subscriber: 'subscriber'

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@newJob.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a valid job without a from', ->
      beforeEach (done) ->
        job =
          metadata:
            auth:
              uuid: 'subscriber'
            toUuid: 'subscriber'
            responseId: 'yellow-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 422', ->
        expect(@newJob.metadata.code).to.equal 422

      it 'should get have the status of Unprocessable Entity', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[422]

    describe 'when called with a valid job without a to', ->
      beforeEach (done) ->
        job =
          metadata:
            auth:
              uuid: 'subscriber'
            fromUuid: 'emitter'
            responseId: 'yellow-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 422', ->
        expect(@newJob.metadata.code).to.equal 422

      it 'should get have the status of Unprocessable Entity', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[422]

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureSent.yields null, true
        job =
          metadata:
            auth:
              uuid: 'subscriber2'
            fromUuid: 'emitter2'
            toUuid: 'subscriber2'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkConfigureSent).to.have.been.calledWith
          emitter: 'emitter2'
          subscriber: 'subscriber2'

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 204', ->
        expect(@newJob.metadata.code).to.equal 204

      it 'should get have the status of OK', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a toUuid that does not match auth.uuid', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureSent.yields null, false
        job =
          metadata:
            auth:
              uuid: 'imposter'
            fromUuid: 'emitter'
            toUuid: 'subscriber'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@newJob.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called with a job that with a device that has an invalid whitelist', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureSent.yields null, false
        job =
          metadata:
            auth:
              uuid: 'subscriber'
            fromUuid: 'emitter'
            toUuid: 'subscriber'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkConfigureSent).to.have.been.calledWith
          emitter: 'emitter'
          subscriber: 'subscriber'

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@newJob.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the checkConfigureSent yields an error', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureSent.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'subscriber'
            fromUuid: 'emitter'
            toUuid: 'subscriber'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkConfigureSent).to.have.been.calledWith
          emitter: 'emitter'
          subscriber: 'subscriber'

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@newJob.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[500]
