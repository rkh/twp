module TWP::TDL
  class Renderer
    def initialize(out = $stdout)
      @out, @indentation = out, ""
    end

    def indent(prefix = '  ')
      indent_was, @indentation = @indentation, @indentation + prefix
      yield
    ensure
      @indentation = indent_was
    end

    def <<(line)
      @out.puts @indentation + line
    end
  end
end
