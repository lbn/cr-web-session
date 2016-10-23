require "json"
require "kemal"
require "redis"

require "./cr-web-session/*"
require "./session-model/*"

PREFIX = "ws:"
MINUTES_TTL = 10


module Cr::Web::Session
  class Spind
    @redis = Redis.new
    def save_json(env)
      env.response.content_type = "application/json"
      if !env.params.json["key"]?
        {"error": "no key"}.to_json
      elsif !env.params.json["entry"]?
        {"error": "no entry"}.to_json
      else
        key = env.params.json["key"].as(String)
        entry = env.params.json["entry"]
        @redis.set(PREFIX+key, entry.to_json)
        @redis.expire(PREFIX+key, 60*MINUTES_TTL)
        {"error": ""}.to_json
      end
    end

    def query_json(env)
      env.response.content_type = "application/json"
      if !env.params.json["key"]?
          {"error": "no key"}.to_json
      else
        res = {} of String => JSON::Any

        key = env.params.json["key"].as(String)
        entry = @redis.get(PREFIX+key)
        if entry.nil?
          res = {"error": "no entry"}
        else
          # Set entry TTL to what was given in the request or return current TTL
          ttl = 0
          if env.params.json["expire"]? && env.params.json["expire"].is_a?(Number)
            ttl = env.params.json["expire"].as(Number)
            @redis.expire(PREFIX+key, ttl)
          else
            ttl = @redis.ttl(PREFIX+key)
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

    # TODO: add key check back, handle errors better and do everything right
    def query_protobuf(env)
      res = {} of String => JSON::Any

      key = env.params.json["key"].as(String)
      entry = @redis.get(PREFIX+key)
      if entry.nil?
        raise Exception.new("no entry")
      end
      # Set entry TTL to what was given in the request or return current TTL
      ttl = 0
      if env.params.json["expire"]? && env.params.json["expire"].is_a?(Number)
        ttl = env.params.json["expire"].as(Number)
        @redis.expire(PREFIX+key, ttl)
      else
        ttl = @redis.ttl(PREFIX+key)
      end
      entry
    end

    def save_protobuf(env)
      env.response.content_type = "application/json"
      body = env.request.body
      if body.nil?
        raise Exception.new("no body")
      end

      entry_io = MemoryIO.new(body)
      entry = Context.from_protobuf(entry_io)

      key = entry.id
      if key.nil?
        raise Exception.new("no ID")
      end

      @redis.set(PREFIX+key, entry_io.to_s)
      @redis.expire(PREFIX+key, 60*MINUTES_TTL)

      {"error": ""}.to_json
    end


    def init()
      post "/save" do |env|
        #save_json env
        begin
          save_protobuf env
        rescue ex
          puts ex.message
          {"error": ex.message}.to_json
        end
      end

      post "/query" do |env|
        #query_json env
        begin
          query_protobuf env
        rescue ex
          puts ex.message
          {"error": ex.message}.to_json
        end
      end
      Kemal.run
    end
  end

  Spind.new.init
end
