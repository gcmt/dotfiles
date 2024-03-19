#!/usr/bin/python -u

import os
import sys
import yaml
import signal
import argparse
import threading
from datetime import datetime
from subprocess import run, PIPE

PID = os.getpid()
SCRIPT_PATH = os.path.realpath(__file__)

WATERING_FILE = "~/Notes/Plants/Schedule.yaml"
PLANTS_GUIDE_FILE = "~/Notes/Plants/Plants.pdf"
PLANTS_WIKI_FILE = "obsidian://open?vault=Notes&file=Plants%2FWiki"

DELAY = 60 * 60

MENU_SEPARATOR = f"<tt><span foreground='#ccc'>{'—' * 30}</span></tt>"
ICON_FONT = "Font Awesome 6 Free"
FG_DIM = "#777777"
FG_DELAY = "#ce7d86"

MENU_CMD = [
    "mouse-menu",
    "-format",
    "p",
    "-width",
    "auto",
    "-markup-rows",
    "-maxlines",
    "30",
]

VIM_CMD = [
    "kitty",
    "--name",
    "floating",
    "-e",
    "nvim",
]


def redraw_handler(signum, frame):
    REDRAW_EVENT.set()


REDRAW_EVENT = threading.Event()
signal.signal(signal.SIGUSR1, redraw_handler)


def span(text, **kwargs):
    attrs = (f"{k}='{v}'" for k, v in kwargs.items() if v)
    return f"<span {' '.join(attrs)}>{text}</span>"


def icon(text, **kwargs):
    return span(text, face=ICON_FONT, **kwargs)


def menu(plants):
    entries = []
    by_delay = lambda p: p["target_watering"] - p["elapsed_watering"]
    for p in sorted(plants, key=by_delay):
        line = ""
        delay = p["elapsed_watering"] > p["target_watering"]
        fg_color = FG_DELAY if delay else ""
        line += span(p["plant"], foreground=fg_color)
        line += span("   -   ", foreground=FG_DIM)
        line += icon("", size="small", foreground=FG_DIM) + "  "
        if p["last_watering"]:
            line += f"{p['elapsed_watering']} "
            line += span(f"({p['target_watering']})", size="small", foreground=FG_DIM)
        else:
            line += "n/a"
        if p["last_fertilizing"]:
            line += span("   -   ", foreground=FG_DIM)
            line += icon("", size="small", foreground=FG_DIM) + "  "
            line += f"{p['elapsed_fertilizing']}"
        line += ""
        entries.append(line)
    entries.append(MENU_SEPARATOR)
    entries.append(span("OPEN GUIDE", size="small"))
    entries.append(span("OPEN WIKI", size="small"))
    try:
        input = "\n".join(entries)
        output = run(MENU_CMD, input=input, stdout=PIPE, encoding="utf8").stdout
    except FileNotFoundError:
        print("i3-tiny-menu not found", sys.stderr)
        sys.exit(1)
    else:
        return output.lower().strip()


def load_file(path):
    today = datetime.today().date()
    with open(os.path.expanduser(path), "r") as f:
        for item in yaml.safe_load(f):
            yield {
                "plant": item["plant"],
                "target_watering": item["target_watering"],
                "last_watering": item["last_watering"],
                "last_fertilizing": item["last_fertilizing"],
                "elapsed_watering": (
                    (today - item["last_watering"]).days if item["last_watering"] else 0
                ),
                "elapsed_fertilizing": (
                    (today - item["last_fertilizing"]).days
                    if item["last_fertilizing"]
                    else 0
                ),
            }


def print_label():
    while True:
        plants = load_file(WATERING_FILE)
        delays = sum(int(p["elapsed_watering"] >= p["target_watering"]) for p in plants)
        label = ""
        if delays:
            label = f" {delays}"
        print(
            f"%{{A1:{SCRIPT_PATH} --edit {PID}:}}%{{A3:{SCRIPT_PATH} --menu:}}{label}%{{A}}%{{A}}"
        )
        REDRAW_EVENT.wait(DELAY)
        REDRAW_EVENT.clear()


def vim_edit(path, caller_pid=None):
    cmd = VIM_CMD + [os.path.expanduser(path)]
    run(cmd, stdout=PIPE, stderr=PIPE)
    if caller_pid is not None:
        os.kill(caller_pid, signal.SIGUSR1)


def xdg_open(path):
    run(["xdg-open", os.path.expanduser(path)])


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_mutually_exclusive_group(required=False)
    parser.add_argument("--edit", type=int)
    parser.add_argument("--menu", action="store_true")
    return parser.parse_args()


def main():
    args = parse_args()
    if args.menu:
        selected = menu(load_file(WATERING_FILE))
        if "guide" in selected:
            xdg_open(PLANTS_GUIDE_FILE)
        elif "wiki" in selected:
            xdg_open(PLANTS_WIKI_FILE)
        elif selected:
            vim_edit(WATERING_FILE)
    elif args.edit:
        vim_edit(WATERING_FILE, caller_pid=args.edit)
    else:
        print_label()


if __name__ == "__main__":
    main()
