module TWP
  class Message
    attr_reader :connection, :field_values

    def initialize(connection, id_or_type, *fields)
      @connection, @field_values = connection, fields
      @type   = connection.messages[id_or_type] if Symbol === id_or_type
      @type ||= connection.messages.values.detect { |m| m.id == id_or_type }

      if @type.nil?
        messages = connection.messages.map { |k,v| "%p(%p)" % [k,v.id] }
        raise PeerError, "unkown message type %p (I do know #{messages.join ", "})" % id_or_type
      end
    end

    def fields
      Hash[field_names.zip(field_values)]
    end

    def <<(value)
      @field_values << value
    end

    def name
      @type.name.to_sym
    end

    def id
      @type.id
    end

    def field_names
      @field_names ||= @type.fields.map(&:name).map(&:to_sym)
    end

    def [](index)
      field_values[indexify(index)]
    end

    def []=(index, value)
      field_values[indexify(index)] = value
    end


    def inspect
      "#<#{self.class}: %p(%p) %p>" % [name, id, fields]
    end

    def respond_to_missing?(name, *)
      return true if field_names.include? name
      name.to_s.end_with? '=' and field_values.include? name.to_s[0..-2].to_sym
    end

    def method_missing(name, *args)
      if name.to_s.end_with? '=' and field_values.include? name.to_s[0..-2].to_sym
        self[name.to_s[0..-2]] = args.first
      elsif field_names.include? name
        raise ArgumentError, "wrong number of arguments (#{args.count} for 0)" if args.any?
        self[name]
      else
        super
      end
    end

    private

    def indexify(index)
      return index if Integer === index
      field_names.index(index.to_sym)
    end
  end
end
