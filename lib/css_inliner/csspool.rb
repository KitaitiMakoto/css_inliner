# Extensions for CSSPool
require 'csspool'

module CSSPool
  module Visitors
    class ToCSS
      alias visit_CSSInliner_CSSDocument visit_CSSPool_CSS_Document
    end
  end
end
