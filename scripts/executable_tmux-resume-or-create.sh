#!/bin/sh
(tmux ls | grep -vq attached && tmux -2 at) || tmux -2
