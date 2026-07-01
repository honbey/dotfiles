#!/usr/bin/env bash

if [[ "$1" == "cn" ]]; then
  curl -fOL https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/cn_dicts/8105.dict.yaml
  curl -fOL https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/cn_dicts/base.dict.yaml
  curl -fOL https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/cn_dicts/others.dict.yaml
elif [[ "$1" == "en" ]]; then
  curl -fOL https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/en_dicts/cn_en.txt
  curl -fOL https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/en_dicts/en.dict.yaml
  curl -fOL https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/en_dicts/en_ext.dict.yaml
else
  echo "error - \$1: cn / en"
  exit
fi
