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
            base_decl = base_decls.pop
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
    end
  end

  module Visitors
    class ToCSS
      alias visit_CSSInliner_CSSDocument visit_CSSPool_CSS_Document
    end
  end
end
