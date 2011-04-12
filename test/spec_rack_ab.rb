require 'test/spec'
require 'rack/mock'
require 'rack/ab'

context "Rack::AB" do
  
  specify "should expose release" do
    Rack::AB.should.respond_to :release
  end
  
  specify "should set bucket cookie if no cookie is set" do
    app = lambda { |env|
      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app)

    response = Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => '')
    response.headers['Set-Cookie'].should =~ /rack_ab=[a-zA-Z0-9]{32}/
  end  
  
end
