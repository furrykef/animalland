#!/usr/bin/env python
# Written for Python 3.4
import argparse
import sys


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    parser = argparse.ArgumentParser(description="Compress a file for Animal Land.")
    parser.add_argument('infilename')
    parser.add_argument('outfilename')
    args = parser.parse_args()
    with open(args.infilename, 'rb') as f:
        data = f.read()
    with open(args.outfilename, 'wb') as f:
        f.write(compressRLE(data))


def compressRLE(data):
    outdata = bytearray()
    segment = bytearray()
    it = iter(data)
    for byte in it:
        # Is this byte the same as the last two?
        if bytes([byte])*2 == segment[-2:]:
            # Yes; we have an RLE run
            # First write the pre-RLE data, if any
            add_segment(outdata, segment[:-2])
            # Now write the RLE data
            count = 3
            for byte2 in it:
                if byte2 == byte:
                    count += 1
                    if count == 127:
                        # Write the RLE run and start a new, empty segment
                        outdata += bytes([count, byte])
                        segment = bytearray()
                        break
                else:
                    # Write the RLE run
                    outdata += bytes([count, byte])
                    # Begin new segment
                    segment = bytearray([byte2])
                    break
            else:
                # If we got here, we got to the end of the data during an RLE run
                # Write the RLE run and start a new, empty segment
                outdata += bytes([count, byte])
                segment = bytearray()
        else:
            segment.append(byte)
            if len(segment) == 127:
                # Segment is maximum length; output it and start a new one
                add_segment(outdata, segment)
                segment = bytearray()
    add_segment(outdata, segment)
    outdata.append(0)                       # add terminator
    return outdata


def add_segment(data, segment):
    if len(segment) > 0:
        data.append(0x80 | len(segment))
        data += segment


if __name__ == '__main__':
    sys.exit(main())
