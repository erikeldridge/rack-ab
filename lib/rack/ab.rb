module Rack

  # The Rack::AB middleware splits assigns a user to a bucket
  # according the the user's id, and passes the bucket name
  # into the app via the env object.
  #
  # Example
  #
  # use Rack::AB,
  #   :buckets => [{:v => 10}, {:b => 10}, {:n => 10}]
  #
  # creates three buckets, 'v', 'b', and 'n'. Users will be assigned to buckets as follows:
  # * ids in [0, 10) --> 'v'
  # * ids in [10, 20) --> 'b'
  # * ids in [20, 30) --> 'n'
  # * ids in [30, 100) --> nil
  #
  # Usage
  #
  # 1) Use Rack::AB middleware via 'use' directive
  # 2) Set options as desired
  # 3) Check bucket value inside Rack app via the 'rack.ab.bucket_name' member of the
  #    env object.
  # 4) Use this bucket name to split your traffic, eg if 'a' == env['rack.ab.bucket_name']:
  #    ...; elsif 'b' == env['rack.ab.bucket_name']: ... end
  #

  class AB

    def initialize(app, options={})
      @app = app

      # Name of cookie for forcing bucket setting
      @ab_cookie_name = options[:ab_cookie_name] || 'rack_ab'

      # Name of cookie for setting the user id
      @user_id_cookie_name = options[:user_id_cookie_name] || 'user_id'

      # Bucket definitions
      @buckets = options[:buckets] || [{:a => 50}, {:b => 50}]

    end

    def call(env)

      req = Request.new(env)

      if req.cookies[@ab_cookie_name]
        env["rack.ab.bucket_name"] = req.cookies[@ab_cookie_name]
      elsif req.cookies[@user_id_cookie_name]

        user_id = req.cookies[@user_id_cookie_name].to_i

        base_percentage = 0
        @buckets.each do |bucket|

          name, percentage = bucket.first

          base_percentage += percentage
          if user_id % 100 < base_percentage
            env["rack.ab.bucket_name"] = name.to_s
            break
          end
        end

      end
      @app.call(env)
    end

  end
end