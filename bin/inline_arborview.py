#! /usr/bin/env python
"""
Add data to existing points, generating a page with the data embedded in the HTML page.

Matthew Wells: 2024-01-31
"""

import os
from typing import NamedTuple, List
import logging
import argparse
import sys

class FR_TOKENS(NamedTuple):
    search: str
    replace_value: str

NEWICK_TOKEN = FR_TOKENS(search = "TREE = __DEADBEEF__", replace_value = "__DEADBEEF__")
DATA_TOKEN = FR_TOKENS(search = "DATA = __DEADFOOD__", replace_value = "__DEADFOOD__")
OUTPUT_DIRECTORY = "static"


def read_html(file):

    lines = None

    # Hold a copy of the entire file in memory so that the original data
    # will not be overwritten when inlining values
    with open(file, 'r', encoding='utf8') as js:
        lines = js.readlines()
    return lines


def strip_trailing_lf(text: str):
    """
    Test if newline character exists in text, an removes it if it does.
    This should handle CRLF line endings as well,
    """
    if text.endswith("\n"):
        return text.rstrip()
    return text

def find_and_replace_text(lines: List[str], tsv_data: str, newick_data: str):
    data_found = False
    tree_found = False

    html_text = iter(lines)
    idx = 0
    while not data_found or not tree_found:
        try:
            line = next(html_text)
        except StopIteration:
            # ! TODO throw errors for tokens not being found
            break
        else:
            if tree := NEWICK_TOKEN.search in line:
                tree_found = tree
                lines[idx] = line.replace(NEWICK_TOKEN.replace_value, f"\"{newick_data}\"")
            elif data := DATA_TOKEN.search in line:
                data_found = data
                lines[idx] = line.replace(DATA_TOKEN.replace_value, f"\"{strip_trailing_lf(tsv_data)}\"")
            idx += 1
    return lines

def output_static_file(lines: List[str], path: str):
    """
    Output the modified html file to a standard place
    """
    with open(path, 'w', encoding='utf8') as html_out:
        html_out.write("".join(lines))


def read_tsv(file):
    data = None
    with open(file, 'rb') as context_data:
        data = context_data.read().replace(b"\r\n", b"\\n").replace(b"\n", b"\\n").replace(b"\t", b"\\t").decode("utf-8").replace('"', "'")
    return data

def read_nwk(file):
    data = None
    with open(file, 'rb') as context_data:
        data = context_data.read().replace(b"\r\n", b"\\n").replace(b"\n", b"\\n").decode("utf-8").replace('"', "'")

    return strip_trailing_lf(data)


if __name__ == "__main__":
    output_file_name = "ArborView_static.html"
    parser = argparse.ArgumentParser(
        prog="ArborView Fillin",
        description="Embeds the newick file and tabular data directly in ArborView. Eliminating the need for user data upload.",
    )
    source_home = os.path.dirname(os.path.dirname(__file__))
    HTML_file = os.path.join(source_home , "html", "table.html")

    parser.add_argument("-d", "--metadata", help="Path to a tsv file containing contextual data relevant to your newick formatted file.")
    parser.add_argument("-n", "--newick", help="Path to your newick formatted file.")
    parser.add_argument("-o", "--output", help="An optional argument of what to name your outputted file. Make sure your output directory exists",
                        default=f"{OUTPUT_DIRECTORY}/{output_file_name}", required=False)
    parser.add_argument("-t", "--template", help=f"Path to the ArborView HTML", default=HTML_file)
    args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG)
    if args.template != HTML_file:
        HTML_file = args.template

    logging.info(f"Reading template file {HTML_file}")
    lines = read_html(HTML_file)

    #logging.info(f"Updating tree and table information.")
    logging.info(f"Reading TSV file.")
    #tsv_data = "h1\\th2\\nv1\\tv2\\nb1\\tb2\\n"
    tsv_data = read_tsv(args.metadata)
    #nwk_data = "(v1:1(b1))"
    nwk_data = read_nwk(args.newick)
    modified_text = find_and_replace_text(lines, tsv_data=tsv_data, newick_data=nwk_data)

    if args.output:
        output_file = args.output
    else:
        output_file = os.path.join(source_home, OUTPUT_DIRECTORY, output_file_name)

    logging.info(f"Creating new HTML file in {output_file}")
    output_static_file(modified_text, output_file)
    logging.info(f"Finished.")
