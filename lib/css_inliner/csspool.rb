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

      DIMENSIONS = %w[top right bottom left]
      PROPERTY_EXPANSION = {}
      %w[margin padding].each do |prop|
        PROPERTY_EXPANSION[prop] = DIMENSIONS.map {|dim| "#{prop}-#{dim}"}
      end
      %w[color style width].each do |subprop|
        PROPERTY_EXPANSION["border-#{subprop}"] = DIMENSIONS.map {|dim| "border-#{dim}-#{subprop}"}
      end

      # @param [Declaration] other
      # @return [Declaration] self
      def update(other)
        raise ArgumentError('different property') unless property == other.property
        self.expressions = other.expressions if !important? or other.important?
        self
      end
      alias merge! update

      # @param [Declaration] other
      # @return [Declaration] merged declaration
      def merge(other)
        dup.update other
      end

      # @return [Array<Declaration>] array of declaration indicating four dimensions
      def expand_dimension
        return [self] unless PROPERTY_EXPANSION.keys.include? property

        expanded = case expressions.length
                   when 4
                     expressions
                   when 3
                     [expressions[0], expressions[1], expressions[2], expressions[1]]
                   when 2
                     [expressions[0], expressions[1], expressions[0], expressions[1]]
                   when 1
                     [expressions[0], expressions[0], expressions[0], expressions[0]]
                   else
                     raise InvalidExpressionCountError, "has #{expressions.length} properties"
                   end

        PROPERTY_EXPANSION[property.to_s].each.with_index.map {|prop, i|
          Declaration.new(prop, expanded[i], important, rule_set)
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
