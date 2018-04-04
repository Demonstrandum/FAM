require_relative 'tokens'

module FAM::Syntax
  class Lexer
    attr_reader :tokens

    def initialize string
      @raw = string
      @tokens = TokenStream.new
    end

    def self.lex string
      obj = self.new string
      obj.lexer
      obj
    end

    def lexer
      puts "Lexing..." if $VERBOSE
      @raw << EOF unless @raw[-1] == EOF

      loc = {:line => 1, :col => 1}
      i = 0
      while i < @raw.size
        unread = @raw[i..-1]

        if ["\n", ";"].include? unread[0]
          loc[:line] += 1
          loc[:col] = 1
          @tokens << tokenize(unread[0], :TERMINATOR, loc)
          i += 1

        elsif unread[0] == ' '
          loc[:col] += 1
          i += 1

        elsif unread[/\A{{/, 0] || unread[/\A!/, 0]
          comment = unread[/\A{{/, 0] || unread[/\A!/, 0]
          comment_start = loc.clone
          j = 0
          if comment == '!'
            until unread[j] == "\n" || unread[j] == EOF
              i += 1
              j += 1
            end
            j -= 1
          else
            until unread[j..j+1] == '}}' || unread[j] == EOF
              i += 1
              loc[:col] += 1
              if unread[j] == "\n"
                loc[:line] += 1
                loc[:col] = 1
              end
              j += 1
            end
            j += 1
          end
          @tokens << tokenize(unread[0..j], :COMMENT, comment_start)

        elsif label = unread[/\A[a-zA-Z_]([a-zA-Z0-9_]+)?:/, 0]
          @tokens << tokenize(label, :LABEL, loc)
          loc[:col] += label.size
          i += label.size

        elsif numeric = unread[/\A(\-|\+)??((?=0x|0b)([0-9A-Za-z]+)|([0-9]+((e(\-|\+)?[0-9]+)?)))/, 0]
          @tokens << tokenize(numeric, :NUMERIC, loc)
          loc[:col] += numeric.size
          i += numeric.size

        elsif address = unread[/\A@[0-9]+/, 0]
          @tokens << tokenize(address, :ADDRESS, loc)
          loc[:col] += address.size
          i += address.size

        elsif register = unread[/\A&[a-zA-Z0-9]+/, 0]
          @tokens << tokenize(register, :REGISTER, loc)
          loc[:col] += register.size
          i += register.size

        elsif ident = unread[/\A[A-Za-z_]([A-Za-z0-9_]+)?/, 0]
          if Tokens::OPCODES.include? ident
            @tokens << tokenize(ident, :OPCODE, loc)
          else
            @tokens << tokenize(ident, :IDENT, loc)
          end

          loc[:col] += ident.size
          i += ident.size


        elsif op = unread[/\A[(\+)(\-)(\:)(\|)]/, 0]
          @tokens << tokenize(op, :OPERATOR, loc)
          loc[:col] += op.size
          i += op.size

        else
          i += 1
          loc[:col] += 1
        end

      end

      @tokens
    end

    private def tokenize name, type, location={:line => 'IMPLICIT TOKEN', :col => 'IMPLICIT TOKEN'}
      TokenObject.new type, name, location
    end

    def to_s
      result = "LEXED TOKENS:\n"
      @tokens.tokens.each do |token|
        widest = @tokens.tokens.map(&:type).max
        result << "  :#{token.type}#{' ' * (widest.size - token.type.size)} :: " +
        "[#{token.line.to_s.rjust 3}:#{token.col.to_s.ljust 3}] " +
        "{ #{token.name.inspect.size > 10 ? (token.name[0..7] + '...').inspect : token.name.inspect} }\n"
      end
      result
    end
  end
end
