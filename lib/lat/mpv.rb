# frozen_string_literal: true

require 'mpv'

module Lat
  class Mpv
    attr_reader :mpv

    def self.test_instance
      new(MPV::Session.new(user_args: %w[--no-config]))
    end

    def self.client
      new(MPV::Client.new('/tmp/mpv-socket'))
    end

    def initialize(mpv)
      @mpv = mpv
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

    def runloop
      require 'thwait'
      client = mpv.respond_to?(:client) ? mpv.client : mpv
      thnames = %w[@command_thread @results_thread @events_thread]
      threads = thnames.map { |iv| client.instance_variable_get(iv) }
      ThreadsWait.new(*threads).join
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

    def message(message)
      style = { fs: 14, bord: 1, '1c': '&HFFFFFF&', '3c': '&H000000&' }
      style = style.map { |k, v| "{\\#{k}#{v}}" }.join
      @mpv.command('osd-overlay', 0, 'ass-events', [style, message].join)
    end

    def clear_message
      @mpv.command('osd-overlay', 0, 'none')
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
