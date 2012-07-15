require 'csspool'

module CSSPool
  module CSS
    class << self
      # Update declarations in base with ones in other
      # @param [Array<Declaration>] base updated array of declarations
      # @param [Array<Declaration>] other array of declarations
      # @return [Array<Declaration>] base itself
      def update_declarations(base, other)
        other.each do |other_decl|
          base_decls = base.find_all {|base_decl| base_decl.property == other_decl.property}
          if base_decls.empty?
            base << other_decl
          else
            base_decl = base_decls.shift
            base_decls.each do |decl|
              base_decl.update decl
            end
            base_decl.update other_decl
          end
        end
        base
      end

      # Merge declarations in each argument
      # @param [Array<Declaration>] base Array of declarations
      # @param [Array<Declaration>] other Array of declarations
      # @return [Aarray<Declaration>] merged array of declarations
      def merge_declarations(base, other)
        update_declarations base.dup, other
      end
    end

    class Declaration
      class InvalidExpressionCountError < StandardError; end

      COLOR_NAMES = %w[red lime blue black gray silver white maroon green navy purple olive teal yellow fuchsia aqua]

      BORDER_STYLES = %w[none hidden solid double groove ridge inset outset dashed dotted]
      BORDER_WIDTH_KEYWORDS = %w[thin medium thick]
      BORDER_COLOR_KEYWORDS = %w[transparent]

      DIMENSIONS = %w[top right bottom left]

      PROPERTY_EXPANSION = {}
      PROPERTY_EXPANSION['border'] = %w[border-style border-width border-color]
      %w[margin padding].each do |prop|
        PROPERTY_EXPANSION[prop] = DIMENSIONS.map {|dim| "#{prop}-#{dim}"}
      end
      %w[color style width].each do |subprop|
        PROPERTY_EXPANSION["border-#{subprop}"] = DIMENSIONS.map {|dim| "border-#{dim}-#{subprop}"}
      end

      EXPANSION_INDICES = {
        1 => [0, 0, 0, 0],
        2 => [0, 1, 0, 1],
        3 => [0, 1, 2, 1],
        4 => [0, 1, 2, 3]
      }

      # @param [Declaration] other
      # @return [Declaration] self
      def update(other)
        raise ArgumentError, 'different property' unless property == other.property
        self.expressions = other.expressions if !important? or other.important?
        self
      end
      alias merge! update

      # @param [Declaration] other
      # @return [Declaration] merged declaration
      def merge(other)
        dup.update other
      end

      # @return [Array<Declaration>] array of declaration expanded to style, width and color
      def expand_border
        # border: black dotted 1px => [border-color: black, border-style: dotted, border-width: 1px]
        # 1px => CSSPool::Terms::Number
        # #000000 => CSSPool::Terms::Hash
        # rgb(255, 255, 255) => CSSPool::Terms::Rgb
        expanded_properties = PROPERTY_EXPANSION[property] # ["border-top-width", "border-right-width", "border-bottom-width", "border-left-width"]

        return [self] unless expanded_properties

        raise InvalidExpressionCountError, "has #{expressions.length} expressions" if expressions.length > expanded_properties.length

        expanded = []
        expressions.each do |exp|
          case exp
          when CSSPool::Terms::Number
            # width
            expanded << Declaration.new(expanded_properties.shift, exp, important, rule_set)
          when CSSPool::Terms::Hash, CSSPool::Terms::Rgb#, color name regexp
            # color
            raise NotImplementedError
          when CSSPool::Terms::Ident
            # check exp.to_s is style or color name
            raise NotImplementedError
          else
            # raise
            raise NotImplementedError
          end
        end

        # check the case "border: red 1xp;" <- style omitted

        expanded
      end

      # @return [Array<Declaration>] array of declaration indicating four dimensions
      def expand_dimension
        expanded_properties = PROPERTY_EXPANSION[property]
        return [self] unless expanded_properties

        expansion_map = EXPANSION_INDICES[expressions.length]
        raise InvalidExpressionCountError, "has #{expressions.length} properties" unless expansion_map

        expanded_properties.each.with_index.map {|prop, i|
          expression = expressions[expansion_map[i]]
          Declaration.new(prop, expression, important, rule_set)
        }
      end
    end
  end

  module Visitors
    class ToCSS
      alias visit_CSSInliner_CSSDocument visit_CSSPool_CSS_Document
    end
  end
end
