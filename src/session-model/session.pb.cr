## Generated from session.proto for websession
require "protobuf"


struct Context
  include Protobuf::Message
  
  contract do
    optional :id, :string, 1
    optional :timestamp, :uint64, 2
  end
end
