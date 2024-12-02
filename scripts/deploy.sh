#!/bin/bash

set -eux
crontab -e #0 0 * * * /path/to/archive_converter.py

