import os
import subprocess

from ranger.api.commands import Command
from ranger.ext.get_executables import get_executables

from plugins.ranger_udisk_menu.mounter import mount


class yank(Command):
    """:yank [name|dir|path|name_without_extension]

    Copy the selected file metadata into the active clipboard backend.
    """

    modes = {
        "": "basename",
        "name_without_extension": "basename_without_extension",
        "name": "basename",
        "dir": "dirname",
        "path": "path",
    }

    def execute(self):
        clipboard_commands = self._clipboard_commands()
        if not clipboard_commands:
            self.fm.notify("No supported clipboard backend found", bad=True)
            return

        mode = self.modes[self.arg(1)]
        selection = self.get_selection_attr(mode)
        new_clipboard_contents = "\n".join(selection)

        for command in clipboard_commands:
            with subprocess.Popen(
                command,
                universal_newlines=True,
                stdin=subprocess.PIPE,
            ) as process:
                process.communicate(input=new_clipboard_contents)

    def _clipboard_commands(self):
        clipboard_managers = {
            "wl-copy": [["wl-copy"]],
            "xclip": [["xclip"], ["xclip", "-selection", "clipboard"]],
            "xsel": [["xsel"], ["xsel", "-b"]],
            "pbcopy": [["pbcopy"]],
        }

        executables = get_executables()
        session_type = os.environ.get("XDG_SESSION_TYPE", "").lower()
        wayland_display = os.environ.get("WAYLAND_DISPLAY", "")

        if wayland_display or session_type == "wayland":
            ordered_managers = ["wl-copy", "xclip", "xsel", "pbcopy"]
        else:
            ordered_managers = ["xclip", "xsel", "wl-copy", "pbcopy"]

        for manager in ordered_managers:
            if manager in executables:
                return clipboard_managers[manager]

        return []

    def get_selection_attr(self, attr):
        return [getattr(item, attr) for item in self.fm.thistab.get_selection()]

    def tab(self, tabnum):
        return (
            self.start(1) + mode
            for mode in sorted(self.modes.keys())
            if mode
        )
