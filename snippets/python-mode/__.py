# -*- mode: snippet -*-
# name: python-default-file
# --
"""Module documentation."""

import pathlib
from typing import Any, Callable, Literal, Optional

from absl import app
from absl import flags
from absl import logging
import numpy as np
import numpy.typing as npt
import tree


Path = pathlib.Path

logging.set_verbosity(logging.INFO)

_EXAMPLE_STR_PATH_FLAG = flags.DEFINE_string(
    "example_str_path",
    None,
    "Help for `example_str_path` flag",
)
# _EXAMPLE_REQUIRED_FLOAT_FLAG = flags.DEFINE_float(
#     "example_required_float",
#     None,
#     "Help for `example_required_float` flag.",
# )

# flags.mark_flags_as_required(
#     (
#         _EXAMPLE_REQUIRED_FLOAT_FLAG,
#     )
# )


def main(argv):
    if _EXAMPLE_STR_PATH_FLAG.present:
        example_str_path = Path(_EXAMPLE_STR_PATH_FLAG.value).expanduser()
    else:
        example_str_path = None
    print(f"{example_str_path=}")$0


if __name__ == "__main__":
    app.run(main)
