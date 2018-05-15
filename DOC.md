# Documentation
> Documentation, quite incomplete

## Basic Syntax
The syntax is extremely simplistic.

The language consists mostly of labels, opcodes and operands.

### Identifiers
Identifiers are just names for things, such as variables, labels, etc.

They may consist of any number of underscores (`_`) anywhere in the name and any number of Latin alphabet letters. Numbers may only exist in identifiers only if preceded by one or more letters or underscores.

Identifiers have the following regular expression:

`[A-Za-z_]([A-Za-z0-9_]+)?`

### Labels
A label is defined by an identifier (a name) immediately followed by a colon, e.g.
```nasm
LABEL_NAME:
    !! Code goes here.
    !! ...
```
A label if not jumped to by a `GOTO`, will be entered automatically, when that happens the special `_BACK` ident will be set to that label.

Labels are defined as: `[a-zA-Z_]([a-zA-Z0-9_]+)?:`

### Comments
Single-line comments must start with an `!` (although it looks neater using a double exclamation-mark: `!!`), and are ended, naturally, by a new line.

e.g.
```nasm
    SUB   4 : &ACC  !! Hi, I'm a comment
    MOD 265 : &ACC
```

Multi-line comments start by a `{{` and are ended by a `}}`.

e.g.
```nasm
  DATA x : -0xff
  {{ I can be one line }}

  {{
      Here, multiple lines
      are commented out.
  }}
```

### Numerics
Numerics must always start with wither a number, or a sign (`+`/`-`). Hexadecimal and duodecimal (binary) support also exists; this is achieved by prepending a `0x` (hexadecimal) or `0b` (binary) prefix to the number.

Normal base-10 numbers can have an `e` (scientific notation for 10 to the power of some number).

Numbers can be defined through the regular expression:
```
(\-|\+)??((?=0x|0b)([0-9A-Za-z]+)|([0-9]+((e(\-|\+)?[0-9]+)?)))
```

Some examples of numbers:
```
!! Scientific notation
12e1      !! becomes 120
12e+1     !! becomes 120
-23e+3    !! becomes -23000
5000e-3   !! becomes 5

!! Hexadecimal
0xff4a    !! becomes 65354
-0xff4a   !! becomes -65354

!! Binary
0xb010110 !! becomes 184615184
-0b101    !! becomes -5
```

### Registers
Registers in the language, are names for the registers in the CPU. Registers must start with an `&` followed my any combination of lower and uppercase Latin letters, and digits.

Regular expression: `&[a-zA-Z0-9]+`

### Addresses
Addresses address locations in memory, these address numbers range from `0` to your chosen allocated amount, minus one.

Regular expression: `@[0-9]+`

### Opcodes
#### `:HALT`
#### `:ALIAS`
  **Not implemented.**
#### `:DATA`
#### `:STORE`
#### `:LOAD`
#### `:GOTO`
#### `:DATA`
#### `:EQUAL`
#### `:MORE`
#### `:LESS`
#### `:ADD`
#### `:SUB`
#### `:MUL`
#### `:DIV`
#### `:MOD`
#### `:SLEEP`
  **Not implemented.**
#### `:IN`
#### `:OUT`
#### `:ASCII`
