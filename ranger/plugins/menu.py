
import re
from subprocess import run, PIPE

from ranger.core.shared import FileManagerAware


class Menu(FileManagerAware):

    def __init__(self, entries=None, theme="", width=None):
        """Create a clickable rofi menu at mouse position.

        Example entries:

            entries = [
                ["entry", func],
                ["sub menu..", [["entry": "cmd"], ["entry", func]]],
                ["entry", "cmd"],
            ]
        """
        self.entries = entries
        self.theme = theme
        self.width = width

    def open(self):
        """Open the menu at mouse position."""

        if not self.entries:
            return

        x, y = self._get_mouse_coordinates()
        if not x and not y:
            return

        entries = self.entries
        try:

            while True:

                index = self._rofi(x, y, list(map(lambda e: e[0], entries)))
                if not index:
                    return

                entry = entries[int(index)][0]
                cmd = entries[int(index)][1]

                if isinstance(cmd, str):
                    if not cmd:
                        return
                    return self.fm.execute_console(cmd)
                if callable(cmd):
                    return cmd(self.fm)
                if (isinstance(cmd, list) or isinstance(cmd, tuple)) and cmd:
                    entries = cmd
                    continue

                msg = "expected type string, callable or non-empty list, "
                msg += f"got value '{repr(cmd)}' (type {type(cmd)}) for entry '{entry}'"
                raise TypeError(msg)

        except (IndexError, TypeError) as e:
            self._error(f"{e}")
            return

    def _get_mouse_coordinates(self):
        """Retrieve mouse location using 'xdotool'."""

        try:
            cmd = ['xdotool', 'getmouselocation']
            stdout = run(cmd, stdout=PIPE, encoding='utf8').stdout
        except FileNotFoundError:
            self._error('xdotool not found')
            return None, None

        match = re.search('x:(\d+) y:(\d+)', stdout)
        if not match:
            return None, None

        return int(match.group(1)), int(match.group(2))

    def _get_screen_size(self):
        """Retrieve screen size using 'xrandr'."""

        try:
            stdout = run(['xrandr'], stdout=PIPE, encoding='utf8').stdout
        except FileNotFoundError as e:
            self._error('xrandr not found')
            return None, None

        for line in stdout.split('\n'):
            if 'connected' in line:
                match = re.search('(\d+)x(\d+)', line)
                if match:
                    return int(match.group(1)), int(match.group(2))

        return None, None

    def _rofi(self, x, y, entries):
        """Open the rofi menu at position x and y on the screen."""

        options  = ['-dmenu', '-format', 'i', '-click-to-exit']
        options += ['-me-select-entry', '', '-me-accept-entry', 'MousePrimary']

        options += ['-theme', self.theme] if self.theme else []
        options += ['-theme-str', 'window { location: north west; anchor: north west; }']
        options += ['-theme-str', f'window {{ x-offset: {x}px; y-offset: {y}px; }}']
        options += ['-theme-str', 'listview { fixed-height: false; }']

        w, h = self._get_screen_size()
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
            self._error('rofi not found')
            return

    def _error(self, msg):
        self.fm.notify(f"Menu: {msg}", bad=True)
