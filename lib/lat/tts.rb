# frozen_string_literal: true

module Lat
  class Tts
    def initialize(text)
      @text = text
    end

    def call
      path = Tempfile.new(['clip', '.mp3'])
      IO.write(path, tts.audio_content)
      path
    end

    private

    def tts
      require 'google/cloud/text_to_speech'
      Google::Cloud::TextToSpeech.new.synthesize_speech(
        { text: @text },
        { language_code: 'ja-JP', name: 'ja-JP-Wavenet-D' },
        audio_encoding: 'MP3', pitch: 0, speaking_rate: 0.95
      )
    end
  end
end
