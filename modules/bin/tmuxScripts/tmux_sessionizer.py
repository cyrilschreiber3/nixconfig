import sys
from pathlib import Path

import libtmux
import sh
from pyfzf.pyfzf import FzfPrompt

fzf = FzfPrompt()
folders = [
    "~/Documents/",
    "~/Documents/dev/",
]

available_folders = (
    sh.find(
        *[Path(f).expanduser() for f in folders]
        + "-mindepth 1 -maxdepth 2 -type d".split(" ")
    )
    .strip()
    .split("\n")
)
available_folders.append(Path("~/nixconfig").expanduser())

selected = fzf.prompt(
    ["Select a folder to create or switch session to"] + available_folders,
    "--cycle --header-lines 1 --tmux center",
)

if not selected:
    sys.exit(1)

selected = selected[0]
session_name = selected.split("/")[-1]
srv = libtmux.Server()

if not srv.has_session(session_name):
    srv.new_session(session_name, attach=False, start_directory=selected)

srv.switch_client(session_name)