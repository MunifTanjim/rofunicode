#!/usr/bin/env bash

set -e

ROFUNICODE_EMOJI_MODIFIER_BASE="☝⛹✊✋✌✍🎅🏂🏃🏄🏇🏊🏋🏌👂👃👆👇👈👉👊👋👌👍👎👏👐👦👧👨👩👪👫👬👭👮👯👰👱👲👳👴👵👶👷👸👼💁💂💃💅💆💇💏💑💪🕴🕵🕺🖐🖕🖖🙅🙆🙇🙋🙌🙍🙎🙏🚣🚴🚵🚶🛀🛌🤌🤏🤘🤙🤚🤛🤜🤝🤞🤟🤦🤰🤱🤲🤳🤴🤵🤶🤷🤸🤹🤼🤽🤾🥷🦵🦶🦸🦹🦻🧍🧎🧏🧑🧒🧓🧔🧕🧖🧗🧘🧙🧚🧛🧜🧝🫃🫄🫅🫰🫱🫲🫳🫴🫵🫶🫷🫸"

ROFUNICODE_CACHE_DIR="${XDG_CACHE_HOME:-"${HOME}/.cache"}/rofunicode"
ROFUNICODE_CONFIG_DIR="${XDG_CONFIG_HOME:-"${HOME}/.config"}/rofunicode"
ROFUNICODE_CONFIG_FILE="${ROFUNICODE_CONFIG_DIR}/config.sh"
ROFUNICODE_THEME_FILE="${ROFUNICODE_CONFIG_DIR}/theme.rasi"

function ensure_dir() {
  if [ ! -d "${1}" ]; then
    mkdir -p "${1}"
  fi
}

function file_exists() {
  test -f "${1}"
}

function ensure_config() {
  if ! file_exists "${ROFUNICODE_CONFIG_FILE}"; then
    cat > "${ROFUNICODE_CONFIG_FILE}" <<EOL
#!/usr/bin/env sh

export ROFUNICODE_DATA_FILENAMES="emojis"
export ROFUNICODE_PROMPT="Emoji"
export ROFUNICODE_SKIN_TONE="neutral" # neutral/light/medium-light/medium/medium-dark/dark
EOL
  fi
}

function ensure_theme() {
  if ! file_exists "${ROFUNICODE_THEME_FILE}"; then
    cat > "${ROFUNICODE_THEME_FILE}" <<EOL
listview {
  cycle: true;
  scrollbar: true;
  columns: 10;
  lines: 10;
}
EOL
  fi
}

function accepts_skin_tone_modifier() {
  echo -n "${ROFUNICODE_EMOJI_MODIFIER_BASE}" | grep -q "${1}"
}

function apply_skin_tone_modifier() {
  local -r emoji="${1}"
  local -r skin_tone="${2:-"neutral"}"
  case "${skin_tone}" in
    light) echo -n "${emoji}" | sed 's/./&🏻/1';;
    medium-light) echo -n "${emoji}" | sed 's/./&🏼/1';;
    medium) echo -n "${emoji}" | sed 's/./&🏽/1';;
    medium-dark) echo -n "${emoji}" | sed 's/./&🏾/1';;
    dark) echo -n "${emoji}" | sed 's/./&🏿/1';;
    *) echo -n "${emoji}";;
  esac
}

function rofunicode() {
  local data_filenames
  IFS=',' read -r -a data_filenames <<< "${ROFUNICODE_DATA_FILENAMES:-"emojis"}"
  local -r prompt="${ROFUNICODE_PROMPT:-"Emoji"}"
  local -r skin_tone="${ROFUNICODE_SKIN_TONE:-""}"

  local data_files=()

  for data_filename in "${data_filenames[@]}"; do
    local -r data_file="${ROFUNICODE_CACHE_DIR}/${data_filename}.txt"
    local -r data_url="https://raw.githubusercontent.com/MunifTanjim/rofunicode/master/data/${data_filename}.txt"

    if [ ! -f "${data_file}" ]; then
      curl -LsSf -o "${data_file}" "${data_url}"
    fi

    data_files+=("${data_file}")
  done

  if (("${#data_files[@]}" == 0)); then
    echo "no data_files!"
    exit 1
  fi

  local rofi_version="$(rofi -version)"

  local selection

  if [[ "${rofi_version}" == *"1.7."* ]]; then
    selection=$(cat "${data_files[@]}" | rofi -dmenu -markup-rows -i -theme-str "@import \"${ROFUNICODE_THEME_FILE}\"" -p "${prompt}" | awk '{ print $NF }' | tr -d '\n')
  else
    selection=$(cat "${data_files[@]}" | rofi -dmenu -markup-rows -i -columns 10 -lines 10 -p "${prompt}" | awk '{ print $NF }' | tr -d '\n')
  fi

  if accepts_skin_tone_modifier "${selection}"; then
    selection=$(apply_skin_tone_modifier "${selection}" "${skin_tone}")
  fi

  echo -n "${selection}"
}

ensure_dir "${ROFUNICODE_CACHE_DIR}"
ensure_dir "${ROFUNICODE_CONFIG_DIR}"
ensure_config
ensure_theme

source "${ROFUNICODE_CONFIG_FILE}"

rofunicode
