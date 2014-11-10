#!/usr/bin/env python
# Written for Python 2.7
import re
import sys

import chars


INFILENAME = 'animalhack-script.txt'
OUTFILENAME = 'animalhack-script.out.txt'


NEWLINE = '<nl>'
END = '<end>'


class MyError(Exception):
    pass


class State(object):
    def __init__(self):
        self.x = 0
        self.lineno = 0
        self.maxlines = 4
        self.section_name = '(nameless)'


def main():
    state = State()
    with open(INFILENAME, 'r') as infile:
        with open(OUTFILENAME, 'w') as outfile:
            for lineno, line in enumerate(infile):
                line = line.rstrip('\n')
                if line.startswith('#'):
                    if not line.startswith('##'):
                        # Emit all plain Atlas commands
                        outfile.write(line)
                    if line.startswith('#ACTIVETBL'):
                        ...
                    elif line.startswith('##SECTION'):
                        handleSection(line, state)
                    elif line.startswith('##MENUS'):
                        ...
                    elif line.startswith('##DIALOGUE'):
                        ...
                    elif line.startswith('##MAXLINES'):
                        handleMaxLines(line, state)
                elif line.startswith('//') or line == '':
                    # Line is a comment or blank
                    outfile.write(line)
                else:
                    # Line is assumed to be game text
                    handleGameText(line, state, tbl, outfile)


def handleSection(line, state)
    match = re.match(r"^##SECTION\s+(.*)$")
    if match is None
        raise MyError("Invalid syntax for ##SECTION")
    state.section = match.group(1)


def handleMaxLines(line, state):
    match = re.match(r"^##MAXLINES\s+([0-9]+)$")
    if match is None:
        raise MyError("Invalid syntax for ##MAXLINES")
    state.maxlines = int(match.group(1))


def handleGameText(line, state, tbl, outfile):
    chpos = 0
    while chpos < len(line):
        ...


def loadTblFile(filename):
    cp_to_ascii = {}                # cp = codepoint
    ascii_to_cp = {}
    with open(filename, 'r') as f:
        for line in f:
            if line.lstrip() == '':
                continue
            match = re.match(r'^[/*]?([0-9A-Fa-f]+)=(.*)$', line)
            if match is None:
                raise MyError("Invalid line: {0}".format(line))
            cp, ascii = match.group(1, 2)
            if len(cp) not in (2, 4):
                raise MyError("Invalid codepoint; line: {0}".format(line))
            cp = int(cp, 16)
            if cp in cp_to_ascii:
                raise MyError("Multiply defined codepoint; line: {0}".format(line))
            if ascii in ascii_to_cp:
                raise MyError("Multiply defined string; line: {0}".format(line))
            cp_to_ascii[cp] = ascii
            ascii_to_cp[ascii] = cp
    return cp_to_ascii, ascii_to_cp


if __name__ == '__main__':
    sys.exit(main())
