module TWP::TDL
  class Node
    def render(io = $stdout)
      renderer = Renderer.new(io)
      render_on(renderer)
    end

    def to_s
      out = StringIO.new
      render(out)
      out.rewind
      out.read
    end

    def apply(base)
      raise NotImplementedError, "cannot apply to #{base}:\n#{self}"
    end

    def render_on(renderer)
      first_line, children = self.class.name.sub(/^TWP::TDL::/, ''), []
      instance_variables.each do |var|
        value = instance_variable_get(var)
        if Array === value
          children = value if not value.empty? and value.all? { |e| Node === e }
        else
          first_line += " #{var.to_s[1..-1]}: #{value.inspect}"
        end
      end
      renderer << first_line
      renderer.indent { children.each { |c| c.render_on(renderer) } }
    end
  end
end
