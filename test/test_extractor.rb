require_relative 'helper'
require 'nokogiri'

class TestExtractor < CSSInlinerTestCase
  def setup
    super
    @extractor1 = Extractor.new @doc1, @sample1_dir
    @extractor2 = Extractor.new @doc2, @sample2_dir
    @extractor3 = Extractor.new @doc3, @sample3_dir
    @extractor4 = Extractor.new @doc4, @sample4_dir
  end

  def test_extract_from_link_basic
    expected = File.read(File.join(@sample1_dir, 'rdoc.css'))
    actual = @extractor1.extract_from_link[0]
    assert_equal expected, actual
  end

  def test_extract_from_link_remove_link_element_when_passed_true
    @extractor1.extract_from_link(true)
    assert_empty @doc1.css('link[rel="stylesheet"]')
  end

  def test_extract_from_link_leave_link_element_when_passed_false
    expected = @doc1.css('link[rel="stylesheet"]').to_s
    @extractor1.extract_from_link(false)
    assert_equal expected, @doc1.css('link[rel="stylesheet"]').to_s
  end

  def test_extract_from_style_basic
    src = '
    h2   {
      color:  gray ;
    }
'
    expected = CSSPool.CSS src
    actual = CSSPool.CSS @extractor3.extract_from_style[0]

    assert_equal expected.to_s, actual.to_s
  end

  def test_extract_from_style_remove_style_element_when_passed_true
    @extractor3.extract_from_style(true)
    assert_empty @doc3.css('style')
  end

  def test_extract_from_style_leave_style_element_when_passed_false
    expected = @doc3.css('style').to_s
    @extractor3.extract_from_style(false)
    assert_equal expected, @doc3.css('style').to_s
  end

  def test_extract_from_grouped_files
    doc = Nokogiri.HTML <<EOH
<html>
  <head>
    <link rel="stylesheet" type="text/css" title="group1" href="group1-1.css">
    <link rel="stylesheet" type="text/css" title="group1" href="group1-2.css">
    <link rel="stylesheet" type="text/css" title="group2" href="group2-1.css">
  </head>
  <body>
  </body>
</html>
EOH
    expected = [
'#group1-1 {
  color: black;
}
',
'#group1-2 {
  color: black;
}
'
]
    extractor = Extractor.new(doc, @sample1_dir)

    assert_equal expected, extractor.extract_from_link
  end

  def test_integrate_basic
    sources = [
      '
h2 {
  color: gray;
}',
'
h2 p {
  color: blue;
}
',
'
a {
  text-decoration: none;
}
'
    ]
    expected = <<EOC
h2 {
  color: gray;
}
h2 p {
  color: blue;
}
a {
  text-decoration: none;
}
EOC
    assert_equal expected.chomp, @extractor1.integrate(sources).to_css.chomp
  end
end
