module Lat
  class Sub2srs
    Data = S.new(:text, :title, :start, :end, :apath, :aid)

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def call; end

    class NoOp < Sub2srs
      def call; end
    end
  end
end
