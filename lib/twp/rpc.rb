module TWP
  module RPC
    RPC_SPEC = TWP.load_tdl(:rpc)

    class RPCException < PeerError
    end

    class Remote
      attr_accessor :connection

      def initialize(connection)
        @connection = connection
      end

      def remote?
        false
      end

      def local?
        not remote?
      end

      def method_missing(*args)
        @connection.send_rpc(*args)
      end
    end

    class Client < TWP::Client
      set_spec RPC_SPEC

      def self.get(*args)
        Remote.new(new(*args))
      end

      def response_expected?(operation)
        true
      end

      def send_rpc(operation, *args)
        response_expected = response_expected? operation.to_sym
        send_message :Request, request_id, response_expected ? 1 : 0, operation.to_s, structify(*args)
        return unless response_expected
        result = read_message.result
        raise RPCException, result.text if result.is_a? Message and result.name == :RPCException
        result
      end

      def request_id
        @request_id ||= 0
        @request_id += 1
      end

      def structify(*args)
        return nil unless args.any?
        struct = Struct.new(*args.size.times.map { |i| :"arg_#{i}" })
        struct.new(*args)
      end
    end

    class Server < TWP::Server
      set_spec RPC_SPEC
      attr_accessor :object

      on_message(:Request) do |msg|
        begin
          result = object.public_send(msg.operation, *msg.parameters.to_a)
          send_message(:Reply, msg.request_id, result) if msg.response_expected == 1
        rescue StandardError => error
          #send_message :RPCException, error.message
          send_data error
        end
      end
    end
  end
end