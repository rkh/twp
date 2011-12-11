module TWP
  class Session < Reader
    def initialize(*)
      @handshake_seen = false
      super

      log "new connection"
      sessions << self
    end

    def blocking?
      false
    end

    def handshake_seen?
      @handshake_seen
    end

    # return value indicates if something happend
    # used to decide whether to slow down the event loop
    def poll
      buffer_size = @outstanding.size
      read_handshake unless handshake_seen?
      connection.handle(read_message, self)
      true
    rescue Errno::EAGAIN
      @outstanding.size != buffer_size
    rescue PeerError, EOFError => error
      log "dropping connection: #{error.message}"
      sessions.delete self
      begin
        io << connection.encode(error)
        io.close
      rescue
      end
      true
    end

    def send_message(type, *fields)
      connection.send_data connection.message(type, *fields), io
    end

    def sessions
      connection.sessions
    end

    def log(*messages)
      messages.each do |message|
        message = "#{io.addr.last}: #{message}" unless message.nil? or message.empty?
        super message
      end
    end

    private

    def read_handshake
      buffered do
        wire = read_bytes(5)
        raise PeerError, "recieved %p instead of TWP3 handshake" % wire unless wire == "TWP3\n"

        protocol_id = read_data!
        raise PeerError, "wrong protocol %p" % protocol_id unless protocol_id == protocol.id
      end

      debug "received handshake"
      @handshake_seen = true
    end
  end
end
