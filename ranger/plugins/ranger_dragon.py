from __future__ import annotations

import shutil
from subprocess import Popen

from ranger.api.commands import Command


def _dragon_binary() -> str | None:
    for name in ("xdragon", "dragon-drop", "dragon"):
        path = shutil.which(name)
        if path:
            return path
    return None


class dragon(Command):
    """:dragon

    Send the current selection to the dragon drop helper.
    """

    def execute(self):
        binary = _dragon_binary()
        if not binary:
            self.fm.notify(
                "dragon-drop helper not found; install nix package `dragon-drop`",
                bad=True,
            )
            return

        files = [f.path for f in self.fm.thistab.get_selection()]
        if not files and self.fm.thisfile:
            files = [self.fm.thisfile.path]

        if not files:
            return

        Popen([binary, *files], stdout=None, stderr=None, stdin=None)
