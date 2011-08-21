require_relative 'helper'
require 'css_inliner'

class CSSInlinerTest < CSSInlinerTestCase
  def setup
    super
  end

  def test_process_without_inline_style
    assert_equal *process(@sample1_dir)
  end

  def test_process_with_inline_style
    assert_equal *process(@sample2_dir)
  end

  def test_process_with_style_attribute
    assert_equal *process(@sample3_dir)
  end

  def test_process_with_inline_style_and_style_attibute
    assert_equal *process(@sample4_dir)
  end

  def process(basedir)
    source = File.read(File.join(basedir, 'index.html'))
    inlined = File.read(File.join(basedir, 'index.inlined.html'))
    [inlined, CSSInliner.process(source, basedir)]
  end
end
