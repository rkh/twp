module TWP
  class Client < Connection
    def self.server?
      false
    end

    def send_message(type, *fields)
      send_raw encode(message(type, *fields))
    end

    def send_raw(raw)
      debug "sending: %p" % raw
      @connection << raw
    end

    def connect
      log "connecting to #{host}:#{port}"
      @connection = TCPSocket.new(host, port)

      debug "sending handshake"
      send_raw handshake

      @reader = Reader.new(self, @connection)
    end

    def read_message
      @reader.read_message
    end

    def handshake
      "TWP3\n" + encode(protocol.id)
    end
  end
end
