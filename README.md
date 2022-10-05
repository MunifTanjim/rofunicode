# Rofunicode - Unicode Character Picker for Rofi

## Installation

Just download the `rofunicode.sh` script whereever you want and give it executable permission:

```sh
curl --progress-bar https://raw.githubusercontent.com/MunifTanjim/rofunicode/main/bin/rofunicode.sh -o ~/.local/bin/rofunicode.sh
chmod u+x ~/.local/bin/rofunicode.sh
```

**Dependencies**:

- `rofi`
- `bash`
- `curl`
- Unicode Characters supported Fonts

## Configuration

Rofunicode configuration file is located at `~/.config/rofunicode/config.sh`:

```sh
#!/usr/bin/env sh

export ROFUNICODE_DATA_FILENAMES="emojis"
export ROFUNICODE_PROMPT="Emoji"
export ROFUNICODE_SKIN_TONE="dark" # neutral/light/medium-light/medium/medium-dark/dark
```

Rofunicode theme file is located at `~/.config/rofunicode/theme.rasi`:

```rasi
listview {
  cycle: true;
  scrollbar: true;
  columns: 10;
  lines: 10;
}
```

The theme file is used for `rofi v1.7.x`.

## Usage

Run the `rofunicode.sh` script and do whatever you want with the picked unicode character.

```sh
~/.local/bin/rofunicode.sh | xsel -i --clipboard
```

Run the following command to clear cached data:

```sh
~/.local/bin/rofunicode.sh clear-cache
```

## Screenshot

![Emoji Picker](screenshots/emoji-smile.png)

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
