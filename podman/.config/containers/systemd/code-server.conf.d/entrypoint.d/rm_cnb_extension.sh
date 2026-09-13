#!/usr/bin/env bash

export EXT_GROUPS=common,theme,node,go,rust,python

/usr/bin/env bash /usr/local/bin/purge_extensions.sh && /bin/rm -rf /root/.cache/*

ln -s /root/dotfiles/ai/prompts/000-global-rule-for-my-webide_codebuddy.mdc \
  /root/.codebuddy/rules/000-global-rule-for-my-webide_codebuddy.mdc &&
  rm -rf /root/.codebuddy/rules/000-global-rule-for-cnb-webide_codebuddy.mdc
