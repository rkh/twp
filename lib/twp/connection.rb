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
        klass.timeout  ||= klass.superclass.timeout
        klass.protocol ||= klass.superclass.protocol
        klass.messages ||= klass.superclass.messages
        klass.message_handlers.merge! klass.superclass.message_handlers
        super
      end

      def on_message(*types, &block)
        types = messages.keys if types.empty? and messages
        types.each { |type| message_handlers[type.to_sym] = block }
      end

      def message_handlers
        @message_handlers ||= {}
      end
    end

    attr_accessor :host, :port, :connection, :last_message

    def initialize(host, port, log = $stderr)
      @host, @port, @log = host, port, log
      connect
    end

    def handle(message, scope = self, &block)
      block = message_handlers[message.name] if message_handlers.include? message.name
      return scope.instance_exec(message, &block) if block
      raise PeerError, "unknown message %p" % message
    end

    def encode(object)
      case object
      when NilClass                       then "\1"
      when Integer                        then encode_int(object)
      when String                         then object.encoding == Encoding::BINARY ? encode_binary(object) : encode_string(object)
      when Message                        then encode_message(object)
      when Exception                      then encode_exception(object)
      when Struct, TWP::RPC::CheapStruct  then encode_struct(object)
      when Array                          then encode_sequence(object)
      else raise NotImplementedError, 'cannot encode %p' % object
      end
    end

    def encode_int(int, tag = 13)
      return tag.chr + [int].pack("c") if int.between? -128, 127
      [tag + 1, int].pack("Cl>")
    end

    def encode_string(str)
      str = str.encode 'utf-8'
      if str.bytesize < 110
        [str.bytesize + 17, str].pack('CA*')
      else
        [127, str.bytesize, str].pack('CL>A*')
      end
    end

    def encode_binary(data)
      [16, data.bytesize, data].pack('CL>A*')
    end

    def encode_message(msg)
      marshal = msg.id < 8 ? (msg.id + 4).chr : [12, msg.id].pack('CL>')
      marshal.force_encoding('binary')
      msg.field_values.each { |f| marshal << encode(f) }
      marshal << "\0"
    end

    def encode_exception(error)
      [12, 8].pack('Cl>') + encode(last_message.id) + encode("%s [%s]" % [error.message, error.backtrace[0..3].join("\n")])
    end

    def encode_struct(struct)
      encode_sequence(struct.to_a, 2)
    end

    def encode_sequence(array, tag = 3)
      tag.chr + array.map { |e| encode(e) }.join + "\0"
    end

    def message(name, *args)
      Message.new(self, name, *args)
    end

    def send_message(*args)
      send_data message(*args)
    end

    def send_data(data, io = @connection)
      send_raw encode(data), io
    end

    def send_raw(raw, io = @connection)
      $stderr.print "\033[36m#{raw.inspect[1..-2]}\033[0m" if ENV['SHOW_STREAM'] and ENV['SHOW_STREAM'] != '0'
      io << raw
    end

    def scope
      self
    end

    def connect
      raise NotImplementedError, "subclass responsibilty"
    end

    def debug?
      !!ENV['DEBUG'] and ENV['DEBUG'] != '0'
    end

    def log(*strings)
      @log.puts(*strings) if @log
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
