#!/bin/bash

set -x

sudo apt update && sudo apt install -y cmake g++ libboost-all-dev ninja-build
test -d out || mkdir out
cd out && cmake .. -GNinja && ninja install
