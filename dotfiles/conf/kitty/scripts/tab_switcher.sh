#!/usr/bin/env bash
# Tab switcher — tokyonight transparent, matches lazyvim snacks.nvim picker.

if ! command -v jq &>/dev/null; then
  printf '\033[31mjq not found — install: sudo pacman -S jq\033[0m\n'
  read -r; exit 1
fi

R=$'\033[0m'
BLUE=$'\033[38;2;122;162;247m'
CYAN=$'\033[38;2;125;207;255m'
FG=$'\033[1;38;2;192;202;245m'
FG_DIM=$'\033[38;2;169;177;214m'
COMMENT=$'\033[38;2;86;95;137m'

proc_icon() {
  case "${1##*/}" in
    nvim|vim|vi)      printf "" ;;
    zsh|bash|sh|fish) printf "" ;;
    ssh)              printf "󰣀" ;;
    python*)          printf "" ;;
    node|npm|npx|bun) printf "" ;;
    git)              printf "" ;;
    docker*)          printf "󰡨" ;;
    htop|btop|top)    printf "" ;;
    claude)           printf "󰚩" ;;
    *)                printf "󰆍" ;;
  esac
}

raw=$(kitty @ ls 2>/dev/null | jq -r '
  .[] as $win |
  $win.tabs[] as $tab |
  ($win.id | tostring) as $wid |
  ($tab.id | tostring) as $tid |
  ($tab.windows[0].foreground_processes[-1].cmdline[0] // "shell") as $proc |
  "\($tid)\t\($wid)\t\(if ($tab.is_focused // false) then "1" else "0" end)\t\($tab.title // ("Tab "+$tid))\t\($proc)"
')

[[ -z "$raw" ]] && {
  printf '\033[31mNo tabs — is allow_remote_control enabled?\033[0m\n'
  read -r; exit 1
}

# Pass 1: measure actual max column widths and count items
max_title=5
max_pname=3
num_items=0
while IFS=$'\t' read -r tid wid focused title proc; do
  pname="${proc##*/}"
  [[ ${#title} -gt $max_title ]] && max_title=${#title}
  [[ ${#pname} -gt $max_pname ]] && max_pname=${#pname}
  (( num_items++ ))
done <<< "$raw"

# Cap column widths
[[ $max_title -gt 42 ]] && max_title=42
[[ $max_pname -gt 22 ]] && max_pname=22

# Pass 2: build entries — pad plain text first, then wrap in color
entries=""
while IFS=$'\t' read -r tid wid focused title proc; do
  icon=$(proc_icon "$proc")
  pname="${proc##*/}"
  title_p=$(printf "%-${max_title}s" "${title:0:$max_title}")
  pname_p=$(printf "%-${max_pname}s" "${pname:0:$max_pname}")
  if [[ "$focused" == "1" ]]; then
    row="${BLUE}●${R}  ${FG}${title_p}${R}  ${icon} ${CYAN}${pname_p}${R}"
  else
    row="${COMMENT}○${R}  ${FG_DIM}${title_p}${R}  ${icon} ${COMMENT}${pname_p}${R}"
  fi
  entries+="${tid}"$'\t'"${wid}"$'\t'"${row}"$'\n'
done <<< "$raw"

# Window sizing — fit to content
term_lines=${LINES:-$(tput lines 2>/dev/null || echo 40)}
term_cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 120)}

# Horizontal: window = content + fzf overhead
# fzf overhead: border_l(1) + pad_l(2) + ptr(1) + ptr_spc(1) + pad_r(2) + border_r(1) = 8
# content:      dot(1) + 2sp + max_title + 2sp + icon(2) + sp(1) + max_pname = max_title + max_pname + 8
# Note: Nerd Fonts v3 icons are 2 cells wide
window_cols=$(( max_title + max_pname + 8 + 8 ))
h_margin=$(( (term_cols - window_cols) / 2 ))
[[ $h_margin -lt 2 ]] && h_margin=2
H_MARGIN_PCT=$(( h_margin * 100 / term_cols ))

# Vertical: fit to content, centered
# overhead: border(2) + inner-pad(2) + prompt(1) + separator(1) + header(1) + blank(2) = 9
needed_height=$(( num_items + 1 + 9 ))
max_height=$(( term_lines * 80 / 100 ))
[[ $needed_height -gt $max_height ]] && needed_height=$max_height
[[ $needed_height -lt 8 ]]           && needed_height=8
v_margin=$(( (term_lines - needed_height) / 2 ))
[[ $v_margin -lt 1 ]] && v_margin=1
V_MARGIN_PCT=$(( v_margin * 100 / term_lines ))

# Header embedded as first input line so --header-lines=1 renders it through
# the same pointer-gutter path as list items → guaranteed column alignment.
# 3 spaces replace "●  " (indicator + 2sp), 5 spaces replace "  icon(2w) "
hdr_content=$(printf "   %-${max_title}s     %-${max_pname}s" "title" "cmd")
entries="__HDR__"$'\t'"0"$'\t'"${hdr_content}"$'\n'"${entries}"

colors="dark,bg:-1,bg+:#2d3f76,fg:#a9b1d6,fg+:#c0caf5"
colors+=",hl:#7aa2f7,hl+:#7dcfff"
colors+=",border:#414868,label:#bb9af7"
colors+=",prompt:#7aa2f7,pointer:#7dcfff,marker:#bb9af7"
colors+=",info:#565f89,spinner:#7aa2f7,header:#565f89"
colors+=",separator:#414868"

selected=$(
  printf '%s' "$entries" | fzf \
    --ansi \
    --height=100% \
    --margin="${V_MARGIN_PCT}%,${H_MARGIN_PCT}%" \
    --padding=1,2 \
    --layout=reverse \
    --border=rounded \
    --border-label="  tabs " \
    --border-label-pos=3 \
    --prompt="  " \
    --pointer="▌" \
    --marker="┃" \
    --separator="─" \
    --info=hidden \
    --header-lines=1 \
    --delimiter=$'\t' \
    --with-nth=3 \
    --no-sort \
    --color="$colors" \
    --bind="esc:abort,ctrl-c:abort,enter:accept"
)

[[ -z "$selected" ]] && exit 0
tab_id=$(printf '%s' "$selected" | cut -f1)
kitty @ focus-tab --match "id:${tab_id}"
