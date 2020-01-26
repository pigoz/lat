module Lat
  module Factory
    extend ActiveSupport::Concern

    class_methods do
      def get(iso2)
        Kernel.const_get("#{name}#{iso2.capitalize}")
      end
    end
  end
end
