#!/usr/bin/env python
# Written for Python 3.4
import argparse
import struct
import sys


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    parser = argparse.ArgumentParser(description="Rip graphics from an Animal Land ROM.")
    parser.add_argument('romname')
    parser.add_argument('offset')
    parser.add_argument('outname')
    args = parser.parse_args(argv)
    romname = args.romname
    offset = int(args.offset, 16)
    outname = args.outname
    with open(romname, 'rb') as romfile:
        logname = outname + ".log"
        with open(logname, 'w') as logfile:
            print("Dump of image at {:05X}".format(offset), file=logfile)
            romfile.seek(offset)
            img_size = struct.unpack('<H', romfile.read(2))[0]
            print("Compressed size (incl. header):", img_size, "bytes", file=logfile)
            for i in range(1, 5):
                stream_header = romfile.read(1)[0]
                print("Stream", i, "header:", "{:02X}".format(stream_header), file=logfile)
                stream_outname = outname + "." + str(i) + ".bin"
                with open(stream_outname, 'wb') as outfile:
                    decodeRLE(romfile, outfile)
            # Assume the rest is the tilemap
            map_size = img_size - (romfile.tell() - offset)
            map_outname = outname + ".map"
            with open(map_outname, 'wb') as outfile:
                outfile.write(romfile.read(map_size))


def decodeRLE(infile, outfile):
    while True:
        v = infile.read(1)[0]
        if v == 0:
            break
        count = v & 0x7f
        if v & 0x80:
            # Copy bytes verbatim
            for i in range(count):
                byte = infile.read(1)
                outfile.write(byte)
        else:
            # Handle run length
            value_to_repeat = infile.read(1)
            outfile.write(value_to_repeat * count)


if __name__ == '__main__':
    sys.exit(main())
