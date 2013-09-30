lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

# Maintain your gem's version:
require "data_kitten/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "data_kitten"
  s.version     = DataKitten::VERSION
  s.authors     = ["James Smith", "Stuart Harrison"]
  s.email       = ["tech@theodi.org"]
  s.homepage    = "http://github.com/data-kitten"
  s.summary     = "Get dataset metadata in a consistent format - no matter what you throw at it"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.md", "README.md"]

  s.add_dependency "git"
  s.add_dependency "json"
  s.add_dependency "rest-client"
  s.add_dependency "linkeddata"
  s.add_dependency "nokogiri"
  s.add_dependency "curb"

  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov-rcov"
  s.add_development_dependency "fakeweb", ["~> 1.3"]

end