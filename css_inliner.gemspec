# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "css_inliner/version"

Gem::Specification.new do |s|
  s.name        = "css_inliner"
  s.version     = CSSInliner::VERSION
  s.authors     = ["KITAITI Makoto"]
  s.email       = ["KitaitiMakoto@gmail.com"]
  s.homepage    = ""
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

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "css_parser"

  s.add_development_dependency "test-unit"
end
