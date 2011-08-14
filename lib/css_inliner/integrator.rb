require 'enumerator'
require 'rubygems'
require 'nokogiri'
require 'css_parser'

module CSSInliner
  class Integrator
    def initialize(document, basedir)
      @document, @basedir = document, basedir
    end

    def find_css
      bases = @document.css 'base'
      basedir = bases.empty? ? @basedir : bases[0]['href']

      externals = @document.css('link[rel="stylesheet"]').collect do |link|
        begin
          File.read File.join(basedir, link['href'])
        rescue Errno::ENOENT
          ''
        end
      end

      style_elems = @document.css('style').collect do |style|
        style.inner_text
      end

      @document.css('link[rel="stylesheet"], style').remove
      @css_array = externals + style_elems
    end

    def integrate
      find_css unless @css_array
      css_parser = CssParser::Parser.new
      @css_array.each {|css| css_parser.add_block! css}
      css_map = create_css_map css_parser
    end

    def create_css_map(css_parser)
      selectors = css_parser.enum_for :each_selector
      rules = {}
      i = 0
      selectors = selectors.sort_by {|sel, dec, spec| [spec, i += 1]}
      selectors.each do |sel, dec, spec|
        rules[sel] = CssParser::RuleSet.new(sel, nil) unless rules[sel]
        rules[sel] = CssParser.merge(
                       rules[sel],
                       CssParser::RuleSet.new(sel, dec)
                     )
      end
      rules
    end
  end
end
