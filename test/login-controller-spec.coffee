describe 'LoginController', ->
  beforeEach ->
    module 'email-password'

    inject ($controller, $q, $rootScope) ->
      @q = $q
      @rootScope = $rootScope
      @AuthenticatorService = authenticate: sinon.stub().returns @q.when()
      @sut = $controller 'LoginController',
        AuthenticatorService: @AuthenticatorService

  describe '->login', ->
    describe 'when called with a email and password', ->
      beforeEach ->
        @sut.login 'r@go.co', 'sliced'
        @rootScope.$digest()

      it 'should call AuthenticatorService.authenticate with the email and password', ->
        expect(@AuthenticatorService.authenticate).to.have.been.calledWith 'r@go.co', 'sliced'

    describe 'when called and authenticate throws an error', ->
      beforeEach ->
        @AuthenticatorService.authenticate.returns @q.reject('ERROR')
        @sut.login 'r@go.co', 'sliced'
        @rootScope.$digest()

      it 'should add ERROR to the errorMessage on the scope', ->
        expect(@sut.errorMessage).to.equal 'ERROR'


        
    