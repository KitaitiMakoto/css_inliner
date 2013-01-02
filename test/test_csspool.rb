require_relative 'helper'

class TestCSSPool < CSSInlinerTestCase
  def setup
    super

    @css = CSSPool.CSS <<EOC
p {
  color: black;
}
p {
  color: white;
}
p {
  color: blue !important;
}
p {
  color: red;
}
EOC
  end

  def test_update_basic
    base = @css.rule_sets.first.declarations.first
    other = @css.rule_sets.last.declarations.first
    base.update other

    assert_equal 'color: black red;', base.to_css.strip
  end

  def test_udpate_with_important
    base = @css.rule_sets[2].declarations.first
    other = @css.rule_sets.first.declarations.first
    base.update other

    assert_equal 'color: blue !important;', base.to_css.strip
  end

  def test_complex_border
    complex_border = CSSPool.CSS <<EOC
p {
  border: red 1px;
}
div {
  border-top: blue solid thin;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-width: 1px;
  border-right-width: 1px;
  border-bottom-width: 1px;
  border-left-width: 1px;
  border-top-color: red;
  border-right-color: red;
  border-bottom-color: red;
  border-left-color: red;
}
div {
  border-top-width: thin;
  border-top-color: blue;
  border-top-style: solid;
}
EOC
    assert_equal expected.rule_sets.map {|rs| rs.declarations}.flatten.map(&:to_s).sort,
    complex_border.rule_sets.map {|rs| rs.declarations.map {|decl| decl.expand_border.map(&:expand_dimension)}}.flatten.map(&:to_s).sort
  end

  def test_non_expandable_border
    non_expandable = CSSPool.CSS <<EOC
p {
  border-top-width: 12em;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-width: 12em;
}
EOC
    assert_equal expected.rule_sets.first.declarations.to_s,
                 non_expandable.rule_sets.first.declarations.first.expand_border.to_s
  end

  def test_expand_border_with_three_expressions
    non_expanded = CSSPool.CSS <<EOC
p {
  border: black dotted 1px;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-color: black;
  border-style: dotted;
  border-width: 1px;
}
EOC
    assert_equal expected.rule_sets.map {|rs| rs.declarations}.flatten.map(&:to_s).sort,
                 non_expanded.rule_sets.map {|rs| rs.declarations.map(&:expand_border)}.flatten.map(&:to_s).sort
  end

  def test_expand_border_with_two_expressions
    non_expanded = CSSPool.CSS <<EOC
p {
  border: #FFFFFF thin;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-color: #FFFFFF;
  border-width: thin;
}
EOC
    assert_equal expected.rule_sets.map {|rs| rs.declarations}.flatten.map(&:to_s).sort,
                 non_expanded.rule_sets.map {|rs| rs.declarations.map(&:expand_border)}.flatten.map(&:to_s).sort
  end

  def test_expand_border_with_one_expression
    non_expanded = CSSPool.CSS <<EOC
p {
  border: rgb(100%, 0%, 0%);
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-color: rgb(100%, 0%, 0%);
}
EOC
    assert_equal expected.rule_sets.map {|rs| rs.declarations}.flatten.map(&:to_s).sort,
                 non_expanded.rule_sets.map {|rs| rs.declarations.map(&:expand_border)}.flatten.map(&:to_s).sort
  end

  def test_expand_five_dimension_border_width
    five_border_dimensions = CSSPool.CSS <<EOC
p {
  border-width: 12em 3em 1em 5em 3em;
}
EOC
    assert_raise CSSPool::CSS::Declaration::InvalidExpressionCountError do
      five_border_dimensions.rule_sets.first.declarations.first.expand_border
    end
  end

  def test_expand_four_dimension_border_width
    four_dimension_border_width = CSSPool.CSS <<EOC
p {
  border-width: 1em 2em 3em 4em
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-width: 1em;
  border-right-width: 2em;
  border-bottom-width: 3em;
  border-left-width: 4em;
}
EOC
    assert_equal expected.rule_sets.first.declarations.to_s,
                 four_dimension_border_width.rule_sets.first.declarations.first.expand_dimension.to_s
  end

  def test_expand_three_dimension_border_width
    three_dimension_border_width = CSSPool.CSS <<EOC
p {
  border-width: 1em 2em 3em;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-width: 1em;
  border-right-width: 2em;
  border-bottom-width: 3em;
  border-left-width: 2em;
}
EOC
    assert_equal expected.rule_sets.first.declarations.to_s,
                 three_dimension_border_width.rule_sets.first.declarations.first.expand_dimension.to_s
  end

  def test_expand_two_dimension_border_width
    two_dimension_border_width = CSSPool.CSS <<EOC
p {
  border-width: 1em 2em;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-width: 1em;
  border-right-width: 2em;
  border-bottom-width: 1em;
  border-left-width: 2em;
}
EOC
    assert_equal expected.rule_sets.first.declarations.to_s,
                 two_dimension_border_width.rule_sets.first.declarations.first.expand_dimension.to_s
  end

  def test_expand_one_dimension_border_width
    one_dimension_border_width = CSSPool.CSS <<EOC
p {
  border-width: 1em;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-width: 1em;
  border-right-width: 1em;
  border-bottom-width: 1em;
  border-left-width: 1em;
}
EOC
    assert_equal expected.rule_sets.first.declarations.to_s,
                 one_dimension_border_width.rule_sets.first.declarations.first.expand_border.to_s
  end

  def test_expand_border_with_invalid_property
    no_dimension_border_width = CSSPool.CSS <<EOC
p {
  border: zero;
}
EOC
    assert_empty no_dimension_border_width.rule_sets.first.declarations.first.expand_border
  end

  def test_non_expandable_dimension
    no_dimension = CSSPool.CSS <<EOC
p {
  color: blue;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  color: blue;
}
EOC
    assert_equal expected.rule_sets.first.declarations.to_s,
                 no_dimension.rule_sets.first.declarations.first.expand_dimension.to_s
  end

  def test_expand_five_dimensions
    five_dimensions = CSSPool.CSS <<EOC
p {
  border-width: 1em 2em 3em 4em 5em;
}
EOC
    assert_raise CSSPool::CSS::Declaration::InvalidExpressionCountError do
      five_dimensions.rule_sets.first.declarations.first.expand_dimension
    end
  end

  def test_expand_four_dimensions
    four_dimensions = CSSPool.CSS <<EOC
p {
  margin: 1em 2em 3em 4em;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  margin-top: 1em;
  margin-right: 2em;
  margin-bottom: 3em;
  margin-left: 4em;
}
EOC

    assert_equal expected.rule_sets.first.declarations.to_s,
                 four_dimensions.rule_sets.first.declarations.first.expand_dimension.to_s
  end

  def test_expand_three_dimensions
    three_dimensions = CSSPool.CSS <<EOC
p {
  padding: 1em 2em 3em;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  padding-top: 1em;
  padding-right: 2em;
  padding-bottom: 3em;
  padding-left: 2em;
}
EOC

    assert_equal expected.rule_sets.first.declarations.to_s,
                 three_dimensions.rule_sets.first.declarations.first.expand_dimension.to_s
  end

  def test_expand_two_dimensions
    two_dimensions = CSSPool.CSS <<EOC
p {
  border-color: red blue;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-color: red;
  border-right-color: blue;
  border-bottom-color: red;
  border-left-color: blue;
}
EOC

    assert_equal expected.rule_sets.first.declarations.to_s,
                 two_dimensions.rule_sets.first.declarations.first.expand_dimension.to_s
  end

  def test_expand_one_dimension
    one_dimension = CSSPool.CSS <<EOC
p {
  border-style: dotted;
}
EOC
    expected = CSSPool.CSS <<EOC
p {
  border-top-style: dotted;
  border-right-style: dotted;
  border-bottom-style: dotted;
  border-left-style: dotted;
}
EOC

    assert_equal expected.rule_sets.first.declarations.to_s,
                 one_dimension.rule_sets.first.declarations.first.expand_dimension.to_s
  end
end
