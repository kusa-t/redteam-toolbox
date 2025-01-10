import argparse
import encoder

def main():
    parser = argparse.ArgumentParser(
                    prog='Flounder',
                    description='Text encode/decode utilities')
    parser.add_argument("method", choices=["caesar", "rot13"], help="encode/decode method")
    parser.add_argument("text", help="text to process")
    parser.add_argument("-k", "--key", help="key to use")
    parser.add_argument("-d", "--decode", action="store_true", help="decode mode")

    args = parser.parse_args()

    result = ""
    if args.method == "caesar":
        key = int(args.key)
        result = encoder.caesar(args.text, key, args.decode)
    if args.method == "rot13":
        result = encoder.rot13(args.text)

    print(result)


def banner():
    art = "" \
    "   __====_        _====__    \n"\
    " ./        \/| |\/        \. \n"\
    "< . /        | |        \ . >\n"\
    "  \________/\| |/\________/  \n"\
    "                             \n"\
    "Flounder\n"
    print(art)


if __name__ == "__main__":
    main()