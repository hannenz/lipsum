#!/bin/bash

# Enable debug output (GLib.debug())
export G_MESSAGES_DEBUG=all

# Use local copy of settings schema file, no need to install it (for development)
export GSETTINGS_SCHEMA_DIR=./data/

# run the executable
./lipsum -g $@
