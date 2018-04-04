require_relative 'lib/fam'

Gem::Specification.new do |s|
  s.name        = 'fam'
  s.version     = FAM::version
  s.required_ruby_version = '>= 2.0.0'
  s.executables << 'fam'
  s.date        = Time.now.to_s.split(/\s/)[0]
  s.summary     = "Fake Assembly(ish) Machine"
  s.description = "A very watered down language ment to look like an assembly language."
  s.authors     = ["Demonstrandum"]
  s.email       = 'knutsen@jetspace.co'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md DOC.md)
  s.require_path= 'lib'
  s.homepage    = 'https://github.com/Demonstrandum/FAM'
  s.license     = 'GPL-2.0'
end
