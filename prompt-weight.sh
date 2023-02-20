#!/usr/bin/env python3
# generate prompt series based on weight values for a select argument

# EXAMPLE: echo 'tech support' | ./prompt-weight.sh -a 'indian' -s 0.2 | ./prompt-weight.sh -a 'asking user to show' -m 1.0 -M 1.0 -[ ', ('  | ./prompt-weight.sh -[ '' -] ' )'  -a 'bobs and vagene' > output.txt

import argparse
import os
import sys
from typing import Optional, List


# initialize arguments
def args_prompt() -> Optional[ List[str] ]:
    piped = sys.stdin.buffer.read()
    if piped and len(piped) > 0:
        # print("split:", piped.decode().strip().split('\n'), file=sys.stderr)
        return piped.decode().strip().split('\n')
    return None


def args_parse(flag_piped: bool = False):
    parser = argparse.ArgumentParser()
    if flag_piped is False:
        parser.add_argument('prompt', default=None, help='constant prompt string', type=str)
    parser.add_argument('-a', '--arg', help='prompt argument string', type=str)
    #parser.add_argument('-d', '--delim', default=',', help='prompt delimiter symbol', type=str)
    parser.add_argument('-[', '--prefix', default=',', help='prompt prefix string', type=str)
    parser.add_argument('-]', '--postfix', default='', help='prompt prefix string', type=str)
    parser.add_argument('-f', '--fix', default=False, help='replace _ with space', type=bool)
    parser.add_argument('-m', '--min', default=0.5, help='minimum argument weight', type=float)
    parser.add_argument('-M', '--max', default=1.5, help='maximum argument weight', type=float)
    parser.add_argument('-s', '--step', default=0.1, help='argument weight step', type=float)
    return parser.parse_args()


def frange(min: float, max: float, step: float = 0.1) -> List[float]:
    mult = 1E6  # constant multiplier
    func = lambda fx: int(fx * mult)
    r = range(int(min * mult), int(max * mult) + 1, int(step * mult))
    return list(map(lambda ix: float(ix / mult), list(r) ))


# main processing method
def process(args, prompt = None):
    assert(args.min >= 0 and args.min <= args.max)
    assert(args.max >= 0 and args.max <= 2.0)
    assert(args.step >= 0)
    assert(type(args.arg) is str and len(args.arg) > 0)
    
    # check when weights minimum == maximum
    weight_list = [ args.min ]
    if abs(args.max - args.min) > 1e-5:
        assert(args.step <= (args.max - args.min))
        weight_list = frange(args.min, args.max, args.step)
    
    prompt = prompt if prompt is not None else args.prompt
    prompt = list(prompt) if type(prompt) is str else prompt
    assert(type(prompt) is list and len(prompt) >= 0)
    
    # print the resulting prompt series
    for line in prompt:
        for weight in weight_list:
            s: str = f'{line}{args.prefix} ({args.arg}:{weight}){args.postfix}'
            s = s.replace('_', ' ') if args.fix is True else s
            print(s)


if __name__ == '__main__':
    # prompt string can be omitted only if you are using a pipe
    prompt = args_prompt()
    args = args_parse(True if type(prompt) is list else False)
    process(args, prompt if prompt else None)
