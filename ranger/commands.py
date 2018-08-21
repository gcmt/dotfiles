
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


class vim_edit(Command):
    """:vim_edit <mode>

    To be used in conjuntion with the ranger vim plugin and the --choosefile[s] option.

    Overrides the normal --choosefile[s] behavior to also write additional meta
    information to the given file.

    Meta line format: #meta <data>
    """

    def execute(self):

        if not ranger.args.choosefiles and not ranger.args.choosefile:
            self.fm.notify('Ranger was expected to be run with the --choosefile[s] option', bad=True)
            return

        if self.fm.thisfile.is_directory:
            self.fm.thistab.enter_dir(self.fm.thisfile)
            return

        # thistab.get_selection() returns the file under cursor if there is no
        # marked file. When there are marked files, in the current directory or
        # elsewhere, we don't want to return it unless it's marked as well.

        paths = [f.path for hist in self.fm.thistab.history for f in hist.files if f.marked]
        if self.fm.thisdir.marked_items:
            paths += [f.path for f in self.fm.thistab.get_selection()]

        paths = set(paths)

        if not paths:
            paths.add(self.fm.thisfile.path)

        meta = "#meta " + self.rest(1)

        if ranger.args.choosefile:
            with open(ranger.args.choosefile, 'w') as f:
                f.write(meta + '\n' + self.fm.thisfile.path)

        if ranger.args.choosefiles:
            with open(ranger.args.choosefiles, 'w') as f:
                f.write(meta + '\n' + '\n'.join(paths) + '\n')

        raise SystemExit
