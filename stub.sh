#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
declare -A CFG=(


#=== Config starts here ===#
# For descriptions of the available settings, please refer to cfg.defaults.rc.

[share_sh_path]='webgit-easycgi-pmb/../../share.sh'


#=== Config ends here ===#

) && source -- "${CFG[share_sh_path]}"; exit $?
