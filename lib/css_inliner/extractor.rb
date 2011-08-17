require 'open-uri'
require 'css_parser'

module CSSInliner
  class Extractor
    attr_reader :document

    def initialize(document, directory)
      @document, @basedir = document, directory
    end

    def extract(remove_link_and_style = true)
      sources = []
      sources.concat extract_from_link(remove_link_and_style)
      sources.concat extract_from_style(remove_link_and_style)
      integrate sources
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

    def integrate(*sources)
      parser = CssParser::Parser.new
      parser.add_block!(sources * $/)
      rule_sets = parser.enum_for :each_rule_set
      i = 0
      rule_sets = rule_sets.sort_by {|rs| [rs.specificity, i += 1]}
      blank_rule_set = CssParser::RuleSet.new(nil, nil)
      rule_sets.inject(Hash.new(blank_rule_set)) do |rules, rs|
        sel = rs.selectors * ','
        rules[sel] = CssParser.merge rules[sel], rs
        rules
      end
    end

    def basedir
      base = @document.css('base')
      base.empty? ? @basedir : base[0]['href']
    end
  end
end
