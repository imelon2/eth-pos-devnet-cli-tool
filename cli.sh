# default로 .env 설정
env_file=".env"

for arg in "$@"; do
    case $arg in
        --env=* | --e=*) 
            env_file="${arg#*=}" 
            ;;
        *)
            ;;
    esac
done

# 파일 존재 여부 확인
if [ -f "$env_file" ]; then
    source "$env_file"
else
    echo "Error: $env_file does not exist."
    exit 1
fi

echo "== 🛠️ Set ENV $env_file\n"

func_help()
{
    echo Usage:
    echo "  ./cli.sh [command]"
    echo
    echo Available Commands:
    echo "  execution, e       Run Geth Cli"
    echo "  consensus, c       Run Prysm Cli"
    echo "  clean              Clean Geth & Prysm DB"
    echo "  blockscout, b      Run Blockscout Cli"
    echo
    echo Golobal Options:
    echo "  --env=, e=         Set env Path (DEFAULT .env)"
}

func_execution_help()
{
    echo Usage:
    echo "  ./cli.sh execution [command]"
    echo
    echo Available Commands:
    echo "  new-account, new        Create a new account (PATH:/data/keystore)"
    echo "  list-account, list      Print summary of existing accounts"
    echo "  init                    Bootstrap and initialize a new genesis block"
    echo "  run                     Run go-ethereum Execution Layer Node"
    echo "  attach, a               Start an interactive JavaScript environment (PATH:/data/geth.ipc)"
    echo "  clean                   Remove blockchain and state databases (PATH:/data)"
}

func_consensus_help()
{
    echo Usage:
    echo "  ./cli.sh consensus [command]"
    echo
    echo Available Commands:
    echo "  generate-genesis, gg      Generate genesis.json (PATH: $GENESIS_ROOT)"
    echo "  create-jwt-secret, jwt    Create JWT secret (PATH: $JWTSECRET_ROOT)"
    echo "  run-beacon-chain, runb    Run Consensus Layer beacon Node"
    echo "  run-validator, runv       Run Consensus Layer Validator"
    echo "  clean                     Remove beacochain and validator databases"
}

# func_blockscout_help()
# {
#     echo Usage:
#     echo "  ./cli.sh blockscout [command]"
#     echo
#     echo Available Commands:
#     echo "  run              Run Geth Node Explorer (RPC: geth:$GETH_HTTP_PORT)"
# }

func_execution()
{
    case "$1" in
        "new-account"|"new")
            echo "Run go-ethereum account new -- 🚀"
            docker compose run --rm geth account new --datadir $EXECUTION_ROOT/data --password $PASSWORD_ROOT
            ;;
        "list-account"|"list")
            echo "Run go-ethereum account list -- 🚀"
            docker compose run --rm geth account list --datadir $EXECUTION_ROOT/data 
            ;;
        "init")
            echo "Run go-ethereum init genesis block -- 🚀"
            docker compose --env-file $env_file run --no-deps --rm geth-genesis --datadir $EXECUTION_ROOT/data init $GENESIS_ROOT
            ;;
        "run")
            echo "Run Execution Layer go-ethereum Node -- 🚀"
            docker compose -p $PROJECT_NAME --env-file $env_file up --no-deps -d geth
            ;;
        "export")
            echo "Backup Execution Layer Node DB -- 🚀"
            # docker compose stop geth
            docker compose run --no-deps --rm geth-genesis --datadir $EXECUTION_ROOT/data/geth export $EXECUTION_ROOT/backup/data
            # docker compose restart geth --no-deps 
            ;;
        "import")
            echo "Import Execution Layer Node DB -- 🚀"
            docker compose run --no-deps --rm geth-genesis --datadir $EXECUTION_ROOT/data/geth import $EXECUTION_ROOT/backup/data
            ;;
        "attach"| "a")
            docker compose -p $PROJECT_NAME --env-file $env_file run --no-deps --rm geth-genesis attach $EXECUTION_ROOT/data/geth.ipc
            ;;
        "clean")
            echo "Clear go-ethereum DB & Genesis -- 🗑️"
            rm -rf ./execution/data/geth
            ;;
        "help" | "-h")
            func_execution_help
            ;;
        *)
        func_execution_help
        ;;
    esac
}

func_consensus()
{
    case "$1" in
        "generate-genesis" | "gg")
            echo "Generate genesis.json -- 🚀"
            docker compose run --no-deps --rm create-beacon-chain-genesis
            ;;
        "script")
            echo "Generate genesis.json -- 🚀"
            docker compose run --no-deps --rm --entrypoint sh geth-genesis -c "geth --help"
            # docker compose run --no-deps --rm create-beacon-chain-genesis weak-subjectivity cpt --beacon-node-host=beacon-chain:3500
            # docker compose run --no-deps --rm create-beacon-chain-genesis checkpoint-sync download --beacon-node-host=beacon-chain:3500
            # docker compose run --no-deps --rm create-beacon-chain-genesis db buckets --path=${CONSENSUS_ROOT}/beacondata/beaconchaindata/beaconchain.db --help
            # docker compose run --no-deps --rm validator accounts list
            # docker compose run --no-deps --rm geth-genesis removedb --datadir=${EXECUTION_ROOT}/data
            ;;
        "create-jwt-secret" | "jwt")
            echo "Create JWT secret -- 🚀"
            docker compose run --no-deps --rm beacon-chain generate-auth-secret --output-file=${JWTSECRET_ROOT}
            ;;
        "run-beacon-chain" | "runb")
            echo "Run Consensus Layer beacon Node -- 🚀"
            docker compose -p $PROJECT_NAME --env-file $env_file up --no-deps -d beacon-chain
            ;;
        "run-validator" | "runv")
            echo "Run Consensus Layer Validator -- 🚀"
            docker compose -p $PROJECT_NAME --env-file $env_file up --no-deps -d validator
            ;;
        "validator-slashing" | "vslashing")
            echo "Run Consensus Layer Validator -- 🚀"
            docker compose run --no-deps --rm validator \
                slashing-protection-history \
                export \
                --datadir=${CONSENSUS_ROOT}/validatordata \
                --slashing-protection-export-dir=${CONSENSUS_ROOT}/validatordata/slash \
                --accept-terms-of-use
            ;;
        "beacon-restore" | "brestore")
            echo "Run Consensus Layer Validator -- 🚀"
            docker compose run --no-deps --rm beacon-chain \
                db restore \
                --restore-source-file=${CONSENSUS_ROOT}/bea/beaconchain.db \
                --restore-target-dir=${CONSENSUS_ROOT}/beacondata
            ;;
        "validator-restore" | "vrestore")
            echo "Run Consensus Layer Validator -- 🚀"
            docker compose run --no-deps --rm validator db \
                restore \
                --restore-source-file=${CONSENSUS_ROOT}/vali/validator.db \
                --restore-target-dir=${CONSENSUS_ROOT}/validatordata
                # migrate down --datadir ${CONSENSUS_ROOT}/validatordata
            ;;
        # "validator-list" | "vlist")
        #     echo "Run Consensus Layer Validator -- 🚀"
        #     docker compose run --no-deps --rm validator accounts list --wallet-dir=${CONSENSUS_ROOT}/validatordata/slach --accept-terms-of-use
        #     ;;
        "clean")
            echo "Clear Beacon data & validator Data -- 🗑️"
            rm -Rf ./consensus/beacondata ./consensus/validatordata # ./consensus/genesis.ssz
            ;;
        "help" | "-h")
            func_consensus_help
            ;;
        *)
        func_consensus_help
        ;;
    esac
}

func_blockscout()
{
    case "$1" in
        "run")
            echo "Run Geth Node Explorer -- 🚀"
            docker compose -p $PROJECT_NAME up -d blockscout
            ;;
        "help" | "-h")
            func_blockscout_help
            ;;
        *)
        func_blockscout_help
        ;;
    esac
}

func_Run_Node()
{
    echo "==== RUN NODE $PROJECT_NAME"

    if [ ! -f "$V_CONFIG_DIR/jwtsecret" ]; then
        echo "Create JWT secret -- 🚀"
        docker compose -p $PROJECT_NAME --env-file $env_file run --no-deps --rm beacon-chain generate-auth-secret --output-file=${JWTSECRET_ROOT}
    fi

    if [ ! -f "$V_CONFIG_DIR/genesis.ssz" ]; then
        echo "Generate genesis.ssz -- 🚀"
        docker compose -p $PROJECT_NAME --env-file $env_file run --no-deps --rm create-beacon-chain-genesis
    fi


    if [ -d "$V_EXECUTION_ROOT/data/geth" ]; then
        echo "Error: Geth Path $V_EXECUTION_ROOT already used."
        exit 1
    elif [ -d "$V_CONSENSUS_ROOT/beacondata" ]; then
        echo "Error: Beacon Path $V_CONSENSUS_ROOT already used."
        exit 1
    elif [ -d "$V_CONSENSUS_ROOT/validatordata" ]; then
        echo "Error: Validator Path $V_CONSENSUS_ROOT already used."
        exit 1
    fi

    echo "Run go-ethereum init genesis block -- 🚀"
    docker compose --env-file $env_file run --no-deps --rm geth-genesis --datadir $EXECUTION_ROOT/data init $GENESIS_ROOT

    echo "Run Geth, Beacon, Validator node -- 🚀"
    docker compose -p $PROJECT_NAME --env-file $env_file up --no-deps -d beacon-chain
    docker compose -p $PROJECT_NAME --env-file $env_file up --no-deps -d geth
    docker compose -p $PROJECT_NAME --env-file $env_file up --no-deps -d validator
}

case "$1" in
    "execution" | "e")
        func_execution $2
        ;;
    "consensus" | "c")
        func_consensus $2
        ;;
    "blockscout" | "b")
        func_blockscout $2
        ;;   
    "bbackup")
        # docker compose pause beacon-chain validator
        curl http://127.0.0.1:8081/db/backup
        cp ./consensus/beacondata/beaconchaindata/beaconchain.db ./consensus/bea
        ;;   
    "gbackup")
        docker compose stop geth
        docker compose run --no-deps --rm geth-genesis --datadir $EXECUTION_ROOT/data/geth export $EXECUTION_ROOT/backup/data
        docker compose restart geth --no-deps 
        ;;   
    "backup")
        curl http://127.0.0.1:8081/db/backup
        docker compose pause beacon-chain validator
        docker compose stop geth
        docker compose run --no-deps --rm geth-genesis --datadir $EXECUTION_ROOT/data/geth export $EXECUTION_ROOT/backup/data
        cp ./consensus/beacondata/beaconchaindata/beaconchain.db ./consensus/bea
        docker compose unpause beacon-chain validator
        docker compose restart geth --no-deps 
        ;;   
    "run")
        func_Run_Node
        ;;
    "clean" | "c")
        echo "Clear go-ethereum DB & Genesis -- 🗑️"
        echo "Clear Beacon data & validator Data -- 🗑️"
        rm -Rf $V_CONSENSUS_ROOT/beacondata $V_CONSENSUS_ROOT/validatordata
        rm -rf $V_EXECUTION_ROOT/data/geth
        ;;
    "help" | "h")
        func_help
        ;;
    *)
    func_help
    ;;
esac