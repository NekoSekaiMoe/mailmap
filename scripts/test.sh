#!/bin/bash

set -eux

echo "Test email" | mail -s "Test subject" list@example.com

