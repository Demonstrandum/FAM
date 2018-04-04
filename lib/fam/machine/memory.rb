SIZES = {
  :B => 1e0, :kB => 1e3, :MB => 1e6,
  :GB => 1e9, :TB => 1e12
}

class NULL < NilClass
  def to_s *args; 'NULL'; end
end

module FAM::Machine
  class RAM
    attr_accessor :array

    def initialize size
      alloc = 0
      case size
      when Numeric
        alloc = size
      when String
        suffix = size.upcase[/[A-Z]+/] || ''
        suffix = 'kB' if suffix == 'KB'
        unless suffix.empty?
          alloc = size[/[0-9]+/].to_i * SIZES[suffix.to_sym]
        else
          alloc = size.to_i
        end
      else
        abort 'ERROR: `size` argument must be a string or numeric!'.red
      end
      @array = Array.new(alloc, NULL)
    end

    def [](i)
      @array[i]
    end

    def []=(i, value)
      abort 'ERROR: Only integers can be stored in memory!' unless i.class == Integer
      @array[i] = value
    end

    def to_a
      @array
    end

    def to_s
      result = String.new
      width = %x{ tput cols }.to_i
      i = j = 0
      loop do
        break if j >= @array.size
        line = String.new
        i = j
        while line.size < width && j <= @array.size
          line << "#{@array[j].to_s.rjust 4, '0'}XXXXX" # `X` padding
          j += 1
        end
        result << "| #{@array[i..j].map {|e| e.to_s.rjust 4, '0'}.join ' | '} |\n"
      end
      result
    end
  end
end
