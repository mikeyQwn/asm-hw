#!/bin/python

import sys
from typing import Iterable

jmp_conditions = [
    "je",
    "jz",
    "jne",
    "jnz",
    "jg",
    "jnle",
    "jge",
    "jnl",
    "jl",
    "jnge",
    "jle",
    "jng",
    "je",
    "jz",
    "jne",
    "jnz",
    "ja",
    "jnbe",
    "jae",
    "jnb",
    "jb",
    "jnae",
    "jbe",
    "jna",
    "jxcz",
    "jc",
    "jnc",
    "jo",
    "jno",
    "jp",
    "jpe",
    "jnp",
    "jpo",
    "js",
    "jns",
]


def token_in_line(tokens: Iterable[str], s: str) -> bool:
    for token in tokens:
        if token in s:
            return True
    return False


def get_offset(line: str, is_code: bool) -> int:
    TABWIDTH = 4
    stripped = line.strip()
    # Label
    if len(stripped) > 0 and stripped[-1] == ":":
        return TABWIDTH * 0
    if token_in_line(("entry", "format", "section", "include", "macro"), line):
        return TABWIDTH * 0
    if len(stripped) > 0 and stripped[0] == ";":
        return TABWIDTH * 0
    if token_in_line(("invoke", "call", "jmp", "ret", *jmp_conditions), line):
        return TABWIDTH * 1
    return TABWIDTH * 1 if not is_code else TABWIDTH * 2


def format_line(line: str, is_code: bool) -> str:
    return (get_offset(line, is_code) * " ") + line.strip() + "\n"


def main():
    lines = sys.stdin.readlines()
    is_code = False
    for line in lines:
        if "section" in line:
            if ".code" in line:
                is_code = True
            else:
                is_code = False
        print(format_line(line, is_code), end="")


if __name__ == "__main__":
    main()
