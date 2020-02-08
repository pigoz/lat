# frozen_string_literal: true

require 'mpv'

module Lat
  class Mpv
    attr_reader :mpv, :overlay

    def self.test_instance(**args)
      new(MPV::Session.new(user_args: %w[--no-config]), **args)
    end

    def self.client
      new(MPV::Client.new('/tmp/mpv-socket'))
    end

    def initialize(mpv, spy: nil)
      @mpv = mpv
      @mpv.callbacks << method(:observe_callback)
      @mpv.callbacks << method(:message_callback)
      @id = 1_337
      @observers = {}
      @messages = {}
      @spy = spy
    end

    def client_name
      @client_name ||= @mpv.command('client_name').fetch('data')
    end

    def loadfile(path:, options:)
      lspy = Spy.new { |e| e.fetch('event') == 'playback-restart' }
      callback = lspy.to_proc
      @mpv.callbacks << callback
      mpv.command('loadfile', path, 'replace', options)
      lspy.wait
      @mpv.callbacks.delete(callback)
    end

    def runloop
      require 'thwait'
      client = mpv.respond_to?(:client) ? mpv.client : mpv
      thnames = %w[@command_thread @results_thread @events_thread]
      threads = thnames.map { |iv| client.instance_variable_get(iv) }
      ThreadsWait.new(*threads).join
    end

    def observe_property(property, &block)
      id = (@id += 1)
      @observers[id] = block
      mpv.command('observe_property', id, property)
      id
    end

    def unobserve_property(id)
      mpv.command('unobserve_property', id)
    end

    def register_message_handler(message, &block)
      @messages[message] = block
    end

    def unregister_message_handler(message)
      @messages.delete(message)
    end

    OverlayState = S.new(:style, :message)

    def message(message)
      style = { fs: 24, bord: 1, '1c': '&HFFFFFF&', '3c': '&H000000&' }
      style = style.map { |k, v| "{\\#{k}#{v}}" }.join
      @overlay = OverlayState.new(style: style, message: message)
      @mpv.command('osd-overlay', 0, 'ass-events', [style, message].join)
    end

    def clear_message
      @overlay = nil
      @mpv.command('osd-overlay', 0, 'none', '')
    end

    def register_keybindings(keys, section: nil, flags: 'default', &block)
      section ||= ('a'..'z').to_a.sample(8).join
      namespaced_section = [client_name, section].join('/')
      register_message_handler(section, &block)
      contents = keys.map { |k| "#{k} script-binding #{namespaced_section}" }
      command('define-section', section, contents.join("\n"), flags)
      command('enable-section', section)
      section
    end

    def unregister_keybindings(section)
      command('disable-section', section)
      command('define-section', section, '')
      unregister_message_handler(section)
    end

    def enter_modal_mode(message:, keys:, &block)
      quitter = 'ESC'
      message(message)
      register_keybindings(keys + [quitter], flags: :force) do |event|
        clear_message
        unregister_keybindings(event.section)
        next if event.key == quitter

        block.call(event) if block_given?
      end
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
      signal(event, data)
    end

    KeyEvent = Struct.new(:section, :state, :key, :key2)

    def message_callback(raw_data)
      event = raw_data.fetch('event')
      return unless event == 'client-message'

      message, *args = raw_data.fetch('args')
      return unless message.present?

      if message == 'key-binding'
        message, *args = [args.first, KeyEvent.new(*args.drop(1))]
      end

      @messages.fetch(message).call(*args)
      signal(event, *args)
    end

    def playback_restart_callback(raw_data)
      event = raw_data.fetch('event')
      return unless event == 'playback-restart'

      signal(event)
    end

    def signal(*args)
      @spy&.to_proc&.call(*args)
    end
  end
end
