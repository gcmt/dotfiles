
import os
import curses
from datetime import datetime

import ranger
from ranger.gui.widgets.browsercolumn import BrowserColumn
from ranger.gui.mouse_event import MouseEvent

HOOK_INIT_OLD = ranger.api.hook_init

LEFT_BTN = 1
RIGHT_BTN = 3

LAST_CLICK = {
    LEFT_BTN: datetime.now()
}

ENTER_DIRS_WITH_SINGLE_CLICK = False
DOUBLE_CLICK_TRESHOLD = 500


def right_click_handler(fm):
    fm.move(left=1)


def click(self, event):
    """Handle a MouseEvent.

    - Select a file or directory with a single click. Set ENTER_DIRS_WITH_SINGLE_CLICK
      to True to enter a directory with a single click.
    - Double clicking on a file or directory respectively execute the file or
      enters the directory.
    - By default a right click enters the parent directory.
    - Use the mouse wheel to move up and down.

    See ranger/gui/widgets/browsercolumn.py for the original implementation.
    """

    direction = event.mouse_wheel_direction()
    if not (event.pressed(LEFT_BTN) or event.pressed(RIGHT_BTN) or direction):
        return False

    if self.target is None or not self.target.is_directory:
        return False

    if not self.target.accessible and not self.target.content_loaded:
        return False

    index = self.scroll_begin + event.y - self.y

    try:
        clicked_file = self.target.files[index]
    except IndexError:
        return False

    if direction:

        if self.level == -1:
            self.fm.move_parent(direction)
        else:
            return False

    elif event.pressed(RIGHT_BTN):

        self.fm.thisdir.move_to_obj(clicked_file)
        self.fm.ui.redraw()

        right_click_handler(self.fm)

    elif event.pressed(LEFT_BTN):

        delta = datetime.now() - LAST_CLICK[LEFT_BTN]
        millis = (delta.days * 86400000) + (delta.seconds * 1000) + (delta.microseconds / 1000)

        if clicked_file.is_directory:

            if ENTER_DIRS_WITH_SINGLE_CLICK:
                self.fm.enter_dir(clicked_file.path, remember=True)
            else:
                if clicked_file == self.fm.thisfile and millis < DOUBLE_CLICK_TRESHOLD:
                    self.fm.enter_dir(clicked_file.path, remember=True)
                else:
                    self.fm.thisdir.move_to_obj(clicked_file)

        elif self.level == 0:

            if clicked_file == self.fm.thisfile and millis < DOUBLE_CLICK_TRESHOLD:
                self.fm.execute_file(clicked_file)
            else:
                self.fm.thisdir.move_to_obj(clicked_file)

        LAST_CLICK[LEFT_BTN] = datetime.now()

    return True


def mouse_wheel_direction(self):
    """Returns the direction of the scroll action, 0 if there was none.

    See ranger/gui/mouse_event.py for the original implementation.
    """
    # When opening Rofi over Ranger and clicking on an entry,
    # `self.bstate > curses.ALL_MOUSE_EVENTS == True`. We don't want this to be
    # interpreted as scroll down one line.
    if self.bstate & curses.BUTTON4_PRESSED:
            return -self.CTRL_SCROLLWHEEL_MULTIPLIER if self.ctrl() else -1
    elif self.bstate & curses.BUTTON2_PRESSED \
            or self.bstate & 2**21:
        return self.CTRL_SCROLLWHEEL_MULTIPLIER if self.ctrl() else 1
    return 0


def hook_init(fm):

    # Disable mouse handling inside Tmux. Nothing seems to work right.
    if os.environ.get('TMUX'):
        fm.settings.set('mouse_enabled', False)
        return

    # Monkey patching
    BrowserColumn.click = click
    MouseEvent.mouse_wheel_direction = mouse_wheel_direction

    return HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init
