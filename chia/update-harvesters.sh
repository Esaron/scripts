#!/bin/bash

# update harvesters
ssh user@host "/home/user/chia/update.sh"
scp -r ~/.chia/mainnet/config/ssl/ca user@host:/home/user/.chia/mainnet/config/ssl
ssh user@host "/home/user/chia/run.sh > /tmp/chiarunlog 2>&1 && cat /tmp/chiarunlog"

