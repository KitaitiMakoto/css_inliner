require 'cover_me'
gem 'test-unit'
require 'test/unit'
require 'css_inliner'

class CSSInlinerTestCase < Test::Unit::TestCase
  include CSSInliner

  def setup
    @fixtures_dir = File.join(File.dirname(__FILE__), 'fixtures')

    @sample1_dir = File.join(@fixtures_dir, 'sample1')
    @sample2_dir = File.join(@fixtures_dir, 'sample2')
    @sample3_dir = File.join(@fixtures_dir, 'sample3')

    @html1 = File.read(File.join(@sample1_dir, 'index.html'))
    @html2 = File.read(File.join(@sample2_dir, 'index.html'))
    @html3 = File.read(File.join(@sample3_dir, 'index.html'))

    @doc1 = Nokogiri.HTML @html1
    @doc2 = Nokogiri.HTML @html2
    @doc3 = Nokogiri.HTML @html3
  end
end
