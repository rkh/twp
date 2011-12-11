require 'ostruct'
require 'timeout'

module TWP
  class Server < Connection
    attr_accessor :stopping, :running, :thread
    alias running? running
    alias stopping? stopping
    self.timeout = 2

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

    def join
      @thread.join if @thread and Thread.current != @thread
    end

    def stop
      log "stopping server"
      self.stopping = true
      join
    end

    def start(block = true)
      Thread.abort_on_exception = true
      raise RuntimeError, 'aready running' if running?
      join if stopping?
      @thread = Thread.new { start! }
      join if block
    end

    def start!
      self.running  = true
      connect if @connection.nil? or @connection.closed?
      loop do
        something_happened = false
        accept { |io| something_happened |= Session.new(self, io) }
        sessions.each { |s| something_happened |= s.poll }
        break if stopping?
        sleep 0.1 unless something_happened
      end
      Timeout.timeout(1) do
        sessions.each { |s| s.close rescue nil }
        @connection.close rescue nil
      end
    rescue Timeout::Error
    ensure
      @connection = nil
      self.stopping = false
      self.running  = false
    end

    def accept
      return if stopping?
      if sessions.empty?
        Timeout.timeout(1) { yield @connection.accept }
      else
        yield @connection.accept_nonblock
      end
    rescue Errno::EAGAIN, Timeout::Error
    end
  end
end
