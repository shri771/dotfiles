import os
import subprocess
import sys

from ranger.core.shared import FileManagerAware
from ranger.ext.img_display import ImageDisplayer, ImageDisplayError, register_image_displayer


@register_image_displayer("kitty")
class KittyIcatImageDisplayer(ImageDisplayer, FileManagerAware):
    image_id = 424242

    def draw(self, path, start_x, start_y, width, height):
        if width <= 0 or height <= 0:
            return

        place = f"{int(width)}x{int(height)}@{int(start_x)}x{int(start_y)}"
        cmd = [
            "kitten",
            "icat",
            "--silent",
            "--transfer-mode=file",
            "--unicode-placeholder",
            "--passthrough=tmux" if os.environ.get("TMUX") else "--passthrough=none",
            "--place",
            place,
            "--scale-up",
            "--image-id",
            str(self.image_id),
            "--no-trailing-newline",
            path,
        ]

        sys.stdout.flush()
        try:
            subprocess.run(cmd, check=True)
        except FileNotFoundError as error:
            raise ImageDisplayError("kitten is required for kitty previews") from error
        except subprocess.CalledProcessError as error:
            raise ImageDisplayError("kitten icat failed") from error

    def clear(self, start_x, start_y, width, height):
        self.fm.ui.win.redrawwin()
        self.fm.ui.win.refresh()

    def quit(self):
        self.clear(0, 0, 0, 0)
