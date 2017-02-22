#!/bin/bash

# Create symlink to this file so it can be executed during login:
# ln -s `pwd`/.bash_aliases $HOME/.bash_aliases

# Fancy ls
alias ll='ls -alhF --color --group-directories-first'

# Quick SSH to TX-1
alias sshtx="sshpass -p 'ubuntu' ssh ubuntu@10.42.0.1"

# Mount TX-1 to a host
alias tx1mnt1="sudo sshfs -o idmap=user -o allow_other ubuntu@10.42.0.1:/home/ubuntu ~/tx1-01"
alias tx1mnt2="sudo sshfs -o idmap=user -o allow_other ubuntu@10.42.0.1:/home/ubuntu ~/tx1-02"
