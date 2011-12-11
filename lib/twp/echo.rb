module TWP
  module Echo
    ECHO_SPEC = TWP.load_tdl(:echo)

    class Client < TWP::Client
      set_spec ECHO_SPEC
    end

    class Server < TWP::Server
      set_spec ECHO_SPEC

      on_message(:Request) do |msg|
        log "received message: %p" % msg.text
        send_message(:Reply, msg.text, msg.text.scan(/\w/).count)
      end
    end
  end
end