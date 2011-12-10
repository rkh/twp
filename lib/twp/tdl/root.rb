module TWP::TDL
  class Root < Node
    def apply(base)
      elements.each { |e| e.apply(base) }
    end
  end
end
