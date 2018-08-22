
import os
import ranger
from ranger.gui.widgets.browsercolumn import BrowserColumn


HOOK_INIT_OLD = ranger.api.hook_init


def click(self, event):

    direction = event.mouse_wheel_direction()
    if not (event.pressed(1) or event.pressed(3) or direction):
        return False

    if self.target is None or not self.target.is_directory:
        return False

    if not self.target.accessible and not self.target.content_loaded:
        return False

    index = self.scroll_begin + event.y - self.y

    # Mouse scroll
    if direction:

        if self.level == -1:
            self.fm.move_parent(direction)
        else:
            return False

    # Right click
    # Go to parent directory
    elif event.pressed(3):

        self.fm.move(left=1)

    # Left click
    # Enter directory or execute file
    elif event.pressed(1):

        try:
            clicked_file = self.target.files[index]
        except IndexError:
            return False

        if clicked_file.is_directory:
            self.fm.enter_dir(clicked_file.path, remember=True)
        elif self.level == 0:
            self.fm.thisdir.move_to_obj(clicked_file)
            self.fm.execute_file(clicked_file)

    return True


def hook_init(fm):

    if os.environ.get('TMUX'):
        fm.settings.set('mouse_enabled', False)
        return

    BrowserColumn.click = click

    return HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init
