require 'open-uri'
require 'css_parser'

module CSSInliner
  class Extractor
    attr_reader :document, :basedir

    def initialize(document, basedir)
      @document, @basedir = document, basedir
    end

    def extract(remove_link_and_style = true)
      sources = []
      sources.concat extract_from_link(remove_link_and_style)
      sources.concat extract_from_style(remove_link_and_style)
      integrate! sources
    end

    def extract_from_link(remove_link_element = true)
      @document.css('link[rel="stylesheet"]').inject([]) do |sources, link|
        begin
          open(File.join(basedir, link['href'])) {|f| sources << f.read}
        rescue Errno::ENOENT
          warn File.join(basedir, link['href']) + 'not found'
        end
        link.remove if remove_link_element
        sources
      end
    end

    def extract_from_style(remove_style_element = true)
      @document.css('style').inject([]) do |sources, style|
        sources << style.content
        style.remove if remove_style_element
        sources
      end
    end

    def integrate!(sources)
      parser = CssParser::Parser.new
      sources.each {|css| parser.add_block! css}
      selectors = parser.enum_for :each_selector
      i = 0
      selectors = selectors.sort_by {|sel, dec, spec| [spec, i += 1]}
      selectors.inject(Hash.new(CssParser::RuleSet.new(nil, nil))) do |rules, (sel, dec, spec)|
        rules[sel] = CssParser.merge rules[sel], CssParser::RuleSet.new(sel, dec)
        rules
      end
    end

    def basedir
      base = @document.css('base')
      base.empty? ? @basedir : base[0]['href']
    end
  end
end
