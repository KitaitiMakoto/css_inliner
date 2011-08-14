require 'rubygems'
require 'nokogiri'
require 'css_inliner/integrator'

module CSSInliner
  class Inliner
    def initialize(html, basedir)
      @document = Nokogiri.HTML html
      @basedir = basedir
      @integrator = Integrator.new @document, @basedir
    end

    def inline
      original_style = {}
      @document.css('*[style]').each do |elem|
        original_style[elem] = elem['style']
      end

      styles = {}
      @integrator.integrate.each_pair do |sel, rule_set|
        next if sel =~ /@|:/
        body = @document.css('body')
        body.css(sel).each_with_index do |elem, i|
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

      @document
    end
  end
end
