require 'rubygems'
require 'nokogiri'
require 'csspool'
require 'css_inliner/extractor'

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
      css.specificity_index.each do |selector|
        sel = selector.to_s
        next if sel =~ /@|:/
        body = @document.css('body')
        body.css(sel).each do |elem|
          elem = body.css('body').first if elem.name == 'html'
          next unless elem
          elem['style'] = "#{selector.declarations.join}#{elem['style']}"
        end
      end

      @document
    end
  end
end
