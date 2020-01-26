# frozen_string_literal: true

class DownloadDatabase
  def call
    data = data_list_to_hash data_to_list download
    IO.write(database_path, data.to_json)
  end

  def download
    # require 'open-uri'
    host = 'https://raw.githubusercontent.com'
    uri = "#{host}/jmettraux/kensaku/master/data/kanjidic.json"
    URI.open(uri, &:read).to_s
  end

  def data_to_list(data)
    data = data.split("\n").map { |x| JSON.parse(x) }
    data.each { |d| Lat.assert { d['ki'].size == 1 } }
    data
  end

  def data_list_to_hash(list)
    Hash[list.map { |k| [k['ki'].first, k['ka']] }]
  end
end
