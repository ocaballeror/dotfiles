import os
import json
import time
import random
import asyncio
from datetime import datetime, date, timezone, timedelta
from pathlib import Path
from collections import Counter, defaultdict

try:
    import orjson
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

def format_seconds(total_seconds: int) -> str:
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
    return datetime.fromisoformat(d.rstrip("Z"))
