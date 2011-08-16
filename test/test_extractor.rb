require_relative 'helper'
require 'nokogiri'
require 'css_inliner/extractor'

class ExtractorTest < Test::Unit::TestCase
  include CSSInliner

  def setup
    @sample_html = File.join File.dirname(__FILE__), 'fixtures', 'sample1', 'index.html'
    doc = Nokogiri.HTML File.read(@sample_html)
    @extractor = Extractor.new doc, File.dirname(@sample_html)
  end

  def test_extract_from_link_basic
    expected = File.read(File.join(File.dirname(@sample_html), 'rdoc.css'))
    actual = @extractor.extract_from_link[0]
    assert_equal expected, actual
  end
end
