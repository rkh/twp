module TWP::TDL
  class Struct < Node
    def apply(base)
      # FIXME: not a message
      base.messages ||= {}
      base.messages[name.to_sym] = self
    end
  end
end
