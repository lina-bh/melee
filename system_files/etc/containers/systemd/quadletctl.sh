#!/bin/sh
quadlet_to_unit() {
  local quadlet="$1"
  local name="${quadlet%.*}"
  local ext="${quadlet#*.}"
  local type="${ext:-container}"
  local suffix
  suffix="$(case "$type" in
*) ;;
esac)"
  printf "%s%s.service" "${name}" "${suffix}"
}

usage() {
  printf 'usage: %s [translate|restart|reload|logs|tail] QUADLET\n' "$0" >&2
  exit 1
}

case "$1" in
  "translate")
    quadlet_to_unit "$2"
    printf "\n"
    ;;
  "restart")
    follow=
    OPTIND=2
    while getopts f opt; do
      case "$opt" in
        "f") follow=1;;
        *) ;;
      esac
    done
    systemctl daemon-reload
    unit="$(quadlet_to_unit "${!OPTIND}")"
    systemctl restart "$unit"
    [ "$follow" = 1 ] && exec journalctl -fu "$unit"
    ;;
  "logs")
    journalctl -Iu "$(quadlet_to_unit "$2")"
    ;;
  "tail")
    journalctl -fu "$(quadlet_to_unit "$2")"
    ;;
  "reload")
    systemctl reload "$(quadlet_to_unit "$2")"
    ;;
  *) usage;;
esac

