#!/usr/bin/env python3
import sys

def main(argv):
    print(sys.modules)
    site_packages = [p for p in sys.path if p.endswith('site-packages')]
    print(site_packages)

if __name__ == '__main__':
    main(sys.argv)
