require 'twp'
require 'fileutils'
require 'timeout'

shared_examples_for 'any TFS implementation' do
  let(:dir) { File.expand_path('../tfs', __FILE__) }

  def path(arg)
    File.join(dir, arg)
  end

  def write(file, text = '')
    File.write path(file), text
  end

  def read(file)
    File.read path(file)
  end

  before(:each) do
    FileUtils.rm_rf(dir)
    FileUtils.mkdir_p(dir)
    FileUtils.mkdir_p(path('sub'))
  end

  describe :open do
    it 'returns a file handle' do
      write('foo.txt')
      subject.open([], 'foo.txt', 0).should be_an(Integer)
    end

    it 'can append to existing files' do
      write('sub/foo.txt', 'foo')
      subject.write(subject.open(['sub'], 'foo.txt', 2), 'bar')
      read('sub/foo.txt').should be == 'foobar'
    end

    it 'can create new files' do
      File.should_not exist(path('foo.txt'))
      subject.open([], 'foo.txt', 1)
      File.should exist(path('foo.txt'))
    end

    it 'can truncate existign files' do
      write('foo.txt', 'foo')
      subject.open([], 'foo.txt', 1)
      read('foo.txt').should be_empty
    end
  end

  describe :read do
    it 'returns a binary blob' do
      write('foo.txt', 'foo')
      result = subject.read subject.open([], 'foo.txt', 0), 2
      result.should be == 'fo'
      result.encoding.should be == Encoding::BINARY
    end
  end

  describe :write do
    it 'writes to a file' do
      write('sub/foo.txt', 'foo')
      subject.write subject.open(['sub'], 'foo.txt', 1), 'bar'
      read('sub/foo.txt').should be == 'bar'
    end

    it 'returns nil' do
      subject.write(subject.open(['sub'], 'foo.txt', 1), 'bar').should be_nil
    end
  end

  describe :seek do
    it 'seeks' do
      write('foo.txt', 'foo')
      fd = subject.open [], 'foo.txt', 0
      subject.seek(fd, 1)
      result = subject.read(fd, 2)
      result.should be == 'oo'
    end

    it 'returns nil' do
      write('foo.txt', 'foo')
      fd = subject.open [], 'foo.txt', 0
      subject.seek(fd, 1).should be_nil
    end
  end

  describe :close do
    it 'closes a file handle' do
      fd = subject.open ['sub'], 'foo.txt', 1
      subject.close(fd)
      expect { subject.write(fd, 'x') }.to raise_error
    end

    it 'returns nil' do
      fd = subject.open ['sub'], 'foo.txt', 1
      subject.close(fd).should be_nil
    end
  end

  describe :listdir do
    it 'returns a list struct' do
      subject.listdir([]).should be_a(TWP::TFS::ListResult)
    end

    it 'lists directories' do
      subject.listdir([]).directories.should include('sub')
    end

    it 'lists files 'do
      write('sub/foo')
      subject.listdir(['sub']).files.should include('foo')
    end
  end

  describe :stat do
    before(:each) { write('foo', 'bar') }

    it 'returns a stat struct' do
      subject.stat([], 'foo').should be_a(TWP::TFS::StatResult)
    end

    it 'includes the size' do
      subject.stat([], 'foo').size.should be == 3
    end

    it 'includes atime' do
      subject.stat([], 'foo').atime.should be_a(Integer)
    end

    it 'includes mtime' do
      before = Time.now.to_i
      write('foo', 'bar')
      after  = Time.now.to_i
      subject.stat([], 'foo').mtime.should be_between(before, after)
    end
  end

  describe :mkdir do
    it 'creates a directory' do
      subject.mkdir ['sub', 'sub']
      subject.mkdir ['sub', 'sub', 'sub']
      File.should be_directory(path('sub/sub/sub'))
    end

    it 'returns nil' do
      subject.mkdir(['sub', 'sub']).should be_nil
    end
  end

  describe :rmdir do
    it 'removes a directory' do
      subject.rmdir ['sub']
      File.should_not exist(path('sub'))
    end

    it 'returns nil' do
      subject.rmdir(['sub']).should be_nil
    end
  end

  describe :remove do
    it 'removes a file' do
      write('foo')
      subject.remove([], 'foo')
      File.should_not exist('foo')
    end

    it 'returns nil' do
      write('foo')
      subject.remove([], 'foo').should be_nil
    end
  end
end

describe TWP::TFS::Local do
  subject { TWP::TFS::Local.new(dir) }
  it_behaves_like 'any TFS implementation'
end

describe TWP::TFS::Server do
  let(:out) { ENV['DEBUG'] ? $stderr : nil }

  around(:each) do |example|
    tries = 0
    begin
      tries += 1
      port = 7654
      begin
        tfs_server = TWP::TFS::Server.new('127.0.0.1', port, out)
      rescue Errno::EADDRINUSE
        port += 1
        retry
      end
      tfs_server.setup(dir)
      tfs_server.start(false)
      @client = TWP::TFS::Client.get(tfs_server.host, tfs_server.port, out)
      Timeout.timeout(2) { example.run }
      @client.connection.disconnect
      tfs_server.stop
    rescue Errno::EBADF, TWP::PeerError, IOError, Timeout::Error
      raise unless tries < 5 # fun times!
      retry
    end
  end

  subject { @client }

  it_behaves_like 'any TFS implementation'
end
