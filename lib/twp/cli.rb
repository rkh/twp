require 'optparse'

module TWP
  class CLI
    DEFAULT_CLIENT_HOST = "www.dcl.hpi.uni-potsdam.de"
    DEFAULT_CLIENT_PORT = 80
    DEFAULT_SERVER_HOST = "127.0.0.1"
    DEFAULT_SERVER_PORT = 5678

    def self.run(*args, &block)
      cli = new(*args)
      cli.run(&block)
    ensure
      cli.close if cli
    end

    attr_accessor :host, :port

    def default_host(klass)
      klass.server? ? DEFAULT_SERVER_HOST : DEFAULT_CLIENT_HOST
    end

    def default_port(klass)
      klass.server? ? DEFAULT_SERVER_PORT : DEFAULT_CLIENT_PORT
    end

    def initialize(klass, join_command = true, argv = ARGV)
      parse_options(argv, klass)
      @host     ||= default_host(klass)
      @port     ||= default_port(klass)
      @command    = argv.join(" ") # Shellwords.shelljoin?
      @connection = klass.new(host, port)
    end

    def default_command
      @command unless @command.empty?
    end

    def run(command = default_command, &block)
      if @connection.server?
        [:INT, :TERM].each { |sig| trap(sig) { exit } }
        @connection.setup(command, &block)
        @connection.start
      elsif command
        puts @connection.instance_exec(command, &block)
      else
        loop do
          print "> " if $stdin.tty?
          exit unless command = gets
          run(command.chomp, &block)
        end
      end
    end

    def close
      @connection.close
    end

    def parse_options(argv, klass)
      OptionParser.new do |opts|
        opts.banner = "Usage: #$0 [options] [command]"
        
        opts.separator ""
        opts.separator "Supported modes:"
        opts.separator ""
        opts.separator "  # with command line options"
        opts.separator "  $ #$0 -p 80 some_command"
        opts.separator "  ..."
        opts.separator ""
        opts.separator "  # from stdin"
        opts.separator "  $ echo some_command | #$0 -p 80"
        opts.separator "  ..."
        opts.separator ""
        opts.separator "  # interactive (exit with ctrl-d)"
        opts.separator "  $ #$0 -p 80"
        opts.separator "  > some_command"
        opts.separator "  ..."
        opts.separator "  > some_other_command"
        opts.separator "  ..."

        opts.separator ""
        opts.separator "General options:"
        opts.on('-r', '--require LIBRARY', 'requires LIBRARY') { |l| require l }
        opts.on('-I', '--include PATH', 'adds PATH to load path') { |p| $LOAD_PATH.unshift p }
        opts.on('-d', '--[no-]-debug', "run in debug mode") { |d| ENV['DEBUG'] = d ? '1' : '0' }

        opts.separator ""
        opts.separator "Connection options:"
        opts.on('-b', '--host HOST', "host to connect to (default: #{default_host(klass)})") { |h| @host = h }
        opts.on('-p', '--port PORT', "port to connect to (default: #{default_port(klass)})") { |p| @port = Integer(port) }
        opts.on('-t', '--timeout SEC', "set timeout for inactive connections") { |t| klass.timeout = Integer(t) }

        if klass.client?
          opts.on('-l', '--local', "same as -h #{DEFAULT_SERVER_HOST} -p #{DEFAULT_SERVER_PORT}") do
            @host, @port = DEFAULT_SERVER_HOST, DEFAULT_SERVER_PORT
          end
        end

        opts.on('-h', '--help') do
          $stderr.puts opts
          if klass.respond_to? :help
            $stderr.puts "", "Command:"
            $stderr.puts klass.help
          end
          exit 1
        end
      end.order!(argv)
    end
  end
end
