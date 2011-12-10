require 'ostruct'

module TWP
  class Server < Connection
    self.timeout = 120

    def self.server?
      true
    end

    attr_reader :sessions

    def connect
      log "listening on #{host}:#{port}"
      @connection = TCPServer.new host, port
      @sessions = []
    end

    def setup(parameter = nil)
      yield self if block_given?
    end

    def start
      loop do
        something_happened = false
        accept { |io| something_happened |= Session.new(self, io) }
        sessions.each { |s| something_happened |= s.poll }
        sleep 0.1 unless something_happened
      end
    end

    def accept
      if sessions.empty?
        debug "no open connections, blocking event loop"
        yield @connection.accept
      else
        yield @connection.accept_nonblock
      end
    rescue Errno::EAGAIN
    end
  end
end
