module TWP::TDL
  class Protocol < Node
    def apply(base)
      base.protocol = self
      elements.each { |e| e.apply(base) }
    end
  end
end
