begin
  require 'twp'
rescue LoadError
  $LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
  require 'bundler/setup'
  require 'twp'
end
