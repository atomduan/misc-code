import ConfigParser
import os
import re

'''
Example:
python config_parser.py service.conf

'''

def get_config(config_file):
    config = ConfigParser.ConfigParser()
    config.read(config_file)
    return config                    

def print_config(key,value):
    print key,value

def main(argv):
    argv.append("service.conf")
    config_file = argv[1]
    configs = get_config(config_file)
    for section_name in configs.sections():
        service_options = configs.options(section_name)

        for service_option in service_options:
            sed_key = section_name + '_' + service_option
            print sed_key, configs.get(section_name, service_option)

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
