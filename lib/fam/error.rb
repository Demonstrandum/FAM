class String
  def black;   "\e[30m#{self}\e[0m"; end
  def red;     "\e[31m#{self}\e[0m"; end
  def green;   "\e[32m#{self}\e[0m"; end
  def brown;   "\e[33m#{self}\e[0m"; end
  def blue;    "\e[34m#{self}\e[0m"; end
  def magenta; "\e[35m#{self}\e[0m"; end
  def cyan;    "\e[36m#{self}\e[0m"; end
  def gray;    "\e[37m#{self}\e[0m"; end

  def bg_black;   "\e[40m#{self}\e[0m"; end
  def bg_red;     "\e[41m#{self}\e[0m"; end
  def bg_green;   "\e[42m#{self}\e[0m"; end
  def bg_brown;   "\e[43m#{self}\e[0m"; end
  def bg_blue;    "\e[44m#{self}\e[0m"; end
  def bg_magenta; "\e[45m#{self}\e[0m"; end
  def bg_cyan;    "\e[46m#{self}\e[0m"; end
  def bg_gray;    "\e[47m#{self}\e[0m"; end

  def bold;          "\e[1m#{self}\e[22m"; end
  def italic;        "\e[3m#{self}\e[23m"; end
  def underline;     "\e[4m#{self}\e[24m"; end
  def blink;         "\e[5m#{self}\e[25m"; end
  def reverse_color; "\e[7m#{self}\e[27m"; end
end

def UnexpectedToken token
   puts "\nUnexpected token type: '#{token.type}', at line: #{token.line}:#{token.col}".red.bold
   exit 1
end

def ExpectedToken name, token
   puts "\nExpected token: '#{name}', instead got: '#{token}' at line: #{token.line}:#{token.col}".red.bold
   exit 1
end
