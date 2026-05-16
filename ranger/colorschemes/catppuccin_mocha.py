from ranger.colorschemes.default import Default
from ranger.gui.color import bold, default, normal, reverse


class Scheme(Default):
    progress_bar_color = 111

    # Catppuccin Mocha approximated for xterm-256 colors.
    rosewater = 217
    flamingo = 216
    pink = 212
    mauve = 141
    red = 210
    maroon = 174
    peach = 216
    yellow = 229
    green = 150
    teal = 115
    sky = 117
    sapphire = 74
    blue = 111
    lavender = 183
    text = 189
    subtext1 = 145
    subtext0 = 103
    overlay2 = 103
    overlay1 = 60
    overlay0 = 59
    surface2 = 60
    surface1 = 59
    surface0 = 237
    base = 235
    mantle = 234
    crust = 233

    def use(self, context):  # pylint: disable=too-many-branches,too-many-statements
        fg, bg, attr = Default.use(self, context)

        if context.reset:
            return default, default, normal

        if context.in_browser:
            fg = self.text
            bg = default
            attr = normal

            if context.selected:
                fg = self.crust
                bg = self.mauve
                attr = bold
            elif context.marked:
                fg = self.yellow
                bg = self.surface0
                attr = bold
            elif context.empty or context.error:
                fg = self.red
                bg = self.surface0
                attr = bold
            elif context.border:
                fg = self.surface2
            elif context.directory:
                fg = self.blue
                attr = bold
            elif context.executable and not any(
                (context.media, context.container, context.fifo, context.socket)
            ):
                fg = self.green
                attr = bold
            elif context.media:
                fg = self.peach if not context.image else self.pink
            elif context.container:
                fg = self.yellow
            elif context.socket:
                fg = self.mauve
                attr = bold
            elif context.fifo or context.device:
                fg = self.yellow
                attr = bold
            elif context.link:
                fg = self.teal if context.good else self.red
                attr = bold
            elif context.line_number:
                fg = self.overlay0

            if context.tag_marker and not context.selected:
                fg = self.red
                attr = bold

            if not context.selected and (context.cut or context.copied):
                fg = self.overlay1
                attr = bold

            if context.main_column and context.selected:
                attr = bold

            if context.inactive_pane:
                fg = self.overlay1

        elif context.in_titlebar:
            fg = self.text
            bg = self.mantle
            attr = bold

            if context.hostname:
                fg = self.red if context.bad else self.green
            elif context.directory:
                fg = self.blue
            elif context.link:
                fg = self.teal
            elif context.tab:
                fg = self.crust if context.good else self.text
                bg = self.green if context.good else self.surface0

        elif context.in_statusbar:
            fg = self.text
            bg = self.mantle
            attr = normal

            if context.permissions:
                fg = self.green if context.good else self.red
            if context.marked:
                fg = self.crust
                bg = self.yellow
                attr = bold
            if context.frozen:
                fg = self.crust
                bg = self.sky
                attr = bold
            if context.message and context.bad:
                fg = self.red
                attr = bold
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = self.blue
            if context.vcscommit:
                fg = self.yellow
            if context.vcsdate:
                fg = self.teal

        if context.text and context.highlight:
            attr |= reverse

        if context.in_taskview:
            fg = self.text
            bg = default
            if context.title:
                fg = self.blue
                attr = bold
            if context.selected:
                fg = self.crust
                bg = self.mauve
                attr = bold
            if context.loaded:
                bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = self.red
            elif context.vcsuntracked:
                fg = self.sky
            elif context.vcschanged:
                fg = self.peach
            elif context.vcsunknown:
                fg = self.red
            elif context.vcsstaged:
                fg = self.green
            elif context.vcssync:
                fg = self.green
            elif context.vcsignored:
                fg = self.overlay0

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync or context.vcsnone:
                fg = self.green
            elif context.vcsbehind:
                fg = self.red
            elif context.vcsahead:
                fg = self.blue
            elif context.vcsdiverged:
                fg = self.mauve
            elif context.vcsunknown:
                fg = self.red

        return fg, bg, attr
