#!/bin/bash

# Path
EXECUTION=./backup
DATA_DIR=/data

# geth init --datadir $EXECUTION/$DATA_DIR $EXECUTION/genesis.json

geth --datadir $EXECUTION/$DATA_DIR \
# import ./data
--syncmode full \
# --networkid 4693 \
# --http \
# --http.addr 127.0.0.1 \
# --http.api web3,eth,admin,net \
# --ws \
# --ws.api eth,net,web3 \
# --ws.addr 127.0.0.1 \
# --ws.origins "*" \
# --authrpc.vhosts "*" \
# --authrpc.addr 127.0.0.1 \
# --authrpc.jwtsecret ../jwtsecret \
# --mine \
# --miner.etherbase 0xe5b2737199c1c875a05b60b64b9e266e1b22e48a \
# --unlock 0xe5b2737199c1c875a05b60b64b9e266e1b22e48a \
# --allow-insecure-unlock \
# --password ../password.txt \
# --nodiscover


# geth --datadir ./execution/data export ./execution/data   