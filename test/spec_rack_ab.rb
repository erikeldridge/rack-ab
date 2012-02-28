require 'test/spec'
require 'rack/mock'

context "Rack::AB" do
  specify "should provide a way to set a custom ab override cookie name" do

    bucket_name = 'h'

    app = lambda { |env|

      assert_equal env['rack.ab.bucket_name'], bucket_name

      [200, {'Content-Type' => 'text/plain'}, '']
    }

    cookie_name = 'new_cookie_name'
    app = Rack::AB.new(app, :ab_cookie_name => cookie_name)
    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => "#{cookie_name}=#{bucket_name}")

  end

  specify "should provide a way to set a custom user id cookie name" do

    app = lambda { |env|

      assert_equal env['rack.ab.bucket_name'], 'a'

      [200, {'Content-Type' => 'text/plain'}, '']
    }

    cookie_name = 'new_cookie_name'
    app = Rack::AB.new(app, :user_id_cookie_name => cookie_name)
    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => "#{cookie_name}=1")

  end

  specify "should provides a way to set a custom bucket sizes" do

    app = lambda { |env|
      assert_equal 'v', env['rack.ab.bucket_name']
      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app, :buckets => [{:v => 10}, {:b => 10}, {:n => 10}])
    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => 'user_id=5')

    app = lambda { |env|
      assert_equal 'b', env['rack.ab.bucket_name']
      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app, :buckets => [{:v => 10}, {:b => 10}, {:n => 10}])
    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => 'user_id=15')

    app = lambda { |env|
      assert_equal 'n', env['rack.ab.bucket_name']
      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app, :buckets => [{:v => 10}, {:b => 10}, {:n => 10}])
    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => 'user_id=25')

    app = lambda { |env|
      assert_equal nil, env['rack.ab.bucket_name']
      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app, :buckets => [{:v => 10}, {:b => 10}, {:n => 10}])
    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => 'user_id=35')
  end

  specify "should provide a way to split traffic inside app" do
    app = lambda { |env|
      if 'a' == env['rack.ab.bucket_name']
        body = 'content for bucket a'
      elsif 'b' == env['rack.ab.bucket_name']
        body = 'content for bucket b'
      end
      [200, {'Content-Type' => 'text/plain'}, body]
    }
    app = Rack::AB.new(app)

    response = Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => 'user_id=164')

    response.body.should.equal 'content for bucket b'
  end

end

context "Rack::AB without user id or ab cookies" do
  specify "should do nothing without ab or user id cookies" do
    app = lambda { |env|

      assert_nil env['rack.ab.bucket_name'], "should not set env"

      [200, {'Content-Type' => 'text/plain'}, '']
    }
    Rack::AB.new(app).call({})
  end
end

context "Rack::AB with user id in [0, 50)" do
  specify "should put user in bucket 'a' by default" do
    app = lambda { |env|

      assert_equal env['rack.ab.bucket_name'], 'a'

      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app)

    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => 'user_id=13')
  end
end

context "Rack::AB with user id in [50, 100)" do
  specify "should be in bucket 'b' by default" do
    app = lambda { |env|

      assert_equal env['rack.ab.bucket_name'], 'b'

      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app)

    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => 'user_id=50')
  end
end

context "Rack::AB with ab override cookie" do
  specify "should put user in bucket specified by cookie" do

    bucket_name = 'g'

    app = lambda { |env|

      assert_equal env['rack.ab.bucket_name'], bucket_name

      [200, {'Content-Type' => 'text/plain'}, '']
    }
    app = Rack::AB.new(app)
    Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => "rack_ab=#{bucket_name}")
  end
end