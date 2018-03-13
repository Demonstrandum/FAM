class Object
  def base_name
    self.class.name.split(/(\:\:)|(\.)/)[-1]
  end
end

module FAM
  VERSIONS = { :major => 0, :minor => 0, :tiny => 1 }

  def self.version *args
    VERSIONS.flatten.select.with_index { |val, i| i.odd? }.join '.'
  end
end

Dir["#{File.dirname __FILE__}/fam/*.rb"].each    { |f| require f }
Dir["#{File.dirname __FILE__}/fam/**/*.rb"].each { |f| require f }
