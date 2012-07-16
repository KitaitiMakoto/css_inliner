require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'css_inliner/version'
require 'css_inliner/csspool'
require 'css_inliner/inliner'

module CSSInliner
  class << self
    # @param [Nokogiri::XML::Document, String] html
    # @param [String] basedir Base directory or URI to traverse relative URI for images
    # @param [String] element Element name to be returned.
    #   Returns whole document when nil
    # @param [String] format Format to output, html or xhtml
    # @return [String] HTML source
    def process(html, basedir = '.', element = nil, format = 'html')
      doc = html.instance_of?(Nokogiri::XML::Document) ? html : Nokogiri.HTML(html)
      doc = Inliner.new(doc, basedir).inline
      doc = doc.css(element)[0] if element
      case format
      when 'xhtml'
        doc.to_xhtml
      when 'html'
        doc.to_html
      when 'xml'
        doc.to_xml
      else
        doc.to_s
      end
    end
  end
end
