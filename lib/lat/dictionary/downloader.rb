# frozen_string_literal: true

module Lat
  module Dictionary
    class Downloader
      def initialize(url:, dst:)
        @url = url
        @dst = dst
      end

      def call
        return dst if File.exist?(dst)

        call!
      end

      def call!
        File.open(dst, 'w') do |local_file|
          URI.open(url, **open_uri_options) do |remote_file|
            # make gzip optional
            local_file.write(Zlib::GzipReader.new(remote_file).read)
          end
        end

        dst
      end

      private

      def dst
        Lat.xdg(:cache, @dst)
      end

      def open_uri_options
        # disable print in test env
        {
          content_length_proc: method(:content_length_cb).to_proc,
          progress_proc: method(:progress_cb).to_proc
        }
      end

      def content_length_cb(content_length)
        require 'ruby-progressbar'
        @progress = ProgressBar.create(
          title: "Downloading #{name}",
          format: '%t: |%B|%j%%',
          total: content_length
        )
      end

      def progress_cb(progress)
        @progress.progress = progress
      end
    end
  end
end
