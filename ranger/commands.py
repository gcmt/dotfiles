
import os
import subprocess

import ranger
from ranger.api.commands import Command


class vidir(Command):
    """:vidir

    Rename all files in the current directory or marked files if any.
    """

    def execute(self):

        if not self.fm.thisdir:
            self.fm.notify("Nothing to rename!", bad=True)
            return

        if self.fm.thisdir.marked_items:
            files = self.fm.thisdir.get_selection()
        else:
            files = []

        args = [f.relative_path for f in files]
        self.fm.execute_command(['vidir', *args])

        for f in files:
            self.fm.thisdir.mark_item(f, False)


class cd_root(Command):
    """:cd_root

    Cd into the current project root.
    """

    def execute(self):
        root_markers = set(['.gitignore', 'node_modules'])
        path = self.find_root(self.fm.thisdir.path, root_markers)
        if not path:
            self.fm.notify("Root cannot be located", bad=True)
        else:
            self.fm.cd(path)
            self.fm.notify("cd " + path)

    def find_root(self, path, markers):
        if not path or path == '/':
            return ''
        if set(os.listdir(path)) & markers:
            return path
        return self.find_root(os.path.dirname(path), markers)
