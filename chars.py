#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Written for Python 3.4
import sys


CHAR_WIDTHS_FILENAME = 'char_widths.out.bin'


CHAR_WIDTHS = [
#       [the digits and period here are bold]
#       0  1  2  3  4  5  6  7  8  9  .  *  “
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 3, 4, 5, 0, 0, 0,

#       [first char here is <mnl> ("menu newline") control code]
#       [displays as space when not in a menu]
        3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

#       [first char here is space]
#       [asterisk in this row is not the one we use]
#          !  ”     $  %  &  '  (  )  *  +  ,  -  .  /
        3, 2, 5, 0, 6, 6, 6, 3, 3, 3, 6, 6, 3, 5, 2, 4,

#       0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
        5, 3, 6, 6, 6, 6, 6, 6, 6, 6, 2, 3, 6, 6, 6, 6,

#       @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
        6, 6, 6, 6, 6, 5, 5, 6, 6, 2, 5, 5, 5, 6, 6, 6,

#       P  Q  R  S  T  U  V  W  X  Y  Z  [  ¥  ]  ^  _
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,

#       `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
        6, 5, 5, 5, 5, 5, 4, 5, 5, 2, 3, 5, 2, 6, 5, 5,

#       p  q  r  s  t  u  v  w  x  y  z  {  |  }
        5, 5, 4, 5, 4, 5, 5, 6, 5, 5, 5, 6, 6, 6, 0, 0,

#       [first char here is the odd "N"-like character]
#       [after skipping a control code, next 5 are "PRESS SPACE"]
        7, 0, 8, 8, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0,

#       [monospace font for passwords]
#          A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
        0, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,

#       P  Q  R  S  T  U  V  W  X  Y  Z
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 0, 0, 0, 0, 0,

#       [bold font]
#       A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P
        7, 7, 7, 7, 6, 6, 7, 7, 3, 6, 6, 6, 7, 7, 7, 7,

#       Q  R  S  T  U  V  W  X  Y  Z  :  ?
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 3, 7, 0, 0, 0, 0,

        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

#       a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p
        6, 6, 6, 6, 6, 5, 6, 6, 3, 4, 6, 3, 7, 6, 6, 6,

#       q  r  s  t  u  v  w  x  y  z
        6, 5, 6, 5, 6, 6, 7, 6, 6, 6, 0, 0, 0, 0, 0, 0
]


def main():
    with open(CHAR_WIDTHS_FILENAME, 'wb') as f:
        for char_width in CHAR_WIDTHS:
            f.write(bytes([char_width]))


if __name__ == '__main__':
    sys.exit(main())
