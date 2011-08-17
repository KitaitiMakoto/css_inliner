$:.push File.expand_path("../lib", __FILE__)
require "css_inliner/version"

Gem::Specification.new do |s|
  s.name        = "css_inliner"
  s.version     = CSSInliner::VERSION
  s.authors     = ["KITAITI Makoto"]
  s.email       = ["KitaitiMakoto@gmail.com"]
  s.homepage    = "http://gitorious.org/css_inliner"
  s.summary     = %q{inline CSS into HTML attribute of elements}
  s.description = %q{
    inline CSS from external file(s) and/or style elment(s) in head element
    into style attibute of HTML elements
  }

  # s.rubyforge_project = "css_inliner"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.has_rdoc      = false

  s.add_runtime_dependency "nokogiri", '~> 1'
  s.add_runtime_dependency "css_parser", '~> 1'

  s.add_development_dependency "test-unit", '~> 2'
  s.add_development_dependency "cover_me", '~> 1'
end
