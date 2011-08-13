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
      csss = find_css html, File.dirname(input)
      css_parser = CssParser::Parser.new
      csss.each {|css| css_parser.add_block! css}

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
        rules[sel].parse_selectors! sel
      end


      require 'pp'
      p rules['body'].selectors


      # integrated_css = csss.inject {|result, css| result.merge css}
      # inline html, integrated_css
    end

  private

    def find_css(html, basedir)
      doc = Nokogiri.HTML html
      bases = doc.css 'base'
      basedir = bases[0]['href'] unless bases.empty?

      styles = doc.css('style').collect do |style|
        style.inner_text
      end

      externals = doc.css('link[rel="stylesheet"]').collect do |link|
        begin
          File.read File.join(basedir, link['href'])
        rescue Errno::ENOENT
          ''
        end
      end

      doc.css('link[rel="stylesheet"], style').remove
      styles + externals
    end

    def parse_css(csss)
    end
  end
end
