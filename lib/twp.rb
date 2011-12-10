require 'tool'
require 'stringio'

module TWP
  Tool::Autoloader::CAPITALIZE.push 'tdl', 'fam', 'rpc', 'tfs'
  include Tool::Autoloader

  def self.load_tdl(file)
    TDL.load_file File.expand_path("../twp/#{file}.tdl", __FILE__)
  end
end
