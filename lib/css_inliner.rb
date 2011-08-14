require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'css_inliner/version'
require 'css_inliner/integrator'
require 'css_inliner/inliner'

module CSSInliner
  class << self
    def process(html, basedir = '.')
      Inliner.new(html, basedir).inline.to_s
    end
  end
end
