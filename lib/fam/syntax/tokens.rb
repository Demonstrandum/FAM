EOF = "\0"

module FAM::Syntax
  class TokenStream
    attr_accessor :tokens
    attr_accessor :index

    def initialize
      @tokens = []
      @index = 0
    end

    def <<(token)
      @tokens << token
    end

    def [](i)
      @tokens[i]
    end

    def current
      @tokens[@index]
    end

    def next
      @index += 1
      @tokens[@index]
    end

    def back
      @index -= 1
      @tokens[@index]
    end

    def peek i=1
      @tokens[i + @index]
    end

    def previous i=1
      @tokens[@index - i]
    end

    def to_s
      @tokens.to_s
    end
  end

  class TokenObject
    attr_reader :type, :name, :line, :col

    def initialize type, name, location
      @type = type
      @name = name
      @line = location[:line]
      @col  = location[:col]
    end

    def to_s
      value = @name == "\n" ? '\n' : @name
      "TOKEN<:#{@type}>(`#{value}`)"
    end

    alias :pretty_inspect :to_s
  end

  module Tokens
    TYPES = [
      :OPCODE,
      :OPERAND,
      :NUMERTIC,
      :REGISTER,
      :ADDRESS,
      :LABEL,
      :IDENT
    ].map(&:to_s)

    OPERATORS = [
      :'+',
      :'-',
      :'|',
      :':'
    ].map(&:to_s)

    OPCODES = [
      :HALT,
      :ALIAS,
      :DATA,
      :STORE,
      :LOAD,
      :GOTO,
      :DATA,
      :EQUAL,
      :MORE,
      :LESS,
      :ADD,
      :SUB,
      :MUL,
      :DIV,
      :MOD,
      :SLEEP,
      :IN,
      :OUT,
      :ASCII
    ].map(&:to_s)
  end
end
