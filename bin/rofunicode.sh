#!/usr/bin/env bash

set -e

ROFUNICODE_EMOJI_MODIFIER_BASE="☝⛹✊✋✌✍🎅🏂🏃🏄🏇🏊🏋🏌👂👃👆👇👈👉👊👋👌👍👎👏👐👦👧👨👩👪👫👬👭👮👯👰👱👲👳👴👵👶👷👸👼💁💂💃💅💆💇💏💑💪🕴🕵🕺🖐🖕🖖🙅🙆🙇🙋🙌🙍🙎🙏🚣🚴🚵🚶🛀🛌🤌🤏🤘🤙🤚🤛🤜🤝🤞🤟🤦🤰🤱🤲🤳🤴🤵🤶🤷🤸🤹🤼🤽🤾🥷🦵🦶🦸🦹🦻🧍🧎🧏🧑🧒🧓🧔🧕🧖🧗🧘🧙🧚🧛🧜🧝"

ROFUNICODE_CACHE_DIR="${XDG_CACHE_HOME:-"${HOME}/.cache"}/rofunicode"
ROFUNICODE_CONFIG_DIR="${XDG_CONFIG_HOME:-"${HOME}/.config"}/rofunicode"

function ensure_dir() {
  if [ ! -d "${1}" ]; then
    mkdir -p "${1}"
  fi
}

function file_exists() {
  test -f "${1}"
}

function load_config() {
  local -r config_file="${ROFUNICODE_CONFIG_DIR}/config.sh"

  if ! file_exists "${config_file}"; then
    cat > "${config_file}" <<EOL
#!/usr/bin/env sh

export ROFUNICODE_DATA_FILENAMES="emojis"
export ROFUNICODE_PROMPT="Emoji"
export ROFUNICODE_SKIN_TONE="neutral" # neutral/light/medium-light/medium/medium-dark/dark
EOL
  fi

  . "${config_file}"
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

  local selection

  selection=$(cat "${data_files[@]}" | rofi -dmenu -markup-rows -i -columns 10 -lines 10 -p "${prompt}" | awk '{ print $NF }' | tr -d '\n')

  if accepts_skin_tone_modifier "${selection}"; then
    selection=$(apply_skin_tone_modifier "${selection}" "${skin_tone}")
  fi

  echo -n "${selection}"
}

ensure_dir "${ROFUNICODE_CACHE_DIR}"
ensure_dir "${ROFUNICODE_CONFIG_DIR}"

load_config

rofunicode
