# Rack:AB

Default settings assign users by id to one of two equally sized buckets, "a" and "b", and pass the bucket name to the app via the env object.

## Basic usage

1. Set the user id in a cookie called _user_id_
1. Add Rack::AB to your code
    use Rack::AB
    # ...
    if 'a' == env['rack.ab.bucket_name']
      body = 'content for bucket a'
    else
      body = 'content for bucket b'
    end
    # ...
    [200, {}, body]

In development, force a bucket by setting a cookie named _rack_ab_ to the bucket name.

## Configuration

* set buckets, e.g. 10% "control" and 10% "fancy_bucket"
* set user id cookie name
* set override cookie name

Configure like this

    use Rack::AB, :buckets => [{'control' => 10}, {'new_feature' => 10}]
    # ...

Any and all feedback welcome.