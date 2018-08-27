require_relative 'ast'
require_relative 'lexer'

module FAM::Syntax
  class Parser < Lexer
    include AST
    attr_reader :ast

    def initialize token_stream
      @tokens = token_stream
      @ast = SyntaxTree.new
    end

    def self.parse stream
      obj = self.new stream
      obj.parser
      obj
    end

    def parser
      @tokens.tokens.each do |t|
        break if @tokens.current.nil?
        puts "Parsing: (#{@tokens.current.to_s.brown})" if $VERBOSE
        node = parse_token @tokens.current
        puts "Parsed to: (#{node.nil? ? 'NOT PARSED'.red : node.to_s.gray})" if $VERBOSE
        @ast << node unless node.nil?
        @tokens.next
        puts if $VERBOSE
      end
    end

    def parse_token t
      case t.type
      when :LABEL
        return LabelNode.new @tokens.current
      when :OPCODE
        case t.name
        when 'HALT'
          exit_status = NumericNode.new tokenize('0000', :NUMERIC)
          exit_status = parse_token @tokens.next if @tokens.peek.type == @NUMERIC
          return HaltNode.new exit_status
        when 'GOTO'
          label = parse_token @tokens.next
          UnexpectedToken @tokens.current unless @tokens.current.type == :IDENT
          return GotoNode.new label
        when 'STORE'
          value = parse_token @tokens.next
          @tokens.next
          ExpectedToken 'TOKEN<:OPERATOR>(`:`)', @tokens.current unless @tokens.current.name == ':'
          to = parse_token @tokens.next
          ExpectedToken 'ADDRESS or IDENT', @tokens.current unless @tokens.current.type == :ADDRESS || @tokens.current.type == :IDENT
          return StoreNode.new value, to
        when 'LOAD'
          value = parse_token @tokens.next
          @tokens.next
          ExpectedToken 'TOKEN<:OPERATOR>(`:`)', @tokens.current unless @tokens.current.name == ':'
          reg = parse_token @tokens.next
          ExpectedToken 'REGISTER', @tokens.current unless @tokens.current.type == :REGISTER
          return LoadNode.new value, reg
        when 'DATA'
          name = parse_token @tokens.next
          UnexpectedValue name unless @tokens.current.type == :IDENT
          if @tokens.peek.name == ':'
            @tokens.next
            value = parse_token @tokens.next
          else
            value = NumericNode.new tokenize('0000', :NUMERIC)
          end
          return DataNode.new name, value
        when 'ADD', 'SUB', 'MUL', 'DIV', 'MOD'
          value = parse_token @tokens.next
          @tokens.next
          ExpectedToken 'TOKEN<:OPERATOR>(`:`)', @tokens.current unless @tokens.current.name == ':'
          to = parse_token @tokens.next

          return case t.name
          when 'ADD'
            AddNode.new value, to
          when 'SUB'
            SubNode.new value, to
          when 'MUL'
            MulNode.new value, to
          when 'DIV'
            DivNode.new value, to
          when 'MOD'
            ModNode.new value, to
          end
        when 'EQUAL', 'MORE', 'LESS'
          parse_condition
        when 'IN'
          reg = parse_token @tokens.next
          ExpectedToken 'TOKEN<:REGISTER>', @tokens.current unless @tokens.current.type == :REGISTER
          return InNode.new reg
        when 'OUT', 'ASCII'
          value = parse_token @tokens.next
          if t.name == 'OUT'
            return OutNode.new value
          else
            return AsciiNode.new value
          end
        else
          abort "Unknown/unparsable OPCODE: `#{t.name}` at [#{t.line}:#{t.col}]!".red.bold
        end
      when :ADDRESS
        return AddressNode.new @tokens.current
      when :NUMERIC
        return NumericNode.new @tokens.current
      when :REGISTER
        return RegisterNode.new @tokens.current
      when :IDENT
        return IdentNode.new @tokens.current
      else
        return nil
      end
    end

    private def parse_condition
      condition_type = @tokens.current.name
      left  = parse_token @tokens.next
      @tokens.next
      ExpectedToken 'TOKEN<:OPERATOR>(`:`)', @tokens.current unless @tokens.current.name == ':'
      right = parse_token @tokens.next

      @tokens.next until @tokens.current.name == '|'
      valid = parse_token @tokens.next
      @tokens.next until @tokens.current.name == '|'
      invalid = parse_token @tokens.next

      params = [left, right, valid, invalid]
      case condition_type
      when 'EQUAL'
        EqualNode.new(*params)
      when 'MORE'
        MoreNode.new(*params)
      when 'LESS'
        LessNode.new(*params)
      end
    end
  end
end
