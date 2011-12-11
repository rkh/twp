module TWP
  module FAM
    FAM_SPEC = TWP.load_tdl(:fam)

    class Client < TWP::Client
      set_spec FAM_SPEC
    end

    class Server < TWP::Server
      set_spec FAM_SPEC

      on_message do |msg|
        log "FAM: %p" % msg
      end
    end
  end
end
