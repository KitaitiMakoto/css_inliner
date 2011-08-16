require 'rubygems'
require 'nokogiri'
require 'css_inliner/extractor'

module CSSInliner
  class Inliner
    def initialize(html, basedir)
      @document = Nokogiri.HTML html
      @basedir = basedir
      @extractor = Extractor.new @document, @basedir
    end

    def inline
      original_style = {}
      @document.css('*[style]').each do |elem|
        original_style[elem] = elem['style']
      end

      styles = {}
      @extractor.extract.each_pair do |sel, rs|
        next if sel =~ /@|:/
        body = @document.css('body')
        body.css(sel).each_with_index do |elem, i|
          styles[elem] = CssParser::RuleSet.new(nil, nil) unless styles[elem]
          styles[elem] = CssParser.merge styles[elem], rs
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

      @document
    end
  end
end
