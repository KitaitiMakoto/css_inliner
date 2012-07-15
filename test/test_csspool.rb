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
    four_border_dimensions = CSSPool.CSS <<EOC
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
                 four_border_dimensions.rule_sets.first.declarations.first.expand_border.to_s
  end

  def test_expand_three_dimension_border_width
    assert false
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
