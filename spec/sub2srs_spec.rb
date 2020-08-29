# frozen_string_literal: true

require_relative './fixtures/hibike.rb'

RSpec.describe Lat::Sub2srs do
  it 'works on a single file' do
    s = Lat::Sub2srs.new([HIBIKE1])
    p = s.card_data.to_params
    expect(p.keys).to eql(["Source", "Line", "Reading", "Words", "Time", "Sound", "Image"])
    expect(p["Source"]).to eql("hibike.mkv")
    expect(p["Time"]).to eql("72.94")
    expect(p["Line"]).to eql("私ら全国目指してたんじゃないの？")
    expect(p["Reading"]).to eql("私ら 全[ぜん] 国[こく] 目[め] 指[ざ]してたんじゃないの？")
    expect(p["Words"]).to eql(" 全[ぜん] 国[こく] the whole country (P)<br> 目[め] 指[ざ]す to aim at | to have an eye on")
    expect(p["Image"]).to match(%r{<img src=sub2srs-[\w-]+\.jpg>})
    expect(p["Sound"]).to match(%r{\[sound:sub2srs-[\w-]+\.mp3\]})
  end

  it 'handles fields configuration' do
    Lat.with_config_files(Lat.expand_settings_path('share/lat.test.null.yaml')) do
      s = Lat::Sub2srs.new([HIBIKE1])
      p = s.card_data.to_params
      expect(p.keys).to eql(["Source", "Question", "Reading", "Words", "Sound"])
      expect(p["Source"]).to eql("hibike.mkv")
      expect(p["Question"]).to eql("私ら全国目指してたんじゃないの？")
      expect(p["Reading"]).to eql("私ら 全[ぜん] 国[こく] 目[め] 指[ざ]してたんじゃないの？")
      expect(p["Words"]).to eql(" 全[ぜん] 国[こく] the whole country (P)<br> 目[め] 指[ざ]す to aim at | to have an eye on")
      expect(p["Sound"]).to match(%r{\[sound:sub2srs-[\w-]+\.mp3\]})
    end
  end
end
