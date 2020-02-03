# frozen_string_literal: true

module Lat
  class Mpv
    attr_reader :mpv

    def self.test_instance
      new(user_args: %w[--no-config], klass: MPV::Session)
    end

    def initialize(user_args: [], klass: MPV::Client)
      @mpv = klass.new(user_args: user_args)
    end

    def loadfile(path:, options:)
      WaitFor.new(mpv, 'playback-restart').call do
        mpv.command('loadfile', path, 'replace', options)
      end
    end

    delegate :quit!, :get_property, to: :mpv

    class WaitFor
      def initialize(mpv, event_name)
        @mpv = mpv
        @event_name = event_name
        @mutex = Mutex.new
        @resource = ConditionVariable.new
      end

      def call(&block)
        @mpv.callbacks << method(:callback)
        block.call
        @mutex.synchronize { @resource.wait(@mutex) }
        @mpv.callbacks.delete(method(:callback))
      end

      def callback(data)
        event = data.fetch('event')
        @mutex.synchronize { @resource.signal } if event == @event_name
      end
    end
  end
end
