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
      class InvalidExpressionError < StandardError; end
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

      COLOR_NAMES = %w[
        black
        silver
        gray
        white
        maroon
        red
        purple
        fuchsia
        green
        lime
        olive
        yellow
        navy
        blue
        teal
        aqua

        aliceblue
        antiquewhite
        aqua
        aquamarine
        azure
        beige
        bisque
        black
        blanchedalmond
        blue
        blueviolet
        brown
        burlywood
        cadetblue
        chartreuse
        chocolate
        coral
        cornflowerblue
        cornsilk
        crimson
        cyan
        darkblue
        darkcyan
        darkgoldenrod
        darkgray
        darkgreen
        darkgrey
        darkkhaki
        darkmagenta
        darkolivegreen
        darkorange
        darkorchid
        darkred
        darksalmon
        darkseagreen
        darkslateblue
        darkslategray
        darkslategrey
        darkturquoise
        darkviolet
        deeppink
        deepskyblue
        dimgray
        dimgrey
        dodgerblue
        firebrick
        floralwhite
        forestgreen
        fuchsia
        gainsboro
        ghostwhite
        gold
        goldenrod
        gray
        green
        greenyellow
        grey
        honeydew
        hotpink
        indianred
        indigo
        ivory
        khaki
        lavender
        lavenderblush
        lawngreen
        lemonchiffon
        lightblue
        lightcoral
        lightcyan
        lightgoldenrodyellow
        lightgray
        lightgreen
        lightgrey
        lightpink
        lightsalmon
        lightseagreen
        lightskyblue
        lightslategray
        lightslategrey
        lightsteelblue
        lightyellow
        lime
        limegreen
        linen
        magenta
        maroon
        mediumaquamarine
        mediumblue
        mediumorchid
        mediumpurple
        mediumseagreen
        mediumslateblue
        mediumspringgreen
        mediumturquoise
        mediumvioletred
        midnightblue
        mintcream
        mistyrose
        moccasin
        navajowhite
        navy
        oldlace
        olive
        olivedrab
        orange
        orangered
        orchid
        palegoldenrod
        palegreen
        paleturquoise
        palevioletred
        papayawhip
        peachpuff
        peru
        pink
        plum
        powderblue
        purple
        red
        rosybrown
        royalblue
        saddlebrown
        salmon
        sandybrown
        seagreen
        seashell
        sienna
        silver
        skyblue
        slateblue
        slategray
        slategrey
        snow
        springgreen
        steelblue
        tan
        teal
        thistle
        tomato
        turquoise
        violet
        wheat
        white
        whitesmoke
        yellow
        yellowgreen
      ]

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

      # @todo consider transparent and so on
      # @return [Array<Declaration>] array of declaration expanded to style, width and color
      def expand_border
        # border: black dotted 1px => [border-color: black, border-style: dotted, border-width: 1px]
        # 1px => CSSPool::Terms::Number
        # #000000 => CSSPool::Terms::Hash
        # rgb(255, 255, 255) => CSSPool::Terms::Rgb
        expanded_properties = PROPERTY_EXPANSION[property]

        return [self] unless expanded_properties

        raise InvalidExpressionCountError, "has #{expressions.length} expressions" if expressions.length > expanded_properties.length

        decls = []
        expansion_map = EXPANSION_INDICES[expressions.length]
        expanded_properties.each.with_index do |prop, i|
          exp = expressions[expansion_map[i]]
          case exp
          when CSSPool::Terms::Number
            # width
            decls << Declaration.new(prop, exp, important, rule_set)
          when CSSPool::Terms::Hash, CSSPool::Terms::Rgb#, color name regexp
            # color
            raise NotImplementedError
          when CSSPool::Terms::Ident
            unless (BORDER_STYLES + BORDER_WIDTH_KEYWORDS + COLOR_NAMES + BORDER_COLOR_KEYWORDS).include?(exp.to_s)
              raise InvalidExpressionError
            end
            # style or color or width keyword
            raise NotImplementedError
          else
            # raise
            raise InvalidExpressionError
          end
        end

        # check the case "border: red 1xp;" <- style omitted

        decls
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
