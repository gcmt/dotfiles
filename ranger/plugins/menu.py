
import re
from subprocess import run, PIPE

from ranger.core.shared import FileManagerAware


class Menu(FileManagerAware):

    def __init__(self, entries, theme="", width=None):
        """Create a clickable rofi menu at mouse position.

        Example entries:

            entries = [
                ["entry", func],
                ["sub menu..", [["entry": "cmd"], ["entry", func]]],
                ["entry", "cmd"],
            ]
        """
        self.theme = theme
        self.width = width
        self.entries = entries

    def error(self, msg):
        self.fm.notify(f"Menu: {msg}", bad=True)

    def open(self):
        """Open the menu at mouse position."""

        if not self.entries:
            return

        x, y = self.get_mouse_coordinates()
        if not x and not y:
            return

        entries = self.entries

        try:

            while True:

                index = self.rofi(x, y, list(map(lambda e: e[0], entries)))
                if not index:
                    return

                cmd = entries[int(index)][1]
                if isinstance(cmd, str):
                    return self.fm.execute_console(cmd)
                if callable(cmd):
                    return cmd(self.fm)
                if (isinstance(cmd, list) or isinstance(cmd, tuple)) and cmd:
                    entries = cmd
                    continue

                raise TypeError(f"a command must be type string or callable: got '{type(cmd)}'")

        except (IndexError, TypeError) as e:
            self.error(f"{e}")
            return

    def get_mouse_coordinates(self):
        """Retrieve mouse location using 'xdotool'."""

        try:
            cmd = ['xdotool', 'getmouselocation']
            stdout = run(cmd, stdout=PIPE, encoding='utf8').stdout
        except FileNotFoundError:
            self.error('xdotool not found')
            return None, None

        match = re.search('x:(\d+) y:(\d+)', stdout)
        if not match:
            return None, None

        return int(match.group(1)), int(match.group(2))

    def get_screen_size(self):
        """Retrieve screen size using 'xrandr'."""

        try:
            stdout = run(['xrandr'], stdout=PIPE, encoding='utf8').stdout
        except FileNotFoundError as e:
            self.error('xrandr not found')
            return None, None

        for line in stdout.split('\n'):
            if 'connected' in line:
                match = re.search('(\d+)x(\d+)', line)
                if match:
                    return int(match.group(1)), int(match.group(2))

        return None, None

    def rofi(self, x, y, entries):
        """Open the rofi menu at position x and y on the screen."""

        options  = ['-dmenu', '-format', 'i', '-click-to-exit']
        options += ['-me-select-entry', '', '-me-accept-entry', 'MousePrimary']

        options += ['-theme', self.theme] if self.theme else []
        options += ['-theme-str', 'window { location: north west; anchor: north west; }']
        options += ['-theme-str', f'window {{ x-offset: {x}px; y-offset: {y}px; }}']
        options += ['-theme-str', 'listview { fixed-height: false; }']

        w, h = self.get_screen_size()
        if w and w-x <= 200:
            options += ['-theme-str', 'window { anchor: north east; }']

        if self.width:
            options += ['-theme-str', f'window {{ width: {args.width}; }}']
        elif entries:
            chars = max(len(max(entries, key=len)) + 10, 20)
            options += ['-theme-str', f'window {{ width: {chars}ch; }}']

        # Disable input bar
        options += ['-theme-str', 'mainbox { children: [listview]; }']

        # Setup keybindings
        options += ['-kb-row-up', 'Up,Control+k,k', '-kb-row-down', 'Down,Control+j,j']
        options += ['-kb-accept-entry', 'l,Return,Control+d', '-kb-cancel', 'Escape,Control+c,q']

        try:
            cmd = ['rofi'] + options
            input = "\n".join(entries)
            stdout = run(cmd, input=input, stdout=PIPE, encoding='utf8').stdout
            return stdout.strip()
        except FileNotFoundError:
            error('rofi not found')
            return
