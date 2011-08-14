require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'css_inliner/version'
require 'css_inliner/integrator'
require 'css_inliner/inliner'

module CSSInliner
  class << self
    def process(html, basedir = '.', element = nil)
      doc = Inliner.new(html, basedir).inline
      doc = doc.css(element)[0] if element
      doc.to_s
    end
  end
end
