require 'rubygems'
require 'nokogiri'
require 'css_inliner/extractor'
require 'css_inliner/csspool'

module CSSInliner
  class Inliner
    # @param [Nokogiri::XML::Document] document
    # @param [String] basedir
    def initialize(document, basedir)
      @document = document
      @basedir = basedir
      @extractor = Extractor.new @document, @basedir
    end

    def inline
      original_styles = {}
      @document.search('.//*[@style]').each do |elem|
        original_styles[elem] = elem['style']
        elem.remove_attribute('style')
      end

      css = @extractor.extract
      css.sorted_selectors.each do |selector|
        sel = selector.to_s
        next if sel =~ /@|:/
        sel = 'body' if sel == '*' or sel == 'html'
        @document.css(sel).each do |elem|
          base = CSSPool.CSS("* {#{elem['style']}}").rule_sets.first.declarations
          elem['style'] = CSSPool::CSS.update_declarations(base, selector.declarations).join
        end
      end

      original_styles.each_pair do |elem, style|
        base = CSSPool.CSS("* {#{elem['style']}}").rule_sets.first.declarations
        orig = CSSPool.CSS("* {#{style}}").rule_sets.first.declarations
        elem['style'] = CSSPool::CSS.update_declarations(base, orig).join
      end
      # css.sorted_selectors.reverse_each do |selector|
      #   sel = selector.to_s
      #   next if sel =~ /@|:/
      #   body = @document.css('body')
      #   body.css(sel).each do |elem|
      #     elem = body.css('body').first if elem.name == 'html'
      #     next unless elem
      #     # To to: implement Declaration#merge and calc performance
      #     elem['style'] = "#{selector.declarations.join}#{elem['style']}"
      #   end
      # end

      @document
    end
  end
end
