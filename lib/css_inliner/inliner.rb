require 'rubygems'
require 'nokogiri'
require 'css_inliner/extractor'
require 'css_inliner/csspool'

module CSSInliner
  class Inliner
    # @param [Nokogiri::XML::Document] document
    # @param [String] basedir
    def initialize(document, basedir)
      @document = document
      @basedir = basedir
      @extractor = Extractor.new @document, @basedir
    end

    def inline
      css = @extractor.extract
      css.ordered_selectors.reverse_each do |selector|
        sel = selector.to_s
        next if sel =~ /@|:/
        body = @document.css('body')
        body.css(sel).each do |elem|
          elem = body.css('body').first if elem.name == 'html'
          next unless elem
          # To to: implement Declaration#merge and calc performance
          elem['style'] = "#{selector.declarations.join}#{elem['style']}"
        end
      end

      @document
    end
  end
end
