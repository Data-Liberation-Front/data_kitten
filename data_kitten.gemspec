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
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.md", "README.md"]
  s.executables << 'data_kitten'

  s.required_ruby_version = "~> 2.3.0"

  s.add_dependency "rake"
  s.add_dependency "git", "~> 1.7"
  s.add_dependency "json", "~> 2.5"
  s.add_dependency "rest-client", ">= 1.8", "< 3.0"
  s.add_dependency "linkeddata", "~> 1.0"
  s.add_dependency "nokogiri", "~> 1.6"
  s.add_dependency "datapackage", "~> 0.0"

  s.add_development_dependency "rspec"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "fakeweb", ["~> 1.3"]
  s.add_development_dependency "pry"

end
