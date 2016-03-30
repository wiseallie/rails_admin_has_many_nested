$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_admin_has_many_nested/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_admin_has_many_nested"
  s.version     = RailsAdminHasManyNested::VERSION
  s.authors     = ["wiseallie"]
  s.email       = ["wiseallie@gmail.com"]
  s.homepage    = "https://github.com/wiseallie/rails_admin_has_many_nested"
  s.summary     = "Show nested list on parent object member pages. Ie. show, edit and delete"
  s.description = "Show nested list on parent object member pages. Ie. show, edit and delete"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 4.0.0"
  s.add_dependency "rails_admin", ">= 0.6.0"

end
