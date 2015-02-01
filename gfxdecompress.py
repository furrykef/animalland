#!/usr/bin/env python
# Written for Python 3.4
import sys


def main():
    iterator = iter(sys.stdin.buffer.read())
    pos = 0
    for v in iterator:
        pos += 1
        if v == 0:
            break
        count = v & 0x7f
        if v & 0x80:
            # Copy bytes verbatim
            for i in range(count):
                byte = bytes([next(iterator)])
                pos += 1
                sys.stdout.buffer.write(byte)
        else:
            # Handle run length
            value_to_repeat = bytes([next(iterator)])
            pos += 1
            for i in range(count):
                sys.stdout.buffer.write(value_to_repeat)
    print("Position:", pos, file=sys.stderr)


if __name__ == '__main__':
    sys.exit(main())
