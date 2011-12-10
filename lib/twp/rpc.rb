module TWP
  module RPC
    RPC_SPEC = TWP.load_tdl(:rpc)

    class Client < TWP::Client
      set_spec RPC_SPEC
    end

    class Server < TWP::Server
      set_spec RPC_SPEC
    end
  end
end