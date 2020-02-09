module Lat
  class Sub2srs
    Data = S.new(:text, :title, :sub_start, :sub_end, :apath, :aid)

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def call; end

    CardData = S.new(:source, :time, :sound, :image, :line, :reading, :words)

    AUDIO_THRESHOLD = 0.25 # 250ms
    IMAGE_DELAY_PERCENT = 0.08
    IMAGE_WIDTH = 480

    def card_data
      first = data.first
      line = data.map(&:text).join
      lexer = Lat::Lexer.new
      lexer_results = lexer.call(line)
      reading = lexer.to_text(lexer_results)
      words = lexer.to_definitions(lexer_results).join('<br />')
      CardData.new(
        line: line,
        reading: reading,
        sound: 'a.mp3',
        image:
          screenshot(path: first.apath, st: first.sub_start, ed: first.sub_end),
        words: '',
        source: data.first.title,
        time: data.first.sub_start.to_s
      )
    end

    def screenshot(path:, st:, ed:)
      ss = st + (ed - st) * IMAGE_DELAY_PERCENT
      output = Dir::Tmpname.create(%w[sub2srs- .jpg]) {}
      command = [
        'ffmpeg',
        '-y',
        '-ss',
        ss,
        '-i',
        path,
        '-vcodec',
        'mjpeg',
        '-vframes',
        '1',
        '-filter:v',
        "scale=#{IMAGE_WIDTH}:-1",
        output
      ]
      `#{command.join(' ')}`.strip
      output
    end

    class NoOp < Sub2srs
      def call; end
    end
  end
end
