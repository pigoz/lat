module Lat
  class Ffmpeg
    def initialize(path:, timings:)
      @path = path
      @timings = timings
    end

    attr_reader :path

    def st
      @timings.first.st
    end

    def ed
      @timings.last.ed
    end

    AUDIO_THRESHOLD = 0.25 # 250ms
    IMAGE_DELAY_PERCENT = 0.08
    IMAGE_WIDTH = 480

    def screenshot
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

    def audio_sample(aid:)
      ss = st - AUDIO_THRESHOLD
      duration = ed - st + AUDIO_THRESHOLD * 2
      output = Dir::Tmpname.create(%w[sub2srs- .mp3]) {}
      command = [
        'ffmpeg',
        '-y',
        '-ss',
        ss,
        '-i',
        path,
        '-t',
        duration,
        '-map',
        "0:a:#{aid - 1}",
        output
      ]
      `#{command.join(' ')}`.strip
      output
    end
  end
end
