require "json"
require "kemal"
require "redis"

require "./cr-web-session/*"

prefix = "ws:"
minutes_ttl = 10

redis = Redis.new

post "/save" do |env|
  env.response.content_type = "application/json"
  if !env.params.json["key"]?
    {"error": "no key"}.to_json
  elsif !env.params.json["entry"]?
    {"error": "no entry"}.to_json
  else
    key = env.params.json["key"].as(String)
    entry = env.params.json["entry"]
    redis.set(prefix+key, entry.to_json)
    redis.expire(prefix+key, 60*minutes_ttl)
    {"error": ""}.to_json
  end
end

post "/query" do |env|
  env.response.content_type = "application/json"
  if !env.params.json["key"]?
    {"error": "no key"}.to_json
  else
    res = {} of String => JSON::Any

    key = env.params.json["key"].as(String)
    entry = redis.get(prefix+key)
    if entry.nil?
      res = {"error": "no entry"}
    else
      # Set entry TTL to what was given in the request or return current TTL
      ttl = 0
      if env.params.json["expire"]? && env.params.json["expire"].is_a?(Number)
        ttl = env.params.json["expire"].as(Number)
        redis.expire(prefix+key, ttl)
      else
        ttl = redis.ttl(prefix+key)
      end

      res = {
        "error": "",
        "entry": JSON.parse(entry),
        "ttl": ttl
      }
    end
    res.to_json
  end
end

module Cr::Web::Session
  Kemal.run
end
