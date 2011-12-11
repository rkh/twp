require 'socket'

module TWP
  class Connection
    class << self
      attr_accessor :protocol, :timeout, :messages

      def set_spec(tdl)
        tdl.apply(self)
      end

      def server?
        raise NotImplementedError, "subclass responsibilty"
      end

      def client?
        not server?
      end

      def connected?
        true
      end

      def inherited(klass)
        klass.timeout ||= klass.superclass.timeout
        super
      end

      def on_message(type, &block)
        message_handlers[type.to_sym] = block
      end

      def message_handlers
        @message_handlers ||= {}
      end
    end

    attr_accessor :host, :port, :connection, :last_message

    def initialize(host, port)
      @host, @port = host, port
      connect
    end

    def handle(message, scope = self, &block)
      block = message_handlers[message.name] if message_handlers.include? message.name
      return scope.instance_exec(message, &block) if block
      raise PeerError, "unknown message %p" % message
    end

    def encode(object)
      case object
      when NilClass   then "\1"
      when Integer    then encode_int(object)
      when String     then object.encoding == Encoding::BINARY ? encode_binary(object) : encode_string(object)
      when Message    then encode_message(object)
      when Exception  then encode_exception(object)
      else raise NotImplementedError, 'cannot encode %p' % object
      end
    end

    def encode_int(int, tag = 13)
      return [tag, int].pack("cc") if int.between? -128, 127
      [byte + 1, int].pack("cl>")
    end

    def encode_string(str)
      str = str.encode 'utf-8'
      if str.bytesize < 110
        [str.bytesize + 17, str].pack('cA*')
      else
        [127, str.bytesize, str].pack('cl>A*')
      end
    end

    def encode_message(msg)
      marshal = msg.id < 8 ? (msg.id + 4).chr : [12, msg.id].pack('cl>')
      marshal.force_encoding('binary')
      msg.field_values.each { |f| marshal << encode(f) }
      marshal << "\0"
    end

    def encode_exception(error)
      [12, 8].pack('cl>') + encode(last_message.id) + encode(error.message)
    end

    def message(name, *args)
      Message.new(self, name, *args)
    end

    def send_message(*args)
      send_data message(*args)
    end

    def send_data(data, io = @connection)
      io << encode(data)
    end

    def connect
      raise NotImplementedError, "subclass responsibilty"
    end

    def debug?
      !!ENV['DEBUG'] and ENV['DEBUG'] != '0'
    end

    def log(*strings)
      $stderr.puts(*strings)
    end

    def debug(*strings)
      log(*strings) if debug?
    end

    def close
      connection.close if connection and not connection.closed?
    end

    def protocol
      self.class.protocol
    end

    def messages
      self.class.messages
    end

    def timeout
      self.class.timeout
    end

    def server?
      self.class.server?
    end

    def client?
      self.class.client?
    end

    def message_handlers
      self.class.message_handlers
    end
  end
end
