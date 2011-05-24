# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hollybush/version"

Gem::Specification.new do |s|
  s.name        = "hollybush"
  s.version     = Hollybush::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ijonas Kisselbach"]
  s.email       = ["ijonas.kisselbach@gmail.com"]
  s.homepage    = "http://github.com/ijonas/hollybush"
  s.summary     = %q{Flexible structured list manager backed by MongoDB.}
  s.description = %q{Light-weight flexible structured list implementation.}

  s.rubyforge_project = "hollybush"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "mongo"
  s.add_dependency "mongo_ext"
  s.add_dependency "bson"
  s.add_dependency "bson_ext"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "awesome_print"
  
end
