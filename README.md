# LaT
## Overview
**La**nguage **T**ools is a set of tools to automate language acquisition through immersion. Includes sentence analysis (from books, subtitles) and Anki cards creation.

<img src="https://i.imgur.com/yAaw7hZ.png" width="400" title="subs2srs">  <img src="https://i.imgur.com/ZmEWgGU.jpg" width="500" title="jplookup">

## Installation
1. Install the required dependencies
- [mpv master](https://aur.archlinux.org/packages/mpv-git/) (the current stable release doesn't have the new scripting interface used here)
- [myougiden](https://aur.archlinux.org/packages/python-myougiden/)
- [mecab](https://aur.archlinux.org/packages/python-mecab/)
- [ffmpeg](https://www.archlinux.org/packages/extra/x86_64/ffmpeg/)
- [ruby](https://www.archlinux.org/packages/extra/x86_64/ruby/)

2. Install [Bundler](https://bundler.io/)
```bash
$ gem install bundler
```

3. Clone repository and install dependencies
```bash
$ git clone https://github.com/pigoz/lat.git
$ cd lat
$ bundle install
```

4. Create symbolic link in mpv script folder
```bash
$ ln -nfs bin/lat-mpv path/to/mpv/scripts/lat.run
```

**NOTE** Replace path/to/mpv with your actual path to [mpv configuration folder](https://wiki.archlinux.org/index.php/Mpv#Configuration) eg: /home/$USER/.mpv

## Configuration
You have to create a config file at `~/lat.yaml`. Example config file:

```yaml
anki:
  collection: ~/Library/Application Support/Anki2/User 1
  export:
    deck_name: sub2srs
    tag_name: sub2srs
    note_type: Japanese sub2srs

blacklist:
  morphemes:
    active: false
    fields:
      - note_type: Japanese sub2srs
        field_name: Line
  files:
    - share/blacklist.txt                                   
```
**NOTE** Click [here](https://docs.ankiweb.net/#/files?id=file-locations) for more details on Anki media collection folder

**NOTE** To use subdecks in `anki.export.deck_name`, simply add `::` after parent deck (eg: `Japanese::sub2srs`)

**NOTE** Make sure that `anki.export.note_types` has all the fields needed `Source, Line, Reading, Words, Time, Sound, Image` (more on later)

```bash
 lat/lib/lat/anki.rb
 ```
```bash
    class CardData
      def to_params
        result = {
          Source: source,
          Line: line,
          Reading: reading,
          Words: words.join('<br>')
        }
        result[:Time] = time if time
        result[:Sound] = "[sound:#{File.basename(sound)}]" if sound
        result[:Image] = "<img src=#{File.basename(image)}>" if image
        result
      end
```
```bash
    class CardData
      def to_params
        result = {
          Expression: line,
          Reading: reading
        }
        result[:Audio] = "[sound:#{File.basename(sound)}]" if sound
        result[:Image] = "<img src=#{File.basename(image)}>" if image
        result
      end
```
**NOTE** Rename and remove any fields you want. Make sure that the note type have all these fields.
**TODO** Make this configurable

### Myougiden
[Install myougiden](https://github.com/melissaboiko/myougiden) if haven't already and you need compile the dictionary database at least once
```bash
$ sudo updatedb-myougiden -f
```

## Improvement from [mpv-nihongo](https://github.com/pigoz/mpv-nihongo)

- Code is much better, and every part is test driven which makes adding new features easier
- Dictionary access is multithreaded
- Generated furigana matches the sigle Kanji, which results in a much nicer alignment. i.e.: 先[せん] 生[せい] instead of 先生[せんせい]. I have a very visual memory so this helped me immensely, and was the feature I could not add to mpv-nihongo since the code was so bad.
- You can also add stuff to Anki that comes from books (and the code uses TTS to create audio)
- Blacklist based on your subs2srs deck
