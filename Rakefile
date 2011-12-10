require 'rake'
require 'rspec/core/rake_task'

file('lib/twp/tdl/parser.rb' => 'tdl.kpeg') do |t|
  sh "kpeg tdl.kpeg -f -o lib/twp/tdl/parser.rb"
  code = File.read("lib/twp/tdl/parser.rb")
  File.write("lib/twp/tdl/parser.rb", "# THIS CODE HAS BEEN GENERATED!\n\n#{code}")
end

desc 'Compile files'
task build: 'lib/twp/tdl/parser.rb'

desc 'Run specs'
RSpec::Core::RakeTask.new { |t| t.pattern = './spec/**/*_spec.rb' }

task default: [:build, :spec]
