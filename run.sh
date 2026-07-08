#!/bin/bash
cd "$(dirname "$0")"
swift build -c release 2>&1 | tail -5
.build/release/PeckitDevCenter
