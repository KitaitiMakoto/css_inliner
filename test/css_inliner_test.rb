require_relative 'test_helper'
require 'css_inliner'

class CSSInlinerTest < Test::Unit::TestCase
  def setup
    @fixtures_dir = File.join(File.dirname(__FILE__), 'fixtures')
  end

  def test_process_without_inline_style
    basedir = File.join(@fixtures_dir, 'sample1')
    assert_equal *process(basedir)
  end

  def test_process_with_inline_style
    basedir = File.join(@fixtures_dir, 'sample2')
    assert_equal *process(basedir)
  end

  def process(basedir)
    source = File.read(File.join(basedir, 'index.html'))
    inlined = File.read(File.join(basedir, 'index.inlined.html'))
    [inlined, CSSInliner.process(source, basedir)]
  end
end
