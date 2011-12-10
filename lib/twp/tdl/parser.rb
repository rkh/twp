# THIS CODE HAS BEEN GENERATED!

require 'kpeg/compiled_parser'

class ::TWP::TDL::Parser < KPeg::CompiledParser

 attr_accessor :ast 


  module ::TWP::TDL
    class Node; end
    class DefinedBy < Node
      def initialize(name)
        @name = name
      end
      attr_reader :name
    end
    class Field < Node
      def initialize(name, type, optional)
        @name = name
        @type = type
        @optional = optional
      end
      attr_reader :name
      attr_reader :type
      attr_reader :optional
    end
    class Message < Node
      def initialize(name, id, fields)
        @name = name
        @id = id
        @fields = fields
      end
      attr_reader :name
      attr_reader :id
      attr_reader :fields
    end
    class PrimitiveType < Node
      def initialize(type)
        @type = type
      end
      attr_reader :type
    end
    class Protocol < Node
      def initialize(name, id, elements)
        @name = name
        @id = id
        @elements = elements
      end
      attr_reader :name
      attr_reader :id
      attr_reader :elements
    end
    class Root < Node
      def initialize(elements)
        @elements = elements
      end
      attr_reader :elements
    end
    class Sequence < Node
      def initialize(name, type)
        @name = name
        @type = type
      end
      attr_reader :name
      attr_reader :type
    end
    class Struct < Node
      def initialize(name, id, fields)
        @name = name
        @id = id
        @fields = fields
      end
      attr_reader :name
      attr_reader :id
      attr_reader :fields
    end
    class Type < Node
      def initialize(name)
        @name = name
      end
      attr_reader :name
    end
  end
  def defined_by(name)
    ::TWP::TDL::DefinedBy.new(name)
  end
  def field(name, type, optional)
    ::TWP::TDL::Field.new(name, type, optional)
  end
  def message(name, id, fields)
    ::TWP::TDL::Message.new(name, id, fields)
  end
  def primitive_type(type)
    ::TWP::TDL::PrimitiveType.new(type)
  end
  def protocol(name, id, elements)
    ::TWP::TDL::Protocol.new(name, id, elements)
  end
  def root(elements)
    ::TWP::TDL::Root.new(elements)
  end
  def sequence(name, type)
    ::TWP::TDL::Sequence.new(name, type)
  end
  def struct(name, id, fields)
    ::TWP::TDL::Struct.new(name, id, fields)
  end
  def type(name)
    ::TWP::TDL::Type.new(name)
  end

  # ALPHA = /[A-Za-z]/
  def _ALPHA
    _tmp = scan(/\A(?-mix:[A-Za-z])/)
    set_failed_rule :_ALPHA unless _tmp
    return _tmp
  end

  # DIGIT = /[0-9]/
  def _DIGIT
    _tmp = scan(/\A(?-mix:[0-9])/)
    set_failed_rule :_DIGIT unless _tmp
    return _tmp
  end

  # LETTER = (ALPHA | "_")
  def _LETTER

    _save = self.pos
    while true # choice
      _tmp = apply(:_ALPHA)
      break if _tmp
      self.pos = _save
      _tmp = match_string("_")
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_LETTER unless _tmp
    return _tmp
  end

  # identifier = < LETTER (LETTER | DIGIT)* > { text }
  def _identifier

    _save = self.pos
    while true # sequence
      _text_start = self.pos

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:_LETTER)
        unless _tmp
          self.pos = _save1
          break
        end
        while true

          _save3 = self.pos
          while true # choice
            _tmp = apply(:_LETTER)
            break if _tmp
            self.pos = _save3
            _tmp = apply(:_DIGIT)
            break if _tmp
            self.pos = _save3
            break
          end # end choice

          break unless _tmp
        end
        _tmp = true
        unless _tmp
          self.pos = _save1
        end
        break
      end # end sequence

      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  text ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_identifier unless _tmp
    return _tmp
  end

  # number = < DIGIT* > { Integer text }
  def _number

    _save = self.pos
    while true # sequence
      _text_start = self.pos
      while true
        _tmp = apply(:_DIGIT)
        break unless _tmp
      end
      _tmp = true
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  Integer text ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_number unless _tmp
    return _tmp
  end

  # - = /\s*(\/\*.*\*\/)?\s*/
  def __hyphen_
    _tmp = scan(/\A(?-mix:\s*(\/\*.*\*\/)?\s*)/)
    set_failed_rule :__hyphen_ unless _tmp
    return _tmp
  end

  # type = ("any" - "defined" - "by" - identifier:name {defined_by(name)} | - primitiveType:type - {primitive_type(type)} | - identifier:type - {type(type)})
  def _type

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = match_string("any")
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = match_string("defined")
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = match_string("by")
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_identifier)
        name = @result
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin; defined_by(name); end
        _tmp = true
        unless _tmp
          self.pos = _save1
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save2 = self.pos
      while true # sequence
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:_primitiveType)
        type = @result
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save2
          break
        end
        @result = begin; primitive_type(type); end
        _tmp = true
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save3 = self.pos
      while true # sequence
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save3
          break
        end
        _tmp = apply(:_identifier)
        type = @result
        unless _tmp
          self.pos = _save3
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save3
          break
        end
        @result = begin; type(type); end
        _tmp = true
        unless _tmp
          self.pos = _save3
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_type unless _tmp
    return _tmp
  end

  # primitiveType = < ("int" | "string" | "binary" | "any") > {text}
  def _primitiveType

    _save = self.pos
    while true # sequence
      _text_start = self.pos

      _save1 = self.pos
      while true # choice
        _tmp = match_string("int")
        break if _tmp
        self.pos = _save1
        _tmp = match_string("string")
        break if _tmp
        self.pos = _save1
        _tmp = match_string("binary")
        break if _tmp
        self.pos = _save1
        _tmp = match_string("any")
        break if _tmp
        self.pos = _save1
        break
      end # end choice

      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; text; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_primitiveType unless _tmp
    return _tmp
  end

  # typedef = (structdef | sequencedef | uniondef | forwarddef)
  def _typedef

    _save = self.pos
    while true # choice
      _tmp = apply(:_structdef)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_sequencedef)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_uniondef)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_forwarddef)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_typedef unless _tmp
    return _tmp
  end

  # structdef = - "struct" - identifier:name - ("=" - "ID" - number:id -)? "{" - field+:fields - "}" - {struct(name, id, fields)}
  def _structdef

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("struct")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _save1 = self.pos

      _save2 = self.pos
      while true # sequence
        _tmp = match_string("=")
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = match_string("ID")
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:_number)
        id = @result
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      unless _tmp
        _tmp = true
        self.pos = _save1
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("{")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _save3 = self.pos
      _ary = []
      _tmp = apply(:_field)
      if _tmp
        _ary << @result
        while true
          _tmp = apply(:_field)
          _ary << @result if _tmp
          break unless _tmp
        end
        _tmp = true
        @result = _ary
      else
        self.pos = _save3
      end
      fields = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("}")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; struct(name, id, fields); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_structdef unless _tmp
    return _tmp
  end

  # field = - < "optional"? > - type:type - identifier:name - ";" - {field(name, type, text == "optional")}
  def _field

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      _save1 = self.pos
      _tmp = match_string("optional")
      unless _tmp
        _tmp = true
        self.pos = _save1
      end
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_type)
      type = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string(";")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; field(name, type, text == "optional"); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_field unless _tmp
    return _tmp
  end

  # sequencedef = - "sequence" - "<" - type:type - ">" - identifier:name - ";" - {sequence(name, type)}
  def _sequencedef

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("sequence")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("<")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_type)
      type = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string(">")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string(";")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; sequence(name, type); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_sequencedef unless _tmp
    return _tmp
  end

  # uniondef = - "union" - identifier:name - "{" - casedef+:cases - "}" - {union(name, cases)}
  def _uniondef

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("union")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("{")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _save1 = self.pos
      _ary = []
      _tmp = apply(:_casedef)
      if _tmp
        _ary << @result
        while true
          _tmp = apply(:_casedef)
          _ary << @result if _tmp
          break unless _tmp
        end
        _tmp = true
        @result = _ary
      else
        self.pos = _save1
      end
      cases = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("}")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; union(name, cases); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_uniondef unless _tmp
    return _tmp
  end

  # casedef = - "case" - number:id - ":" - type:type - identifier:name - ";" - {casedef(id, type, name)}
  def _casedef

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("case")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_number)
      id = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string(":")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_type)
      type = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string(";")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; casedef(id, type, name); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_casedef unless _tmp
    return _tmp
  end

  # forwarddef = - "typedef" - identifier:name - ";" - {typedef(name)}
  def _forwarddef

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("typedef")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string(";")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; typedef(name); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_forwarddef unless _tmp
    return _tmp
  end

  # messagedef = - "message" - identifier:name - "=" - (number | "ID" - number):id - "{" - field*:fields - "}" - {message(name, id, fields)}
  def _messagedef

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("message")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("=")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end

      _save1 = self.pos
      while true # choice
        _tmp = apply(:_number)
        break if _tmp
        self.pos = _save1

        _save2 = self.pos
        while true # sequence
          _tmp = match_string("ID")
          unless _tmp
            self.pos = _save2
            break
          end
          _tmp = apply(:__hyphen_)
          unless _tmp
            self.pos = _save2
            break
          end
          _tmp = apply(:_number)
          unless _tmp
            self.pos = _save2
          end
          break
        end # end sequence

        break if _tmp
        self.pos = _save1
        break
      end # end choice

      id = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("{")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _ary = []
      while true
        _tmp = apply(:_field)
        _ary << @result if _tmp
        break unless _tmp
      end
      _tmp = true
      @result = _ary
      fields = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("}")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; message(name, id, fields); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_messagedef unless _tmp
    return _tmp
  end

  # protocol = - "protocol" - identifier:name - "=" - "ID" - number:id - "{" - protocolelement+:elements - "}" - {protocol(name, id, elements)}
  def _protocol

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("protocol")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_identifier)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("=")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("ID")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_number)
      id = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("{")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _save1 = self.pos
      _ary = []
      _tmp = apply(:_protocolelement)
      if _tmp
        _ary << @result
        while true
          _tmp = apply(:_protocolelement)
          _ary << @result if _tmp
          break unless _tmp
        end
        _tmp = true
        @result = _ary
      else
        self.pos = _save1
      end
      elements = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("}")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; protocol(name, id, elements); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_protocol unless _tmp
    return _tmp
  end

  # protocolelement = (typedef | messagedef)
  def _protocolelement

    _save = self.pos
    while true # choice
      _tmp = apply(:_typedef)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_messagedef)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_protocolelement unless _tmp
    return _tmp
  end

  # root = (protocol | messagedef | structdef)+:elements { @ast = root(elements) }
  def _root

    _save = self.pos
    while true # sequence
      _save1 = self.pos
      _ary = []

      _save2 = self.pos
      while true # choice
        _tmp = apply(:_protocol)
        break if _tmp
        self.pos = _save2
        _tmp = apply(:_messagedef)
        break if _tmp
        self.pos = _save2
        _tmp = apply(:_structdef)
        break if _tmp
        self.pos = _save2
        break
      end # end choice

      if _tmp
        _ary << @result
        while true

          _save3 = self.pos
          while true # choice
            _tmp = apply(:_protocol)
            break if _tmp
            self.pos = _save3
            _tmp = apply(:_messagedef)
            break if _tmp
            self.pos = _save3
            _tmp = apply(:_structdef)
            break if _tmp
            self.pos = _save3
            break
          end # end choice

          _ary << @result if _tmp
          break unless _tmp
        end
        _tmp = true
        @result = _ary
      else
        self.pos = _save1
      end
      elements = @result
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  @ast = root(elements) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_root unless _tmp
    return _tmp
  end

  Rules = {}
  Rules[:_ALPHA] = rule_info("ALPHA", "/[A-Za-z]/")
  Rules[:_DIGIT] = rule_info("DIGIT", "/[0-9]/")
  Rules[:_LETTER] = rule_info("LETTER", "(ALPHA | \"_\")")
  Rules[:_identifier] = rule_info("identifier", "< LETTER (LETTER | DIGIT)* > { text }")
  Rules[:_number] = rule_info("number", "< DIGIT* > { Integer text }")
  Rules[:__hyphen_] = rule_info("-", "/\\s*(\\/\\*.*\\*\\/)?\\s*/")
  Rules[:_type] = rule_info("type", "(\"any\" - \"defined\" - \"by\" - identifier:name {defined_by(name)} | - primitiveType:type - {primitive_type(type)} | - identifier:type - {type(type)})")
  Rules[:_primitiveType] = rule_info("primitiveType", "< (\"int\" | \"string\" | \"binary\" | \"any\") > {text}")
  Rules[:_typedef] = rule_info("typedef", "(structdef | sequencedef | uniondef | forwarddef)")
  Rules[:_structdef] = rule_info("structdef", "- \"struct\" - identifier:name - (\"=\" - \"ID\" - number:id -)? \"{\" - field+:fields - \"}\" - {struct(name, id, fields)}")
  Rules[:_field] = rule_info("field", "- < \"optional\"? > - type:type - identifier:name - \";\" - {field(name, type, text == \"optional\")}")
  Rules[:_sequencedef] = rule_info("sequencedef", "- \"sequence\" - \"<\" - type:type - \">\" - identifier:name - \";\" - {sequence(name, type)}")
  Rules[:_uniondef] = rule_info("uniondef", "- \"union\" - identifier:name - \"{\" - casedef+:cases - \"}\" - {union(name, cases)}")
  Rules[:_casedef] = rule_info("casedef", "- \"case\" - number:id - \":\" - type:type - identifier:name - \";\" - {casedef(id, type, name)}")
  Rules[:_forwarddef] = rule_info("forwarddef", "- \"typedef\" - identifier:name - \";\" - {typedef(name)}")
  Rules[:_messagedef] = rule_info("messagedef", "- \"message\" - identifier:name - \"=\" - (number | \"ID\" - number):id - \"{\" - field*:fields - \"}\" - {message(name, id, fields)}")
  Rules[:_protocol] = rule_info("protocol", "- \"protocol\" - identifier:name - \"=\" - \"ID\" - number:id - \"{\" - protocolelement+:elements - \"}\" - {protocol(name, id, elements)}")
  Rules[:_protocolelement] = rule_info("protocolelement", "(typedef | messagedef)")
  Rules[:_root] = rule_info("root", "(protocol | messagedef | structdef)+:elements { @ast = root(elements) }")
end
