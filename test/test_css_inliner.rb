require_relative 'helper'
require 'tmpdir'
require 'css_inliner'

class CSSInlinerTest < CSSInlinerTestCase
  def setup
    super
  end

  def test_process_without_inline_style
    html = <<EOH
<html>
  <head>
    <title>Without Inline Style</title>
    <link rel="stylesheet" type="text/css" href="./style.css">
  </head>
  <body>
    <p>This is a blue line.</p>
  </body>
</html>
EOH
    css = <<EOC
p {
  color: blue;
}
EOC
    inlined = process(html, css)
    doc = Nokogiri.HTML(inlined)
    style = doc.search('p').first['style'].strip
    assert_equal 'color: blue;', style
  end

  def test_process_with_inline_style
    html = <<EOH
<html>
  <head>
    <title>With Inline Style</title>
    <link rel="stylesheet" type="text/css" href="./style.css">
  </head>
  <body>
    <p style="font-weight: bold;">This is a bold blue line.</p>
  </body>
</html>
EOH
    css = <<EOC
p {
  color: blue;
}
EOC
    inlined = process(html, css)
    doc = Nokogiri.HTML(inlined)
    style = doc.search('p').first['style'].strip.gsub(/ +/, '')
    assert_equal 'color:blue;font-weight:bold;', style
  end

  def test_process_with_style_elem
    html = <<EOH
<html>
  <head>
    <title>With Style Attribute</title>
    <link rel="stylesheet" type="text/css" href="./style.css">
    <style type="text/css">
      p {font-style: oblique;}
    </style>
  </head>
  <body>
    <p>This is a oblique blue line.</p>
  </body>
</html>
EOH
    css = <<EOC
p {
  color: blue;
}
EOC
    inlined = process(html, css)
    doc = Nokogiri.HTML(inlined)
    style = doc.search('p').first['style'].strip.gsub(/ +/, '')
    assert_equal 'color:blue;font-style:oblique;', style
  end

  def test_process_with_inline_style_and_style_elem
    html = <<EOH
<html>
  <head>
    <title>With Inline Style and Style Attribute</title>
    <link rel="stylesheet" type="text/css" href="./style.css">
    <style type="text/css">
      p {font-style: oblique;}
    </style>
  </head>
  <body>
    <p style="font-weight: bold;">This is a bold oblique blue line.</p>
  </body>
</html>
EOH
    css = <<EOC
p {
  color: blue;
}
EOC
    inlined = process(html, css)
    doc = Nokogiri.HTML(inlined)
    style = doc.search('p').first['style'].strip.gsub(/ +/, '')
    assert_equal 'color:blue;font-style:oblique;font-weight:bold;', style
  end

  private

  def process(html, css)
    Dir.mktmpdir('css_inliner') do |dir|
      File.open("#{dir}/style.css", 'w') do |f|
        f.write css
      end
      CSSInliner.process(html, dir)
    end
  end
end
