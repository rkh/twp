module TWP
  module TFS
    ListResult  = Struct.new :directories, :files
    StatResult  = Struct.new :size, :mtime, :atime

    class Local
      MODES = %w[rb wb ab]
      attr_reader :root, :monitors, :paths, :prefix

      def initialize(root = nil)
        @root, @monitors, @paths = root, [], []
      end

      def join(*args)
        args.flatten!
        raise RuntimeError, 'path may not include ".."' if args.include? '..'
        raise RuntimeError, 'paths may not include /' if args.any? { |a| a.include? '/' }
        File.join(root || Dir.pwd, *args.compact)
      end

      def remote?
        true
      end

      def local?
        not remote?
      end

      def open(directory, file, mode)
        path   = join(directory, file)
        event  = File.exist?(file) ? :Created : :Changed
        openfh = File.open(path, MODES[mode])
        handle = openfh.fileno
        send_event(event, directory, file) if mode > 0
        paths[handle]       = [directory, file]
        handle
      end

      def read(fh, count)
        IO.open(fh).read(count)
      end

      def write(fh, data)
        io = IO.open(fh)
        io.write(data)
        io.flush # make sure this is really the point in time the file changed
        send_event(:Changed, fh)
        nil
      end

      def seek(fh, offset)
        IO.open(fh).seek(offset)
        nil
      end

      def close(fh)
        IO.open(fh).close
        paths.delete_at fh
        nil
      end

      def listdir(directory =  [])
        entries = Dir.entries(join(directory)) - ['..', '.']
        entries = entries.group_by { |e| File.directory? join(directory, e) }
        ListResult.new Array(entries[true]), Array(entries[false])
      end

      def stat(directory, file)
        path = join(directory, file)
        StatResult.new File.size(path), File.mtime(path).to_i, File.atime(path).to_i
      end

      def mkdir(directory = [])
        Dir.mkdir join(directory)
        send_event(:Created, directory[0..-2], directory[-1])
        nil
      end

      def rmdir(directory = [])
        Dir.rmdir join(directory)
        send_event(:Deleted, directory[0..-2], directory[-1])
        nil
      end

      def remove(directory, file)
        File.delete join(directory, file)
        send_event(:Deleted, directory, file)
        nil
      end

      def monitor(directory, recursive, host, port)
        recursive = recursive == 1
        signature = [directory, recursive, host, port]
        monitors << signature unless monitors.include? signature
        monitors.index(signature)
      end

      def stop_monitoring(handle)
        monitors.delete_at(handle)
        nil
      end

      private

      def send_event(type, directory, file = nil)
        directory, file = paths[Integer(directory)] if file.nil?
        monitors.each do |dir, recursive, host, port|
          next unless recursive && dir.zip(directory).all? { |a,b| a == b } or dir == directory
          TWP::FAM::Client.open(host, port) { |f| f.send_message(type, directory, file) }
        end
      end
    end

    class Remote < RPC::Remote
      def write(*args)
        method_missing(__method__, *args)
      end

      def open(*args)
        method_missing(__method__, *args)
      end

      def listdir(*args)
        ListResult.new(*super)
      end

      def stat(*args)
        StatResult.new(*super)
      end
    end

    class Client < TWP::RPC::Client
      def self.get(*args)
        Remote.new(new(*args))
      end

      def response_expected?(operation)
        operation != :close
      end

      def scope
        @scope ||= Remote.new(self)
      end
    end

    class Server < TWP::RPC::Server
      def setup(parameter = nil)
        self.object = Local.new(parameter)
        super
      end
    end
  end
end
