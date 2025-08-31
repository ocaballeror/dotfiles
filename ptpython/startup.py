# ruff: noqa: F401
# type: ignore
import base64
import bz2
import asyncio
import itertools
import functools
import gzip
import json
import os
import pickle
import random
import re
import subprocess
import subprocess as sp
import time
from collections import Counter, defaultdict
from datetime import datetime, date, timezone, timedelta
from io import BytesIO, StringIO
from operator import attrgetter, itemgetter
from pathlib import Path
from pprint import pprint

try:
    import orjson
except ImportError:
    pass

try:
    from tqdm import tqdm, trange
except ImportError:
    pass

try:
    from PIL import Image
except ImportError:
    pass

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


def serints(thing):
    from enum import Enum

    if isinstance(thing, dict):
        thing = {serints(k): serints(v) for k, v in thing.items()}
    elif isinstance(thing, list):
        thing = [serints(x) for x in thing]
    elif isinstance(thing, Enum):
        thing = thing.name
    elif isinstance(thing, datetime):
        thing = thing.isoformat()
    elif not isinstance(thing, None):
        thing = str(thing)

    return thing

def format_seconds(total_seconds: int | timedelta) -> str:
    if isinstance(total_seconds, timedelta):
        total_seconds = total_seconds.total_seconds()

    total_seconds = round(total_seconds)
    total_minutes = total_seconds // 60
    display_seconds = total_seconds % 60

    total_hours = total_minutes // 60
    display_minutes = total_minutes % 60

    main_format = f"{display_minutes:02d}:{display_seconds:02d}"

    if total_hours > 0:
        main_format = f"{total_hours}:{main_format}"

    return main_format


def isof(d: str) -> datetime:
    d = d.rstrip("Z")
    micro = 0
    if re.search(r"\.\d*$", d):
        d, micro = d.rsplit('.')
        micro = int(micro)
        if micro > 1000000:
            micro //= 1000
        elif micro < 1000:
            micro *= 1000
    return datetime.fromisoformat(d) + timedelta(microseconds=micro)
