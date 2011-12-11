module TWP
  class Client < Connection
    def self.open(*args)
      client = new(*args)
      yield client
    ensure
      client.close
    end

    def self.server?
      false
    end

    def connected?
      @connected
    end

    def send_message(type, *fields)
      send_raw encode(message(type, *fields))
    end

    def send_raw(raw)
      debug "sending: %p" % raw
      @connection << raw
    end

    def connect
      debug "connecting to #{host}:#{port}"
      @connection = TCPSocket.new(host, port)

      debug "sending handshake"
      send_raw handshake

      @reader    = Reader.new(self, @connection)
      @connected = true
    end

    def disconnect
      close
      @connected = false
    end

    def read_message
      @reader.read_message
    end

    def handshake
      "TWP3\n" + encode(protocol.id)
    end
  end
end
