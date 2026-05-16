from ranger.colorschemes.default import Default
from ranger.gui.color import bold, default, normal, reverse


class Scheme(Default):
    progress_bar_color = 67

    # Muted slate/Nord-style palette matching the ranger_devicons example.
    text = 252
    muted = 109
    dimmed = 60
    border = 245
    selected_fg = 252
    selected_bg = 236
    directory = 109
    executable = 114
    image = 173
    media = 139
    archive = 180
    document = 253
    code = 150
    link = 116
    error = 203
    warning = 180
    title_good = 150
    path = 110
    pane_inactive = 67
    surface = 236

    def use(self, context):  # pylint: disable=too-many-branches,too-many-statements
        fg, bg, attr = Default.use(self, context)

        if context.reset:
            return default, default, normal

        if context.in_browser:
            fg = self.text
            bg = default
            attr = normal

            if context.selected:
                fg = self.selected_fg
                bg = self.selected_bg
                attr = reverse
            elif context.empty or context.error:
                fg = self.error
                attr = bold
            elif context.border:
                fg = self.border
            elif context.directory:
                fg = self.directory
                attr = bold
            elif context.executable and not any(
                (context.media, context.container, context.fifo, context.socket)
            ):
                fg = self.executable
                attr = bold
            elif context.media:
                fg = self.image if context.image else self.media
            elif context.container:
                fg = self.archive
            elif context.socket:
                fg = self.media
                attr = bold
            elif context.fifo or context.device:
                fg = self.warning
                attr = bold
            elif context.link:
                fg = self.link if context.good else self.error
                attr = bold
            elif context.line_number:
                fg = self.muted

            if context.tag_marker and not context.selected:
                fg = self.error
                attr = bold
            if not context.selected and (context.cut or context.copied):
                fg = self.dimmed
                attr = bold
            if context.main_column and context.marked:
                fg = self.warning
                attr = bold
            if context.badinfo:
                fg = self.error
            if context.inactive_pane:
                fg = self.pane_inactive

        elif context.in_titlebar:
            fg = self.text
            bg = default
            attr = bold
            if context.hostname:
                fg = self.error if context.bad else self.title_good
            elif context.directory:
                fg = self.path
            elif context.link:
                fg = self.link
            elif context.tab:
                fg = self.selected_fg if context.good else self.text
                bg = self.directory if context.good else self.surface

        elif context.in_statusbar:
            fg = self.text
            bg = default
            attr = normal
            if context.permissions:
                fg = self.link if context.good else self.error
            if context.marked:
                fg = self.selected_fg
                bg = self.warning
                attr = bold
            if context.frozen:
                fg = self.selected_fg
                bg = self.link
                attr = bold
            if context.message and context.bad:
                fg = self.error
                attr = bold
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = self.path
            if context.vcscommit:
                fg = self.warning
            if context.vcsdate:
                fg = self.link

        if context.text:
            if context.highlight:
                attr |= reverse
            if context.error:
                fg = self.error

        if context.in_taskview:
            fg = self.text
            bg = default
            if context.title:
                fg = self.path
                attr = bold
            if context.selected:
                fg = self.selected_fg
                bg = self.selected_bg
                attr = reverse
            if context.loaded:
                bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = self.error
            elif context.vcsuntracked:
                fg = self.link
            elif context.vcschanged:
                fg = self.image
            elif context.vcsunknown:
                fg = self.error
            elif context.vcsstaged or context.vcssync:
                fg = self.executable
            elif context.vcsignored:
                fg = self.dimmed

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync or context.vcsnone:
                fg = self.executable
            elif context.vcsbehind:
                fg = self.error
            elif context.vcsahead:
                fg = self.path
            elif context.vcsdiverged:
                fg = self.media
            elif context.vcsunknown:
                fg = self.error

        return fg, bg, attr
