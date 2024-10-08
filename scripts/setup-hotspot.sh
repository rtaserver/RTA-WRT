#!/bin/sh

# Auto Script Install Radius Monitor + Database + Mysql
# By Mutiara-Wrt | Maizil

# RTA-WRT
# RizkiKotet

#===========================================================================================================================
# CMD Install
cmdinstall() {
local MAX_TIME=60
while true; do
  local start_time=$(date +%s)
  echo "Notes: $2 ..."
  echo "Mohon Tunggu Sebentar.."
  echo "Pastikan koneksi internet lancar.."
  local output=$($1 2>&1)
  local exit_code=$?
  local end_time=$(date +%s)
  local elapsed_time=$((end_time - start_time))
  if [ $exit_code -eq 0 ]; then
    if [ $elapsed_time -gt $MAX_TIME ]; then
      echo "${2} berhasil, tapi koneksi lambat (waktu: ${elapsed_time}s)."
    else
      echo "${2} berhasil."
    fi
    sleep 3
    clear
    break
  else
    if [ $elapsed_time -gt $MAX_TIME ]; then
      echo "${2} gagal, mungkin karena koneksi lambat (waktu: ${elapsed_time}s). Mengulangi..."
    else
      echo "${2} gagal. Mengulangi..."
    fi
    echo "Log kesalahan:"
    echo "$output"
    sleep 2
    clear
  fi
  sleep 5
done
}

clone_gh() {
    local REPO_URL="$1"
    local BRANCH="$2"
    local TARGET_DIR="$3"
    rm -rf $TARGET_DIR
    echo "Cloning repository..."
    cmdinstall "git clone -b $BRANCH $REPO_URL $TARGET_DIR" "Clone Repo"
}

clone_gh "https://github.com/Maizil41/RadiusMonitor.git" "main" "files/www/RadiusMonitor"
clone_gh "https://github.com/Maizil41/radiusbilling.git" "main" "files/www/raddash"
cmdinstall "wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip" "Download PhpMyAdmin"
cmdinstall "unzip phpMyAdmin-5.2.1-all-languages.zip" "Mengekstrak Bahan"
rm -rf phpMyAdmin-5.2.1-all-languages.zip
mv phpMyAdmin-5.2.1-all-languages files/www/phpmyadmin