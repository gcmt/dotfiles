#!/usr/bin/env python

import os
import re
import sys
from datetime import datetime
from subprocess import run, PIPE
import yaml


WATERING_FILE = "~/Notes/Plants/Schedule.yaml"
PLANTS_GUIDE_FILE = "~/Notes/Plants/Plants.pdf"
PLANTS_WIKI_FILE = "obsidian://open?vault=Notes&file=Plants%2FWiki"


def menu(plants):
    entries = []
    separator = f"<tt><span foreground='#ccc'>{'—' * 30}</span></tt>"
    plants = sorted(plants, key=lambda p: p["target_watering"] - p["elapsed_watering"])
    for p in plants:
        dim = "#777"
        fg = (
            "foreground='#ce7d86'"
            if p["elapsed_watering"] > p["target_watering"]
            else ""
        )
        line = ""
        line += f"<span {fg}>{p['plant']}</span>  <span foreground='{dim}'>=</span>  "
        line += f"<span face='Font Awesome 6 Free' size='x-small' foreground='{dim}'></span>  "
        if p["last_watering"]:
            line += f"{p['elapsed_watering']}<span  size='small' foreground='#999'> ({p['target_watering']})</span>"
        else:
            line += "n/a"
        if p["last_fertilizing"]:
            line += f"   <span face='Font Awesome 6 Free' size='x-small' foreground='{dim}'></span>  "
            line += f"{p['elapsed_watering']}"
        line += ""
        entries.append(line)
    entries.append(separator)
    entries.append("<span size='small'>OPEN GUIDE</span>")
    entries.append("<span size='small'>OPEN WIKI</span>")
    cmd = [
        "mouse-menu",
        "-format",
        "p",
        "-width",
        "auto",
        "-markup-rows",
        "-maxlines",
        "30",
    ]
    try:
        return run(
            cmd, input="\n".join(entries), stdout=PIPE, encoding="utf8"
        ).stdout.strip()
    except FileNotFoundError:
        print("i3-tiny-menu not found", sys.stderr)
        sys.exit(1)


def load_file(path):
    today = datetime.today().date()
    with open(os.path.expanduser(path), "r") as f:
        for item in yaml.safe_load(f):
            yield {
                "plant": item["plant"],
                "target_watering": item["target_watering"],
                "last_watering": item["last_watering"],
                "last_fertilizing": item["last_fertilizing"],
                "elapsed_watering": (today - item["last_watering"]).days
                if item["last_watering"]
                else 0,
                "elapsed_fertilizing": (today - item["last_fertilizing"]).days
                if item["last_fertilizing"]
                else 0,
            }


def print_label(plants):
    delays = sum(int(p["elapsed_watering"] > p["target_watering"]) for p in plants)
    water = sum(int(p["elapsed_watering"] == p["target_watering"]) for p in plants)
    label = ""
    if water or delays:
        label = ""
    # if delays:
    #    label = "%{F#ce7d86}%{F-}"
    script_path = os.path.realpath(__file__)
    print(
        f"%{{A1:{script_path} -edit:}}%{{A3:{script_path} -menu:}}{label}%{{A}}%{{A}}"
    )


def edit_with_vim(path):
    cmd = [
        "kitty",
        "--name",
        "floating",
        "-e",
        "nvim",
        os.path.expanduser(path),
    ]
    run(cmd, stdout=PIPE, stderr=PIPE)


def xdg_open(path):
    run(["xdg-open", os.path.expanduser(path)])


def main():
    plants = load_file(WATERING_FILE)
    if "-menu" in sys.argv:
        selected = menu(plants)
        selected = selected.lower() if selected else ""
        if "guide" in selected:
            xdg_open(PLANTS_GUIDE_FILE)
        elif "wiki" in selected:
            xdg_open(PLANTS_WIKI_FILE)
        elif selected:
            edit_with_vim(WATERING_FILE)
    if "-edit" in sys.argv:
        edit_with_vim(WATERING_FILE)
    else:
        print_label(plants)


if __name__ == "__main__":
    main()
