module TWP::TDL
  class Message < Node
    def apply(base)
      base.messages ||= {}
      base.messages[name.to_sym] = self
    end
  end
end
