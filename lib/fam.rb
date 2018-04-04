class Object
  def base_name
    self.class.name.split(/(\:\:)|(\.)/)[-1]
  end
end

module FAM
  VERSIONS = { :major => 0, :minor => 1, :tiny => 0 }

  def self.version *args
    VERSIONS.flatten.select.with_index { |val, i| i.odd? }.join '.'
  end
end

Dir["#{File.dirname __FILE__}/fam/*.rb"].each    { |f| require f }
Dir["#{File.dirname __FILE__}/fam/**/*.rb"].each { |f| require f }

module FAM
  def self.run string, allocate: '200B', clock: 6, verbose: false, &block
    $VERBOSE = verbose
    $CLOCK = clock

    lexed = Syntax::Lexer.lex string
    puts lexed if $VERBOSE
    puts if $VERBOSE
    parsed = Syntax::Parser.parse lexed.tokens
    tree = parsed.ast
    pp tree if $VERBOSE
    ram = Machine::RAM.new allocate
    cpu = Machine::CPU.new ram
    puts if $VERBOSE
    cpu.run tree do |pc|
      puts "Program counter: #{pc}" if $VERBOSE
      yield cpu.ram, pc, cpu.registers if block_given?
    end
    cpu
  end
end
