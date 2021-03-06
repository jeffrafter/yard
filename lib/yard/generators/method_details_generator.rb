module YARD
  module Generators
    class MethodDetailsGenerator < MethodListingGenerator
      before_generate :is_namespace?
      before_generate :has_methods?

      def sections_for(object)
        [
          :header, 
          [ # with MethodObject
            :method_header,
            G(MethodGenerator),
          ]
        ]
      end
    end
  end
end