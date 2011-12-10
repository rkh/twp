require 'twp'

module TWP
  module TDL
    include Tool::Autoloader

    def self.load_file(file)
      load File.read(file)
    end

    def self.load(string)
      parser = Parser.new(string)
      raise parser.show_error unless parser.parse
      parser.ast
    end
  end
end
