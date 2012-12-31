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

    assert_equal 'color: red;', base.to_css.strip
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
  border-top: blue 1em thin;
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
  border-top-width: 1px;
  border-right-width: 1px;
  border-bottom-width: 1px;
  border-left-width: 1px;
  border-top-color: red;
  border-right-color: red;
  border-bottom-color: red;
  border-left-color: red;
  border-top-style: thin;
  border-right-style: thin;
  border-bottom-style: thin;
  border-left-style: thin;
}
EOC

    expected = expected.rule_sets.map {|rule_set| rule_set.declarations.map(&:expand_border)}
    complex_border.rule_sets.map {|rule_set| rule_set.declarations.map(&:expand_border)}

    assert_equal expected.rule_sets, complex_border.rule_sets
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
                 four_dimension_border_width.rule_sets.first.declarations.first.expand_border.to_s
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
                 three_dimension_border_width.rule_sets.first.declarations.first.expand_border.to_s
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
                 two_dimension_border_width.rule_sets.first.declarations.first.expand_border.to_s
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

  def test_expand_no_dimension_border_width
    no_dimension_border_width = CSSPool.CSS <<EOC
p {
  border-width: zero;
}
EOC
    assert_raise CSSPool::CSS::Declaration::InvalidExpressionError do
      no_dimension_border_width.rule_sets.first.declarations.first.expand_border
    end
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
