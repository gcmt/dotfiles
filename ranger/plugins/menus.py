
import plugins.mouse
from .menu import Menu


test_entries = [
    ["foo", lambda fm: fm.notify("foo")],
    ["sub menu..", [
        ["sub_foo", lambda fm: fm.notify("sub_foo")],
        ["sub_bar", lambda fm: fm.notify("sub_bar")]
    ]],
    ["bar", lambda fm: fm.notify("bar")],
]


def menu_loader(fm):
    menu = Menu(test_entries, theme="ranger-menu")
    rv = menu.open()


plugins.mouse.right_click_handler = menu_loader
