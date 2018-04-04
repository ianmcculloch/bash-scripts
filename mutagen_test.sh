#!/bin/bash

from mutagen.flac import FLAC
audio = FLAC\("01 - Today.flac"\)
print audio.info.bitrate
