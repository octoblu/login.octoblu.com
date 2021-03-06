describe 'AuthenticatorService', ->
  beforeEach ->
    module 'email-password', ($provide) =>
      @http = post: sinon.stub()
      $provide.value '$http', @http
      $provide.constant 'AUTHENTICATOR_URI', 'https://email-password.octoblu.com'
      return

    inject ($q, $rootScope, AuthenticatorService) =>
      @q = $q
      @rootScope = $rootScope
      @sut = AuthenticatorService

  describe '->authenticate', ->
    describe 'when called with a email, password, and a callbackUrl', ->
      beforeEach ->
        @http.post.returns @q.when(data: {callbackUrl: 'whatevs.co'})
        @sut.authenticate 'sliced@diced.net', 'one-easy-payment', 'laptop.com'
        @rootScope.$digest()

      it 'should call POST /sessions', ->
        url = 'https://email-password.octoblu.com/sessions'
        params =
          email: 'sliced@diced.net'
          password: 'one-easy-payment'
          callbackUrl: 'laptop.com'

        expect(@http.post).to.have.been.calledWith url, params

    describe 'when called and meshblu rejects the email & password', ->
      beforeEach (done) ->
        @http.post.returns @q.reject(data: 'Bad email & password')
        @sut.authenticate 'sliced@diced.net', 'one-easy-payment', 'laptop.com'
            .catch (@error) => done()
        @rootScope.$digest()

      it 'should reject the authenticate promise', ->
        expect(@error).to.equal 'Bad email & password'

    describe 'when called and meshblu resolves with the location', ->
      beforeEach (done) ->
        @http.post.returns @q.when(data: {callbackUrl: 'google.com?some-other=stuff'})
        @sut.authenticate 'sliced@diced.net', 'one-easy-payment', 'google.com'
            .then (@result) => done()
        @rootScope.$digest()

      it 'should return the Location url', ->
        expect(@result).to.deep.equal 'google.com?some-other=stuff'

  describe '->register', ->
    describe 'when called', ->
      beforeEach ->
        @http.post.returns @q.when(data: {callbackUrl: 'something.biz'})
        @sut.register 'taft@president.org', 'bathtub', 'underwater.dive'
        @rootScope.$digest()

      it 'should post to signup.octoblu.com with the email and password', ->
        url = 'https://email-password.octoblu.com/devices'
        params =
          email: 'taft@president.org'
          password: 'bathtub'
          callbackUrl: 'underwater.dive'
        expect(@http.post).to.have.been.calledWith url, params

    describe 'when called and the service rejects', ->
      beforeEach (done) ->
        @http.post.returns @q.reject({data: 'you done screwed up'})
        @sut.register 'complicated', 'dolphin', 'rockslide.gz'
            .catch (@errorMessage) => done()
        @rootScope.$digest()

      it 'should reject the promise and return the error', ->
        expect(@errorMessage).to.equal 'you done screwed up'

    describe 'when called and the service resolves', ->
      beforeEach (done) ->
        @http.post.returns @q.when(data: {callbackUrl: 'die.cool'})
        @sut.register 'crippling', 'insecurity', 'sucked-out'
            .then (@result) => done()
        @rootScope.$digest()

      it 'should reject the promise and return the error', ->
        expect(@result).to.equal 'die.cool'

  describe '->forgotPassword', ->
    describe 'when called with an email', ->
      beforeEach (done) ->
        @http.post.returns @q.when( data: 'hello' )
        @sut.forgotPassword('peter@improved-bacon.com').then (@response) => done()
        @rootScope.$digest()

      it 'should post to http with a request to email-password.octoblu.com/forgot', ->
        url = 'https://email-password.octoblu.com/forgot'
        params =
          email: 'peter@improved-bacon.com'
        expect(@http.post).to.have.been.calledWith url, params

      it 'should resolve the data', ->
        expect(@response).to.equal 'hello'


    describe 'when called with an email and http resolves a different result', ->
      beforeEach (done) ->
        @http.post.returns @q.when( data: 'goodbye!' )
        @sut.forgotPassword('peter@improved-bacon.com').then (@response) => done()
        @rootScope.$digest()

      it 'should post to http with a request to email-password.octoblu.com/forgot', ->
        url = 'https://email-password.octoblu.com/forgot'
        params =
          email: 'peter@improved-bacon.com'
        expect(@http.post).to.have.been.calledWith url, params

      it 'should resolve the data', ->
        expect(@response).to.equal 'goodbye!'

  describe '->resetPassword', ->
    describe 'when called with an email', ->
      beforeEach (done) ->
        @http.post.returns @q.when( data: 'hello' )
        @sut.resetPassword('death-from-above', 'attack', 'vantage-point').then (@response) => done()
        @rootScope.$digest()

      it 'should post to http with a request to email-password.octoblu.com/reset', ->
        url = 'https://email-password.octoblu.com/reset'
        params =
          device: 'death-from-above'
          token: 'attack'
          password: 'vantage-point'

        expect(@http.post).to.have.been.calledWith url, params

      it 'should resolve the data', ->
        expect(@response).to.equal 'hello'

    describe 'when called with an email and http resolves a different result', ->
      beforeEach (done) ->
        @http.post.returns @q.when( data: 'goodbye!' )
        @sut.resetPassword('shriek attack', 'startle', 'any person').then (@response) => done()
        @rootScope.$digest()

      it 'should post to http with a request to email-password.octoblu.com/reset', ->
        url = 'https://email-password.octoblu.com/reset'
        params =
          device: 'shriek attack'
          token: 'startle'
          password: 'any person'

        expect(@http.post).to.have.been.calledWith url, params

      it 'should resolve the data', ->
        expect(@response).to.equal 'goodbye!'
