
from __future__ import (absolute_import, division, print_function)

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
