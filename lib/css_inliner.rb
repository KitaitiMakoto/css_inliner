require 'open-uri'
require 'enumerator'
require 'rubygems'
require 'nokogiri'
require 'css_parser'
require 'css_inliner/version'

module CSSInliner
  class << self
    def process(input, output = nil)
      html = File.read(input)
      doc = Nokogiri.HTML html
      csss = find_css doc, File.dirname(input)
      css_parser = CssParser::Parser.new
      csss.each {|css| css_parser.add_block! css}
      css_map = create_css_map css_parser
      doc = inline doc, css_map

      if output
        open(output, 'w') {|f| f.write doc.to_s}
      else
        $stdout.write doc.to_s
      end
    end

  private

    def find_css(doc, basedir)
      bases = doc.css 'base'
      basedir = bases[0]['href'] unless bases.empty?

      externals = doc.css('link[rel="stylesheet"]').collect do |link|
        begin
          File.read File.join(basedir, link['href'])
        rescue Errno::ENOENT
          ''
        end
      end

      style_elems = doc.css('style').collect do |style|
        style.inner_text
      end

      doc.css('link[rel="stylesheet"], style').remove
      externals + style_elems
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

    def inline(doc, css_map)
      original_style = {}
      doc.css('*[style]').each do |elem|
        original_style[elem] = elem['style']
      end

      styles = {}
      css_map.each_pair do |sel, rule_set|
        next if sel =~ /@/
        # rule_set.each_declaration {|prop, val, imp| p [prop, val, imp]}
        doc.css(sel).each_with_index do |elem, i|
          styles[elem] = CssParser::RuleSet.new(nil, nil) unless styles[elem]
          styles[elem] = CssParser.merge styles[elem], rule_set
        end
      end

      original_style.each_pair do |elem, style|
        styles[elem] = CssParser::RuleSet.new(nil, nil) unless styles[elem]
        rs = CssParser::RuleSet.new(nil, style)
        styles[elem] = CssParser.merge styles[elem], rs
      end

      styles.each_pair do |elem, rule_set|
        elem['style'] = rule_set.declarations_to_s
      end

      doc
    end
  end
end
