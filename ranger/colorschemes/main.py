
from ranger.colorschemes.default import Default
from ranger.gui.color import black, blue, cyan, green, magenta, red, white, yellow, default
from ranger.gui.color import normal, bold, reverse, underline, invisible
from ranger.gui.color import default_colors

orange = 16

foreground = 18
background = 19
cursor = 20

bg_accent = 21
fg_dim = 22
fg_very_dim = 23
fg_super_dim = 24


class Scheme(Default):

    def use(self, context):

        fg, bg, attr = Default.use(self, context)

        if context.border:
            fg = fg_super_dim

        elif context.in_browser:
            attr = normal
            if context.selected:
                bg = bg_accent
            if context.file:
                fg = foreground
            if context.marked:
                fg = yellow

        elif context.in_titlebar:

            if context.hostname:
                fg = red if context.bad else foreground
            elif context.directory:
                fg = foreground

        elif context.in_taskview:
            pass

        elif context.in_statusbar:
            pass

        return fg, bg, attr
