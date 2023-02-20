#!/usr/bin/env python3

'''
A helper script for transmuting saved prompt file to
an arguments list readable by SD prompt matrix script

USAGE:
    cat prompt_file.txt | ./convert.sh
    ./convert.sh prompt_file.txt
'''

from pathlib import Path
import re
import sys


def input_read() -> str:
    result: str = ''
    # check if we have a direct pipe input
    piped = sys.stdin.buffer.read()
    if piped and len(piped) > 0:
        result = piped.decode().strip()
    # otherwise try to get a filename to read from
    elif len(sys.argv) > 1:
        fpath = Path(argv[1]).resolve(True)
        if fpath.exists() and fpath.is_file():
            with open(fpath, mode='r', encoding='utf-8') as f:
                result = ' '.join(f.readlines())
        else:
            raise FileNotFoundError(f'invalid file [{fpath}]')
    else:
        print('no data passed into the script')
        raise SystemExit(1)
    
    result = re.sub(r"\s\s+", ' ', result).strip()
    return result


def transform(string: str) -> str:
    pattern: str = '''
    ^(.*)Negative\sprompt:(.*)Steps:\s*(\d+),\s*Sampler:\s*(.+)
    ,\s*CFG\s*scale:\s*(\d+),\s*Seed:\s*(\d+)
    ,\s*Face\s*restoration:\s*([\w\s]+),\s*Size:\s*(\d+)x(\d+)
    ,\s*Model\s*hash:\s*\w+,\s*Model:\s*.+
    '''
    pattern = re.sub(r"\s+", '', pattern).strip()
    
    parsed = re.match(pattern, string)
    if parsed is not None:
        groups = list(filter(None, parsed.groups()))
        groups = list(map(lambda s: s.strip(), groups))
        
        # str: [0, 1, 2] int: [3, 4, 6, 7] bool: [5]
        args = [
            'prompt', 'negative_prompt', 'steps', 'sampler_name',
            'cfg_scale', 'seed', 'restore_faces', 'width', 'height'
        ]
        
        # replace a restore faces string with a boolean
        groups[args.index('restore_faces')] = 'true'
        
        result: str = ''
        for i in range(len(args)):
            result += '--%s \"%s\" ' % (args[i], groups[i])
        return result
    else:
        print(f'could not parse a string [{string}]')
        raise SystemExit(2)


if __name__ == '__main__':
    # get what was piped, parse arguments, transform prompt
    print(transform(input_read()))
