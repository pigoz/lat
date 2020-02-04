# frozen_string_literal: true

module Lat
  class Mpv
    attr_reader :mpv

    def self.test_instance
      new(user_args: %w[--no-config], klass: MPV::Session)
    end

    def initialize(user_args: [], klass: MPV::Client)
      @mpv = klass.new(user_args: user_args)
      @mpv.callbacks << method(:observe_callback)
      @mpv.callbacks << method(:message_callback)
      @id = 1_337
      @observers = {}
      @messages = {}
    end

    def loadfile(path:, options:)
      f = fence('playback-restart')
      mpv.command('loadfile', path, 'replace', options)
      f.wait
    end

    def fence(event)
      Fence.new(mpv) { |d| d.fetch('event') == event }
    end

    def observe_property(property, &block)
      id = (@id += 1)
      @observers[id] = block
      mpv.command('observe_property', id, property)
    end

    def register_message_handler(message, &block)
      @messages[message] = block
    end

    delegate :quit!, :command, :get_property, :set_property, to: :mpv

    private

    ObserverData = S.new(:id, :data, :property)

    def observe_callback(raw)
      event = raw.fetch('event')
      return unless event == 'property-change'

      data =
        ObserverData.new(
          id: raw.fetch('id'),
          data: raw.fetch('data'),
          property: raw.fetch('name')
        )

      @observers.fetch(data.id).call(data)
    end

    def message_callback(raw_data)
      event = raw_data.fetch('event')
      return unless event == 'client-message'

      message = raw_data.fetch('args').first
      return unless message.present?

      @messages.fetch(message).call
    end

    class Fence
      def initialize(mpv, &block)
        @mpv = mpv
        @mutex = Mutex.new
        @resource = ConditionVariable.new
        @block = block
      end

      def wait
        @mpv.callbacks << method(:callback)
        @mutex.synchronize { @resource.wait(@mutex) }
      end

      def callback(data)
        return unless @block.call(data)

        @mutex.synchronize { @resource.signal }
        @mpv.callbacks.delete(method(:callback))
      end
    end
  end
end
