# .env 파일의 경로 설정
env_file=".env"

# 파일 존재 여부 확인
if [ -f "$env_file" ]; then
    source "$env_file"
else
    echo "Error: $env_file does not exist."
    exit 1
fi


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

func_blockscout_help()
{
    echo Usage:
    echo "  ./cli.sh blockscout [command]"
    echo
    echo Available Commands:
    echo "  run              Run Geth Node Explorer (RPC: geth:$GETH_HTTP_PORT)"
}

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
            docker compose run --rm geth init --datadir $EXECUTION_ROOT/data $GENESIS_ROOT
            ;;
        "run")
            echo "Run Execution Layer go-ethereum Node -- 🚀"
            docker compose -p $PROJECT_NAME up -d geth
            ;;
        "attach"| "a")
            docker compose run --rm geth-scripts attach $EXECUTION_ROOT/data/geth.ipc
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
            docker compose run --rm create-beacon-chain-genesis
            ;;
        "create-jwt-secret" | "jwt")
            echo "Create JWT secret -- 🚀"
            docker compose run --rm beacon-chain generate-auth-secret --output-file=${JWTSECRET_ROOT}
            ;;
        "run-beacon-chain" | "runb")
            echo "Run Consensus Layer beacon Node -- 🚀"
            docker compose -p $PROJECT_NAME up -d beacon-chain
            ;;
        "run-validator" | "runv")
            echo "Run Consensus Layer Validator -- 🚀"
            docker compose -p $PROJECT_NAME up -d validator
            ;;
        "clean")
            echo "Clear Beacon data & validator Data -- 🗑️"
            rm -Rf ./consensus/beacondata ./consensus/validatordata ./consensus/genesis.ssz
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
    "clean" | "c")
        rm -Rf ./consensus/beacondata ./consensus/validatordata ./consensus/genesis.ssz
        rm -rf ./execution/data/geth
        ;;
    "help" | "h")
        func_help
        ;;
    *)
    func_help
    ;;
esac