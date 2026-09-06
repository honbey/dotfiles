#!/bin/usr/env bash

export EXT_GROUPS=ai,common,theme,node,go,rust,python

/bin/usr/env bash /usr/local/bin/purge_extensions.sh && /bin/rm -rf /root/.cache/*
