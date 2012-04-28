require 'English'
require 'open-uri'
require 'bsearch'
require 'css_inliner/csspool'

module CSSInliner
  class CSSDocument < CSSPool::CSS::Document
    # Descending order
    # [
    #   {specificity: [2,1,4], selectors: [selector, selector, ...]},
    #   {specificity: [2,1,3], selectors: [selector, selector, ...]},
    #   #                :
    #   #                :
    # ]
    attr_accessor :specificity_index

    def initialize
      super
      @specificity_index = []
    end
  end

  class CSSDocumentHandler < CSSPool::CSS::DocumentHandler
    def start_document
      @document = CSSDocument.new
    end

    def start_selector selector_list
      super
      selector_list.each do |selector|
        index = @document.specificity_index.bsearch_upper_boundary { |existing|
          existing.specificity <=> selector.specificity
        }
        @document.specificity_index.insert index, selector
      end
    end
  end

  class Extractor
    attr_reader :document

    def initialize(document, directory)
      @document, @basedir = document, directory
    end

    def extract(remove_link_and_style = true)
      sources = []
      sources.concat extract_from_link(remove_link_and_style)
      sources.concat extract_from_style(remove_link_and_style)
      integrate sources
    end

    def extract_from_link(remove_link_element = true)
      @document.css('link').inject([]) do |sources, link|
        next unless link['rel'] == 'stylesheet'
        begin
          # To do: detect file encoding before open it(read only @charset value)
          open(File.join(basedir, link['href']), 'r:BOM|UTF-8') {|f| sources << f.read}
        rescue Errno::ENOENT
          warn File.join(basedir, link['href']) + ' not found'
        end
        link.remove if remove_link_element
        sources
      end
    end

    def extract_from_style(remove_style_element = true)
      @document.css('style').inject([]) do |sources, style|
        sources << style.content
        style.remove if remove_style_element
        sources
      end
    end

    def integrate(*sources)
      source = sources.collect {|src| src * $RS}.join($RS)
      source = 'book {}' if source.empty?
      handler = CSSDocumentHandler.new
      CSSPool::SAC::Parser.new(handler).parse(source)
    end

    def basedir
      base = @document.css('base')
      base.empty? ? @basedir : base[0]['href']
    end
  end
end
