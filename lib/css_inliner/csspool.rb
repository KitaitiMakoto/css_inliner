# Extensions for CSSPool
require 'csspool'

module CSSPool
  class Visitors::ToCSS
    alias visit_CSSInliner_CSSDocument visit_CSSPool_CSS_Document
  end
end
