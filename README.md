# LaT
## Overview
**La**nguage **T**ools is a set of tools to automate language acquisition through immersion. Includes sentence analysis (from books, subtitles) and Anki cards creation.

## Installation
1. Install the required dependencies
- [mpv master](https://aur.archlinux.org/packages/mpv-git/) (the current stable release doesn't have the new scripting interface used here)
- [myougiden](https://aur.archlinux.org/packages/python-myougiden/)
- [mecab](https://aur.archlinux.org/packages/python-mecab/)
- [ffmpeg](https://www.archlinux.org/packages/extra/x86_64/ffmpeg/)
2. Clone this repository
```bash
$ git clone https://github.com/pigoz/lat.git
```
3. Install [Bundler](https://bundler.io/)
```bash
$ gem install bundler
```
4. Run the following to install gems into LaT
```bash
$ cd lat
$ bundle install
```
5. Create symbolic link in mpv script folder

```bash
$ cd
$ mkdir path/to/mpv/scripts #create folder if folder 'scripts' does not exist
$ ln -nfs path/to/lat/bin/lat-mpv path/to/mpv/scripts/lat.run
```
**NOTE** Replace path/to/lat with your actual path to lat folder (the folder that you clone) eg: /home/$user/lat

**NOTE** Replace path/to/mpv with your actual path to [mpv configuration folder](https://wiki.archlinux.org/index.php/Mpv#Configuration) eg: /home/$user/.config/mpv

**NOTE** It is crucial to use absolute path (eg: /home/home/$user/lat) not relative paths (e.g. ~ for home dir) for this to work.

## Configuration
### Anki
Edit these settings to your preference
```bash
 lat/lib/lat/anki.rb
 ```
 ```bash
    ANKI_MEDIA_COLLECTION =
      File.expand_path(
        '~/Library/Application Support/Anki2/User 1/collection.media'
      )
    ANKI_DECK_NAME = 'sub2srs'
    ANKI_NOTE_TYPE = 'Japanese sub2srs'
    ANKI_TAG_NAME = 'sub2srs'
```
 ```bash
    ANKI_MEDIA_COLLECTION =
      File.expand_path(
        '/home/$user/.local/share/Anki2/User 1/collection.media'
      )
    ANKI_DECK_NAME = '🍕日本語::🥇Sentence Mining'
    ANKI_NOTE_TYPE = 'MIA Japanese'
    ANKI_TAG_NAME = 'mpv'
```
**NOTE** Click [here](https://docs.ankiweb.net/#/files?id=file-locations) for more details on Anki media collection folder

**NOTE** To use subdeck in ANKI_DECK_NAME, simply add :: after parent dack (eg: parent deck::sub deck)

**NOTE** Make sure that ANKI_NOTE_TYPE have all the fields need (more on later)

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

### Myougiden
[Install myougiden](https://github.com/melissaboiko/myougiden) if haven't already and you need compile the dictionary database at least once
```bash
$ sudo updatedb-myougiden -f
```
## Improvement from [Mpv-nihongo](https://github.com/pigoz/mpv-nihongo)

- Code is much better, and every part is test driven which makes adding new features easier
- Dictionary access is multithreaded
- Generated furigana matches the sigle Kanji, which results in a much nicer alignment. i.e.: 先[せん] 生[せい] instead of 先生[せんせい]. I have a very visual memory so this helped me immensely, and was the feature I could not add to mpv-nihongo since the code was so bad.
- You can also add stuff to Anki that comes from books (and the code uses TTS to create audio)
