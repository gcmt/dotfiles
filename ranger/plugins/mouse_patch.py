
import os
from datetime import datetime

import ranger
from ranger.gui.widgets.browsercolumn import BrowserColumn


HOOK_INIT_OLD = ranger.api.hook_init

DOUBLE_CLICK_TRESHOLD = 500

LEFT_BTN = 1
RIGHT_BTN = 3

LAST_CLICK = {
    LEFT_BTN: datetime.now()
}


def click(self, event):

    direction = event.mouse_wheel_direction()
    if not (event.pressed(LEFT_BTN) or event.pressed(RIGHT_BTN) or direction):
        return False

    if self.target is None or not self.target.is_directory:
        return False

    if not self.target.accessible and not self.target.content_loaded:
        return False

    index = self.scroll_begin + event.y - self.y

    if direction:

        if self.level == -1:
            self.fm.move_parent(direction)
        else:
            return False

    # Go to parent directory
    elif event.pressed(RIGHT_BTN):

        self.fm.move(left=1)

    # Enter directory or select file. Double click on a file opens it.
    elif event.pressed(LEFT_BTN):

        try:
            clicked_file = self.target.files[index]
        except IndexError:
            return False

        if clicked_file.is_directory:

            self.fm.enter_dir(clicked_file.path, remember=True)

        elif self.level == 0:

            delta = datetime.now() - LAST_CLICK[LEFT_BTN]
            millis = (delta.days * 86400000) + (delta.seconds * 1000) + (delta.microseconds / 1000)

            if clicked_file == self.fm.thisfile and millis < DOUBLE_CLICK_TRESHOLD:
                self.fm.execute_file(clicked_file)
            else:
                self.fm.thisdir.move_to_obj(clicked_file)

        LAST_CLICK[LEFT_BTN] = datetime.now()

    return True


def hook_init(fm):

    if os.environ.get('TMUX'):
        fm.settings.set('mouse_enabled', False)
        return

    BrowserColumn.click = click

    return HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init
