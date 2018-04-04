# FAM
> A very **<u>F</u>ake** **<u>A</u>ssembly**(_-ish_ language) **<u>M</u>achine**, parser and _interpreter_.

## Installation
```shell
gem install fam
```
## Documentation
See this repository's `DOC.md` file.

## Examples
Examples can be found in scarce supply, in the `example` folder in this repository.

Some examples:
```nasm
    STORE 55 : @0
    DATA dyn : 0b01101  !! Dynamic memory allocation,
    LOAD -0xf : &DAT    !! finds available memory location.
    LOAD &DAT : &ACC

LOOP:
    ADD 1 : &ACC
    OUT &ACC
    STORE &ACC : dyn

    EQUAL &ACC : 30
        | GOTO END
        | GOTO LOOP

END: HALT 0
```
```nasm
    GOTO INCR
    OUT &ACC
    HALT 0

INCR:
    ADD 1 : &ACC
    GOTO _BACK

{{  _BACK works by jumping to just after the last GOTO
    statement, or jumping to the last label that was passed
    without GOTOing to it.  }}
```

## Usage
Current terminal usage is very simplistic.
Simply, write `fam` and the file name _ensuring_ the file name ends in `.fam`.

e.g.
```shell
fam some_file.fam
```
by default, the program is extremely verbose.
To make any changes it is recommended you write a Ruby script to deal with it yourself.

e.g.
```ruby
program = <<EOF
  IN  &DAT
  ADD 10 : &DAT
  OUT &DAT

  HALT 0
EOF

# PROGRAM STRING, ALLOC, CLOCK, VERBOSE?
# All except the `program string' are optional,
#   block is not required either.
FAM.run program, '200B', 6, true do |ram, pc, regs|
  puts "RAM:\n#{ram.to_a}"
  puts "REGISTERS:"
  regs.each { |name, value| puts "#{name} => #{value}" }

  puts "PROGRAM COUNTER: #{pc}"
end
```
in a more verbose manner:
```ruby
require 'fam'

$VERBOSE = true
$CLOCK = $VERBOSE ? 20 : Float::INFINITY

file_names = ARGV.select { |file| file.include? '.fam'}
lexed = FAM::Syntax::Lexer.lex File.read file_names[-1]

parsed = FAM::Syntax::Parser.parse lexed.tokens
AST = parsed.ast

MEM = FAM::Machine::RAM.new '100B'  # Alloc 100 bytes
CPU = FAM::Machine::CPU.new MEM

CPU.run AST do |pc|
  # Do something every `clock-cycle'
  puts "Program counter: #{pc}"
end
```
A `#step(syntax_tree)` method is also available for the CPU class.

for auto-generated documentation, see: [rubydoc.info/gems/fam/](http://www.rubydoc.info/gems/fam/FAM/Machine/CPU)
