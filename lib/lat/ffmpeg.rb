# frozen_string_literal: true

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
        escape_path(path),
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
        escape_path(path),
        '-t',
        duration,
        '-map',
        "0:a:#{aid - 1}",
        '-ac',
        '2',
        '-codec:a',
        'libmp3lame',
        '-q:a',
        '0',
        '-af',
        '"loudnorm=I=-16:TP=-2:LRA=11"',
        output
      ]
      `#{command.join(' ')}`.strip
      output
    end

    def escape_path(path)
      "\"#{path}\""
    end
  end
end
