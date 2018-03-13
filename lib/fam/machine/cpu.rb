require_relative 'memory'
require_relative '../syntax/ast'

module FAM::Machine
  class CPU
    include FAM::Syntax

    def initialize ram
      @ram = ram
      @registers = {
        :ACC => 0,
        :DAT => 0
      }
      @memory_aliases = Hash.new

      @labels = Hash.new
      @last_jump = nil
      @back_index = 0
    end

    def self.quick_run ram, parsed
      cpu = self.new ram
      cpu.execute parsed
      cpu
    end

    def run parsed
      @parsed = parsed

      @tree_index = -1
      while @tree_index < parsed.tree.size
        @tree_index += 1

        sleep 1.0 / $CLOCK
        node = parsed[@tree_index]
        status = execute node
        break if status == :STOP
        next  if status == :SKIP
        puts "\n  _BACK: #{parsed[@back_index].inspect}\n " if $VERBOSE
        display if $VERBOSE
      end
    end

    def execute node
      case node
      when AST::LabelNode
        @last_jump = node.label
        @labels[node.label] = @tree_index
        @back_index = @tree_index
      when AST::HaltNode
        return :STOP
      when AST::GotoNode
        back = @tree_index
        if @labels.include? node.ident.name
          @tree_index = @labels[node.ident.name]
        elsif node.ident.name == '_BACK'
          @tree_index = @back_index
          return :PASS
        else  # Search ahead
          found = false
          @parsed.tree.each.with_index do |top_node, i|
            @tree_index = i
            if top_node.base_name == 'LabelNode'
              (found = true; break) if top_node.label == node.ident.name
            end
          end
          abort "Label: `#{node.label.name}` was not found. Execution HALTED!".red.bold unless found
        end
        @last_jump = node.ident.name
        @back_index = back
      when AST::StoreNode
        mem_index = case node.to
        when AST::AddressNode
          node.to.address
        when AST::IdentNode
          @memory_aliases[node.to.name]
        end
        @ram[mem_index] = get_value node, node.value
      when AST::LoadNode
        @registers[node.register.register.to_sym] = get_value node, node.value
      when AST::DataNode
        initial_value = get_value node, node.initial
        free_index = nil
        @ram.array.each.with_index { |value, i| if value == NULL then free_index = i; break; end }
        abort ("No free memory, allocation of `#{node.name.name}`,\n" +
        "cannot happen! Execution HALTED!").red.bold if free_index.nil?
        @memory_aliases[node.name.name] = free_index
        @ram[free_index] = initial_value
      when AST::InNode
        @registers[node.register.register.to_sym] = cpu_input
      when AST::OutNode, AST::AsciiNode
        value = get_value node, node.value
        cpu_output value, (node.base_name == 'OutNode' ? :PLAIN : :ASCII)
      when AST::SubNode, AST::AddNode, AST::MulNode, AST::DivNode, AST::ModNode
        value = get_value node, node.value
        ExpectedNode 'REGISTER', node.to unless node.to.base_name == 'RegisterNode'
        if node.base_name[/Sub|Add/]
          @registers[node.to.register.to_sym] += value * (node.base_name == 'AddNode' ? 1 : -1)
        elsif node.base_name == 'Mul'
          @registers[node.to.register.to_sym] *= value
        elsif node.base_name == 'Div'
          @registers[node.to.register.to_sym] /= value
        else
          @registers[node.to.register.to_sym] %= value
        end
      when AST::EqualNode, AST::MoreNode, AST::LessNode
        left  = get_value node, node.left
        right = get_value node, node.right
        if node.base_name == 'EqualNode' ? (left == right) : (node.base_name == 'MoreNode' ? (left > right) : (left < right))
          execute node.valid
        else
          execute node.invalid
        end
      else
        print "\n" * (@ram.to_s.count("\n") + 1) if $VERBOSE
        abort ("Unknown Node: `#{node.base_name}`,\nparser generated an " +
        "unexecutable/unknown node... Execution HALTED!").red.bold
      end
      return :PASS
    end

    def display
      puts "#{@ram.to_s}"
      puts
      @registers.each { |key, value| print "#{key} => #{value}\n" }
      puts
      # print "\033[F" * (self.to_s.count("\n"))
      # print "\n" * (@ram.to_s.count("\n") + 1)
    end

    def cpu_input  # Ment to be changed
      print 'INPUT: '
      $stdin.gets.to_i
    end

    def cpu_output out, ascii=:PLAIN  # Ment to be changed
      puts "OUTPUT: #{ascii != :PLAIN ? out.chr : out }"
    end

    private def get_value super_value, value_node
      case value_node
      when AST::NumericNode
        value_node.numeric
      when AST::AddressNode
        @ram[value_node.address]
      when AST::RegisterNode
        @registers[value_node.register.to_sym]
      when AST::IdentNode
        @ram[@memory_aliases[value_node.name]]
      else
        AST::UnexpectedNode super_value, value_node
      end
    end

    private def UnexpectedNode node, sub_node
      print "\n" * (@ram.to_s.count("\n") + 1) if $VERBOSE
      abort ("Unexpected Node, you've given `#{sub_node.base_name}` AST::to Node: `#{node.base_name}`?").red.bold
    end

    private def ExpectedNode expect, got
      print "\n" * (@ram.to_s.count("\n") + 1) if $VERBOSE
      abort ("Expected: `#{expect}`, but insted got: `#{got}`").red.bold
    end
  end
end
