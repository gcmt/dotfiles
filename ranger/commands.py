
import os
import subprocess

import ranger
from ranger.api.commands import Command


class ext(Command):
    """:ext <filename>

    Preview a file in a floating vim window.
    """

    def execute(self):

        if self.arg(1):
            target = self.rest(1)
        else:
            target = self.fm.thisfile.path

        if not os.path.exists(target):
            self.fm.notify("File does not exist: " + target, bad=True)
            return

        vim = ['vim', '-c', 'nn <silent> <buffer> q :quit<cr>', target]
        subprocess.run(['urxvt', '-name', 'floating', '-e'] + vim)


    def tab(self, tabnum):
        return self._tab_directory_content()


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
