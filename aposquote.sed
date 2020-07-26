#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-
s~'+~\n&~g
s~\n('{2,})~'"\1"'~g
s~\n'~'\\''~g
s~\n'*~##_QUOTE_ERROR_##~g
s~^~'~;s~^'{2}~~
s~$~'~;s~'{2}$~~
