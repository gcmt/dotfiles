return {

	markdown = [[
        (atx_heading [
            (atx_h1_marker)
            (atx_h2_marker)
            (atx_h3_marker)
            (atx_h4_marker)
            (atx_h5_marker)
            (atx_h6_marker)
        ] @heading)
        (minus_metadata) @metadata
        (thematic_break) @separator
        (fenced_code_block) @codeblock
        (block_quote) @blockquote
        (list) @list
        ((inline) @tags (#match? @tags "^#[a-z_-]+"))
    ]],

	markdown_inline = [[
        (code_span) @codeinline
        ((shortcut_link) @callout (#match? "^[!"))
        (inline_link) @link
        (image) @image
    ]],
}
