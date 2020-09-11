# frozen_string_literal: true

module Lat
  class Tts
    def initialize(text)
      tts_hints = ENV.fetch('TTS_HINTS', '').split('|')
      @text = tts_hints.reduce(text) { |r, n| r.gsub(*n.split(',')) }
    end

    def call
      path = Tempfile.new(['clip', '.mp3'])
      command = [
        'AWS_PROFILE=polly',
        'aws',
        'polly',
        'synthesize-speech',
        "--output-format",
        "mp3",
        '--voice-id',
        'Mizuki',
        '--text-type',
        'ssml',
        '--text',
        "'<speak>#{@text}</speak>'",
        path.path
      ]
      `#{command.join(" ")}`
      path
    end
  end
end
