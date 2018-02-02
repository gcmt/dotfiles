# midnight theme

palette.update({
    "variables": ("white", "default"),

    "var label": ("light blue", "default"),
    "var value": ("white", "default"),

    "stack": ("white", "default"),

    "frame name": ("white", "default"),
    "frame class": ("dark blue", "default"),
    "frame location": ("light cyan", "default"),

    "current frame name": (add_setting("white", "bold"), "default"),
    "current frame class": ("dark blue", "default"),
    "current frame location": ("light cyan", "default"),

    "focused frame name": ("black", "dark green"),
    "focused frame class": (add_setting("white", "bold"), "dark green"),
    "focused frame location": ("dark blue", "dark green"),

    "focused current frame name": ("black", "dark green"),
    "focused current frame class": ( add_setting("white", "bold"), "dark green"),
    "focused current frame location": ("dark blue", "dark green"),

    "search box": ("default", "default"),

    "breakpoint": ("white", "default"),
    "disabled breakpoint": ("dark gray", "default"),
    "focused breakpoint": ("black", "dark green"),
    "focused disabled breakpoint": ("dark gray", "dark green"),
    "current breakpoint": (add_setting("white", "bold"), "default"),
    "disabled current breakpoint": ( add_setting("dark gray", "bold"), "default"),
    "focused current breakpoint": ( add_setting("white", "bold"), "dark green", "bold"),
    "focused disabled current breakpoint": ( add_setting("dark gray", "bold"), "dark green", "bold"),

    "source": ("white", "default"),
    "highlighted source": ("white", "light cyan"),
    "current source": ("white", "light gray"),
    "current focused source": ("white", "dark blue"),

    "line number": ("h17", "default"),
    "keyword": ("dark magenta", "default"),
    "name": ("white", "default"),
    "literal": ("dark cyan", "default"),
    "string": ("dark red", "default"),
    "doublestring": ("dark red", "default"),
    "singlestring": ("light blue", "default"),
    "docstring": ("light red", "default"),
    "backtick": ("light green", "default"),
    "punctuation": ("white", "default"),
    "comment": ("h17", "default"),
    "classname": ("dark cyan", "default"),
    "funcname": ("white", "default"),

    "breakpoint marker": ("dark red", "default"),

    # {{{ shell

    "command line edit": ("white", "default"),
    "command line prompt": (add_setting("white", "bold"), "default"),

    "command line output": (add_setting("white", "bold"), "default"),
    "command line input": (add_setting("white", "bold"), "default"),
    "command line error": (add_setting("light red", "bold"), "default"),

    "focused command line output": ("black", "dark green"),
    "focused command line input": ( add_setting("white", "bold"), "dark green"),
    "focused command line error": ("black", "dark green"),

    "command line clear button": (add_setting("white", "bold"), "default"),
    "command line focused button": ("black", "light gray"),  # White
    # doesn't work in curses mode

    # }}}

})
