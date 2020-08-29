# LaT
## Overview
**La**nguage **T**ools is a set of tools to automate language acquisition through immersion. Includes sentence analysis (from books, subtitles) and Anki cards creation. A screenshot is worth a lot more than words, so here's two screenshots:

### Automatic anki card creation
<img src="https://user-images.githubusercontent.com/24681/91639632-42db3b80-ea18-11ea-8350-6d226ebc78e9.png" width="400" title="subs2srs">

### Words lookup inside mpv
<img src="https://user-images.githubusercontent.com/24681/91639666-7d44d880-ea18-11ea-9db9-49310b6432f2.png" width="500" title="jplookup">

## Installation
1. Install the required dependencies
- [mpv master](https://aur.archlinux.org/packages/mpv-git/) (the current stable release doesn't have the new scripting interface used here)
- [myougiden](https://aur.archlinux.org/packages/python-myougiden/) (I'm working on internal dictionaries, but it will take a while)
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

4. Create symbolic link in your mpv scripts folder
```bash
$ ln -nfs bin/lat-mpv ~/.mpv/scripts/lat.run
```

**NOTE** Sometimes the mpv scripts folder might be following the XDG spec and be located in `~/.config/mpv/scripts`

## Configuration
You have to create a config file at `~/lat.yaml`. Example config file:

```yaml
anki:
  collection: ~/Library/Application Support/Anki2/User 1
  export:
    deck_name: sub2srs
    tag_name: sub2srs
    note_type: Japanese sub2srs
  fields:
    source: Source
    line: Line
    reading: Reading
    words: Words
    time: Time
    sound: Sound
    image: Image

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

**NOTE** To not export a field to Anki set it's value to `null`. (eg: `time: null` will skip the time field)

### mpv Bindings

`l` and `GAMEPAD_ACTION_UP` Are bound to the dictionary lookup
`b` triggers card creation mode

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
- Blacklist based on your subs2srs deck (BETA)
