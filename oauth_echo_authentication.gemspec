$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "oauth_echo_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "oauth_echo_authentication"
  s.version     = OauthEchoAuthentication::VERSION
  s.authors     = ["Toru KAWAMURA"]
  s.email       = ["tkawa@4bit.net"]
  s.homepage    = ""
  s.summary     = "TODO: Summary of OauthEchoAuthentication."
  s.description = "TODO: Description of OauthEchoAuthentication."

  s.files = Dir["{lib,spec}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails"

  #s.add_development_dependency "sqlite3"
end
