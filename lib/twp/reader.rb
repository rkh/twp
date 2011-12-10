module TWP
  class Reader
    attr_reader :connection, :io, :last_activity

    def initialize(connection, io)
      @connection, @io      = connection, io
      @recent, @outstanding = new_buffer, new_buffer
      @last_activity        = Time.now
    end

    def debug(*args)
      connection.debug(*args)
    end

    def log(*args)
      connection.log(*args)
    end

    def protocol
      connection.protocol
    end

    def timeout
      connection.timeout
    end

    def blocking?
      true
    end

    def read_message
      read_data
    end

    def read_data(tag = nil)
      buffered { read_data! tag }
    end

    private

    def buffered
      raise "corrupt data: recent=%p outstanding=%p" % [@recent, @outstanding] unless @recent.empty?
      yield
    rescue StandardError => error
      @outstanding.prepend @recent
      raise PeerTimeout if timeout and Time.now - @last_activity > timeout
      raise error
    ensure
      @recent.clear
    end

    def read_data!(tag = nil)
      case tag ||= read_bytes(1).ord
      when 0        then raise PeerError, 'unexpected EoC'
      when 1        then nil
      when 4..12    then read_method(tag)
      when 13       then read_short
      when 14       then read_long
      when 15       then read_bytes(read_short).encode('binary')
      when 16       then read_bytes(read_long).encode('binary')
      when 17..126  then read_bytes(tag - 17).encode('utf-8')
      when 127      then read_bytes(read_long).encode('utf-8')
      else raise NotImplementedError, 'no support'
      end
    end

    def read_method(tag)
      type = tag == 12 ? read_long : tag - 4
      message = Message.new(connection, type)
      while tag = read_short
        break if tag == 0
        message << read_data!(tag)
      end
      message
    end

    def read_bytes!(count)
      result = new_buffer(blocking? ? io.read(count) : io.read_nonblock(count))
      @last_activity = Time.now
      result
    end

    # like read_bytes! but with a buffer
    def read_bytes(count)
      result = new_buffer
      result << read_outstanding(0, count)
      @outstanding = read_outstanding(count..-1)
      result << read_bytes!(count - result.size) until result.size == count
      result
    ensure
      @recent << result
    end

    def read_short
      read_pattern(1, 'c')
    end

    def read_long
      read_pattern(4, 'l>')
    end

    def read_pattern(length, pattern)
      result = read_bytes(length).unpack(pattern)
      return result if result.length != 1
      result.first
    end

    def read_outstanding(*args)
      new_buffer @outstanding[*args]
    end

    def new_buffer(content = "")
      content.to_s.force_encoding('binary')
    end
  end
end
