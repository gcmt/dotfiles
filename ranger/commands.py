
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

    Overrides the normal --choosefile[s] behavior to also write to the give file
    argument the mode in which the selected file should be opened (or the first
    file of the selection).

    Mode line format: #mode <mode>
    Possible modes are: window, split, vsplit and tab.
    """

    def execute(self):

        if not ranger.args.choosefiles and not ranger.args.choosefile:
            self.fm.notify('Ranger was expected to be run with the --choosefile[s] option', bad=True)
            return

        mode = self.arg(1) if self.arg(1) else 'window'

        selection = self.fm.thistab.get_selection()
        if not selection:
            raise SystemExit

        tfile = self.fm.thisfile
        if tfile.is_directory:
            self.fm.thistab.enter_dir(tfile)
            return

        if ranger.args.choosefile:
            with open(ranger.args.choosefile, 'w') as fobj:
                fobj.write("#mode " + mode + "\n")
                fobj.write(tfile.path)

        if ranger.args.choosefiles:
            paths = []
            for hist in self.fm.thistab.history:
                for fobj in hist.files:
                    if fobj.marked and fobj.path not in paths:
                        paths += [fobj.path]
            paths += [f.path for f in self.fm.thistab.get_selection() if f.path not in paths]

            with open(ranger.args.choosefiles, 'w') as fobj:
                fobj.write("#mode " + mode + "\n")
                fobj.write('\n'.join(paths) + '\n')

        raise SystemExit
