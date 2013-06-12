# Written for Python 2.7
import sys

INFILENAME = "passwords.in"
OUTFILENAME = "passwords.out.inc"


def main():
    with open(INFILENAME, 'r') as infile:
        with open(OUTFILENAME, 'w') as outfile:
            for line in infile:
                outfile.write(process(line))


# Passwords are delta-encoded for some reason
def process(line):
    line = line.strip()
    tagged_line = line + '\x0D\x0F'
    values = []
    previous = '\0'
    for ch in tagged_line:
        values.append(str(ord(ch) - ord(previous)))
        previous = ch
    return "; {0}\nDB {1}\n".format(line, ",".join(values))


if __name__ == '__main__':
    sys.exit(main())
