
import ranger
from ranger.api.commands import Command


HOOK_INIT_OLD = ranger.api.hook_init


class choose(Command):
    """:choose <data>

    This command mimicks the behavior of the command 'move right=1', but
    it overrides the normal --choosefile[s] behavior to also write additional meta
    information to the given file.

    To be used in conjuntion with the ranger vim plugin and the --choosefile[s] option.
    This command is supposed to be called from a mapping.

    Meta line format: #meta <data>
    """

    def execute(self):

        if not ranger.args.choosefiles and not ranger.args.choosefile:
            self.fm.notify('Ranger was expected to be run with the --choosefile[s] option', bad=True)
            return

        if self.fm.thisfile.is_directory:
            self.fm.thistab.enter_dir(self.fm.thisfile)
            return

        data = self.rest(1)
        meta = "#meta " + data + "\n" if data else ""

        if ranger.args.choosefile:

            with open(ranger.args.choosefile, 'w') as f:
                f.write(meta + self.fm.thisfile.path)

        if ranger.args.choosefiles:

            # thistab.get_selection() returns the file under cursor if there is no
            # marked file. When there are marked files, in the current directory or
            # elsewhere, we don't want to return it unless it's marked as well.

            paths = set(f.path for hist in self.fm.thistab.history for f in hist.files if f.marked)
            if self.fm.thisdir.marked_items:
                paths.update(f.path for f in self.fm.thistab.get_selection())

            if not paths:
                paths.add(self.fm.thisfile.path)

            with open(ranger.args.choosefiles, 'w') as f:
                f.write(meta + '\n'.join(paths))

        raise SystemExit


def hook_init(fm):
    if not ranger.args.choosefiles and not ranger.args.choosefile:
        del fm.commands.commands['choose']
    return HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init
