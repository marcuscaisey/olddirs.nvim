.PHONY: install_lemmy_help

doc/olddirs.txt: lua/olddirs.lua
	lemmy-help $^ > $@

install_lemmy_help:
	cargo install lemmy-help --features=cli
