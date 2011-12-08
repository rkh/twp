require 'rake'
require 'rspec/core/rake_task'

file('lib/twp/tdl/parser.rb' => 'tdl.kpeg') do
  sh "kpeg tdl.kpeg -f -o lib/twp/tdl/parser.rb"
end

desc 'Compile files'
task build: 'lib/twp/tdl/parser.rb'

desc 'Run specs'
RSpec::Core::RakeTask.new { |t| t.pattern = './spec/**/*_spec.rb' }

task default: [:build, :spec]
