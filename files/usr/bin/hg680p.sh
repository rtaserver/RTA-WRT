#!/bin/bash

# HG680P GPIO Wrapper
# by Adi Putra


if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

GPIO="/sys/class/gpio"

function dual_general() {
  pin_on="${2}"
  pin_off="${3}"
  # initialize gpio
  echo "${pin_on}" > "${GPIO}/export"
  echo "${pin_off}" > "${GPIO}/export"
  echo out > "${GPIO}/gpio${pin_on}/direction"
  echo out > "${GPIO}/gpio${pin_off}/direction"
  case "${1}" in
    "on")
      echo 0 > "${GPIO}/gpio${pin_off}/value"
      echo 1 > "${GPIO}/gpio${pin_on}/value"
      ;;
    "off")
      echo 0 > "${GPIO}/gpio${pin_on}/value"
      echo 1 > "${GPIO}/gpio${pin_off}/value"
      ;;
    "warn")
      echo 0 > "${GPIO}/gpio${pin_on}/value"
      echo 1 > "${GPIO}/gpio${pin_off}/value"
      ;;
    "dis")
      echo 0 > "${GPIO}/gpio${pin_on}/value"
      echo 0 > "${GPIO}/gpio${pin_off}/value"
      ;;
  esac
}

function power() {
  pin_on="425"
  pin_off="426"
  dual_general "${1}" "${pin_off}" "${pin_on}"
}

function lan() {
  pin_on="510"
  pin_off="506"
  dual_general "${1}" "${pin_on}" "${pin_off}"
}

function usb() {
  pin_usb="505"
  # initialize gpio
  echo "${pin_usb}" > "${GPIO}/export"
  echo out > "${GPIO}/gpio${pin_usb}/direction"
  case "${1}" in
    "reset")
      echo 0 > "${GPIO}/gpio${pin_usb}/value"
      sleep 1
      echo 1 > "${GPIO}/gpio${pin_usb}/value"
      ;;
  esac
}

function usage() {
  cat <<EOF
Usage:
  -power  [on, off, warn, dis]
  -lan    [on, off, warn, dis]
  -usb    [reset]
EOF
}

case "${1}" in
  -power)
    power "${2}"
    ;;
  -lan)
    lan "${2}"
    ;;
  -usb)
    usb "${2}"
    ;;
  *)
    usage
    ;;
esac