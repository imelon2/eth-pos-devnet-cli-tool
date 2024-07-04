# Ethereum Proof-of-Stake Devnet
본 Repo는 **Geth와 Prysm**을 활용하여 Ethereum POS Local Node를 실행하기 위한 docker-compose와 CLI Tool을 제공합니다.
> **[Optional]** 선택에 따라 **blockscout**를 활용하여 실행된 Node의 Block Explorer를 같이 실행할 수 있습니다.

</br>

## genesis.json & config.yml
- genesis.json : /execution/genesis.json
- config.yml : /consensus/config.yml

</br>


## Using CLI Tool
```` bash
% ./cli.sh help

Usage:
  ./cli.sh [command]

Available Commands:
  execution, e       Run Geth Cli
  consensus, c       Run Prysm Cli
  blockscout, b      Run Blockscout Cli
````
본 Repo는 Ethereum POS의 **`execution layer(Geth)`** 와 **`consensus layer(Prysm)`** 를 실행하기 위한 명령어(CLI)를 제공합니다.
> **[Optional]** Block Explorer(Blockscout)를 실행하기 위한 명령어(CLI)를 제공합니다.

</br>

### Execution Layer CLI
```` bash
% ./cli.sh execution help 

Usage:
  ./cli.sh execution [command]

Available Commands:
  new-account, new        Create a new account (PATH:/data/keystore)
  list-account, list      Print summary of existing accounts
  init                    Bootstrap and initialize a new genesis block
  run                     Run go-ethereum Execution Layer Node
  attach, a               Start an interactive JavaScript environment (PATH:/data/geth.ipc)
  clean                   Remove blockchain and state databases (PATH:/data)
````
</br>


### Consensus Layer CLI
```` bash
% ./cli.sh consensus help 

Usage:
  ./cli.sh consensus [command]

Available Commands:
  generate-genesis, gg      Generate genesis.json (PATH: /nwolrd_dev_pos/execution/genesis.json)
  create-jwt-secret, jwt    Create JWT secret (PATH: /nwolrd_dev_pos/execution/jwtsecret)
  run-beacon-chain, runb    Run Consensus Layer beacon Node
  run-validator, runv       Run Consensus Layer Validator
  clean                     Remove beacochain and validator databases
````

### Blockscout CLI
```` bash
% ./cli.sh blockscout help 

Usage:
  ./cli.sh blockscout [command]

Available Commands:
  run              Run Geth Node Explorer (RPC: geth:8545)
````

## Build Node
``` bash
# (1) Create Auth JWT
./cli.sh consensus create-jwt-secret

# (2) Create genesis.json
./cli.sh consensus generate-genesis

# (3) init genesis block
./cli.sh execution init

# (4) Run execution & consensus Node
./cli.sh execution run
./cli.sh consensus run-beacon-chain
./cli.sh consensus run-validator

# (Optional) Run Block Explorer
./cli.sh blockscout run

```

</br>

## Config
- 본 과정은 `Deneb` Ethereum를 하드포크합니다.
- 본 Repo는 Docker Image `ethereum/client-go:v1.14.5`을 고정합니다.
- Validator Deposit Contract는 `0x4242424242424242424242424242424242424242`에 배포됩니다.
- Network 및 Client에 적용되는 환경 변수는 `.env`에서 설정할 수 있습니다.
- 기본적으로 모든 RPC Host는 `127.0.0.1`로 설정되어 있습니다.
- Geth로 계정을 생성하는 경우, `./execution/password.txt` 파일을 통해 Keystore 비밀번호를 설정할 수 있습니다.
- [Optional] blockscout는 기본적으로 `http://localhost:4001`에서 실행됩니다.

</br>

## FAQ / Common Issues
- ``` bash
  WARN [06-20|01:45:18.368] Post-merge network, but no beacon client seen. Please launch one to follow the chain!
  ```
  Execution Layer와 Consensus Layer가 연결되지 않은 경우 발생하는 경고(WARN) Log입니다.

- ```bash
  ERROR[06-20|01:45:24.534] Nil finalized block cannot evict old blobs
  ```
  첫번째 블록이 확정성을 얻지 못해서 발생하는 애러 입니다. Ethereum Mainnet 기준으로 128 블록 생성 후 확정성을 얻으면 자연스럽게 없어집니다.
  ````
  # https://github.com/ethereum/go-ethereum/blob/27008408a57c77e55d3630adb50c72b0a36abb32/core/txpool/blobpool/limbo.go#L115 
  Just in case there's no final block yet (network not yet merged, weird restart, sethead, etc), fail gracefully.
  ````
  