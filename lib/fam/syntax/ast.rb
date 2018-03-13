module FAM::Syntax::AST
  class Node
    def to_s
      "<#{self.class.name.split('Node')[0]} :: NODE>"
    end
  end

  class SyntaxTree
    attr_reader :tree

    def initialize
      @tree = []
    end

    def <<(node)
      @tree << node
    end

    def [](i)
      @tree[i]
    end
  end

  class LabelNode < Node
    attr_accessor :label
    def initialize label
      @label = label.name[0..-2]
    end
  end

  class GotoNode < Node
    attr_accessor :ident
    def initialize ident
      @ident = ident
    end
  end

  class HaltNode < Node
    attr_accessor :status
    def initialize status
      @status = status
    end
  end

  class StoreNode < Node
    attr_accessor :value, :to
    def initialize value, to
      @value = value
      @to = to
    end
  end

  class LoadNode < Node
    attr_accessor :value, :register
    def initialize value, register
      @value = value
      @register = register
    end
  end

  class DataNode < Node
    attr_accessor :name, :initial
    def initialize name, initial
      @name = name
      @initial = initial
    end
  end

  class InNode < Node
    attr_accessor :register
    def initialize reg
      @register = reg
    end
  end

  class OutputNode < Node
    attr_accessor :value
    def initialize value
      @value = value
    end
  end

  class OutNode   < OutputNode; end
  class AsciiNode < OutputNode; end

  class ArithmeticNode < Node
    attr_accessor :value, :to
    def initialize value, to
      @value = value
      @to = to
    end
  end

  class AddNode < ArithmeticNode; end
  class SubNode < ArithmeticNode; end
  class MulNode < ArithmeticNode; end
  class DivNode < ArithmeticNode; end
  class ModNode < ArithmeticNode; end

  class ConditionNode < Node
    attr_accessor :left, :right, :valid, :invalid
    def initialize left, right, valid, invalid
      @left  = left
      @right = right
      @valid = valid
      @invalid = invalid
    end
  end

  class EqualNode < ConditionNode; end
  class MoreNode  < ConditionNode; end
  class LessNode  < ConditionNode; end

  class IdentNode
    attr_accessor :name
    def initialize name
      @name = name.name
    end
  end

  class AddressNode < Node
    attr_accessor :address
    def initialize address
      @address = address.name[1..-1].to_i
    end
  end

  class NumericNode < Node
    attr_accessor :numeric
    def initialize numeric
      @numeric = Integer numeric.name
    end
  end

  class RegisterNode < Node
    attr_accessor :register
    def initialize register
      @register = register.name[1..-1]
    end
  end
end
