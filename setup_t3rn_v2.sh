#!/bin/bash

ask_with_default() {
    local prompt="$1"
    local default_value="$2"
    read -p "$prompt [$default_value]: " input
    echo "${input:-$default_value}"
}

check_and_create_folder() {
    local folder_name="$1"
    if [ "$(basename "$PWD")" = "$folder_name" ]; then
        echo "✅ Already in folder '$folder_name'."
    elif [ ! -d "$folder_name" ]; then
        echo "📂 Folder '$folder_name' not found. Creating folder..."
        mkdir -p "$folder_name"
    else
        echo "📂 Folder '$folder_name' already exists."
    fi
    cd "$folder_name" || { echo "❌ Failed to switch to folder $folder_name"; exit 1; }
}

check_and_create_folder "t3rn"

echo "🔍 Fetching version list from GitHub..."
VERSIONS=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases | \
grep -Po '"tag_name": "\K.*?(?=")' | head -n 5)

echo "📋 Available versions:"
i=1
echo "$VERSIONS" | while read -r version; do
    echo "  $i. $version"
    ((i++))
done

while true; do
    read -p "Choose version number (1-5) [1]: " VERSION_CHOICE
    VERSION_CHOICE=${VERSION_CHOICE:-1}
    if [[ "$VERSION_CHOICE" =~ ^[1-5]$ ]]; then
        break
    else
        echo "❌ Invalid choice. Enter a number between 1-5."
    fi
done

SELECTED_VERSION=$(echo "$VERSIONS" | sed -n "${VERSION_CHOICE}p")
echo "🔄 Selected version: $SELECTED_VERSION"

EXECUTOR_FILE="executor-linux-${SELECTED_VERSION}.tar.gz"
echo "🆕 Downloading executor file version ${SELECTED_VERSION}..."
wget "https://github.com/t3rn/executor-release/releases/download/${SELECTED_VERSION}/${EXECUTOR_FILE}" --show-progress

echo "📦 Extracting executor file..."
tar -xzf "$EXECUTOR_FILE"

rm -f "$EXECUTOR_FILE"

cd executor/executor/bin || { echo "❌ Failed to enter executor directory"; exit 1; }

configure_environment() {
    echo "⚙️  Executor Configuration"
    ENVIRONMENT=$(ask_with_default "Enter ENVIRONMENT" "testnet")
    LOG_LEVEL=$(ask_with_default "Enter LOG_LEVEL" "debug")
    LOG_PRETTY=$(ask_with_default "LOG_PRETTY" "false")
    EXECUTOR_PROCESS_ORDERS_ENABLED=$(ask_with_default "EXECUTOR_PROCESS_ORDERS_ENABLED" "true")
    EXECUTOR_PROCESS_CLAIMS_ENABLED=$(ask_with_default "EXECUTOR_PROCESS_CLAIMS_ENABLED" "true")
    EXECUTOR_PROCESS_BIDS_ENABLED=$(ask_with_default "EXECUTOR_PROCESS_BIDS_ENABLED" "true")
    EXECUTOR_ENABLE_BATCH_BIDING=$(ask_with_default "EXECUTOR_PROCESS_BIDS_ENABLED" "true")
    EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=$(ask_with_default "EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API" "false")
    EXECUTOR_PROCESS_ORDERS_API_ENABLED=$(ask_with_default "EXECUTOR_PROCESS_ORDERS_API_ENABLED" "false")
    EXECUTOR_MAX_L3_GAS_PRICE=$(ask_with_default "Enter EXECUTOR_MAX_L3_GAS_PRICE" "100")
    PRIVATE_KEY_LOCAL=$(ask_with_default "Enter PRIVATE_KEY_LOCAL" "")
    ENABLED_NETWORKS=$(ask_with_default "Enter ENABLED_NETWORKS" "arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,unichain-sepolia,l2rn")
    
    APIKEY_ALCHEMY=$(ask_with_default "Enter Alchemy API Key (leave blank if none)" "")

    RPC_ENDPOINTS_L2RN="https://b2n.rpc.caldera.xyz/http"
   
    if [ -n "$APIKEY_ALCHEMY" ]; then
        RPC_ENDPOINTS_ARBT="https://arbitrum-sepolia.drpc.org,https://arb-sepolia.g.alchemy.com/v2/$APIKEY_ALCHEMY"
        RPC_ENDPOINTS_BAST="https://base-sepolia-rpc.publicnode.com,https://base-sepolia.g.alchemy.com/v2/$APIKEY_ALCHEMY"
        RPC_ENDPOINTS_BLST="https://sepolia.blast.io,https://blast-sepolia.g.alchemy.com/v2/$APIKEY_ALCHEMY"
        RPC_ENDPOINTS_OPST="https://sepolia.optimism.io,https://opt-sepolia.g.alchemy.com/v2/$APIKEY_ALCHEMY"
        RPC_ENDPOINTS_UNIT="https://unichain-sepolia.drpc.org,https://unichain-sepolia.g.alchemy.com/v2/$APIKEY_ALCHEMY"
    else
        RPC_ENDPOINTS_ARBT=$(ask_with_default "Enter RPC_ENDPOINTS_ARBT" "https://arbitrum-sepolia.drpc.org")
        RPC_ENDPOINTS_BAST=$(ask_with_default "Enter RPC_ENDPOINTS_BAST" "https://base-sepolia-rpc.publicnode.com")
        RPC_ENDPOINTS_BLST=$(ask_with_default "Enter RPC_ENDPOINTS_BLST" "https://sepolia.blast.io")
        RPC_ENDPOINTS_OPST=$(ask_with_default "Enter RPC_ENDPOINTS_OPST" "https://sepolia.optimism.io")
        RPC_ENDPOINTS_UNIT=$(ask_with_default "Enter RPC_ENDPOINTS_UNIT" "https://unichain-sepolia.drpc.org")
    fi

    RPC_ENDPOINTS_JSON=$(cat <<EOF
{
    "l2rn": ["$RPC_ENDPOINTS_L2RN"],
    "arbt": ["$(echo $RPC_ENDPOINTS_ARBT | sed 's/,/", "/g')"],
    "bast": ["$(echo $RPC_ENDPOINTS_BAST | sed 's/,/", "/g')"],
    "blst": ["$(echo $RPC_ENDPOINTS_BLST | sed 's/,/", "/g')"],
    "opst": ["$(echo $RPC_ENDPOINTS_OPST | sed 's/,/", "/g')"],
    "unit": ["$(echo $RPC_ENDPOINTS_UNIT | sed 's/,/", "/g')"]
}
EOF
)
}

while true; do
    configure_environment

    export ENVIRONMENT
    export LOG_LEVEL
    export LOG_PRETTY
    export EXECUTOR_PROCESS_BIDS_ENABLED
    export EXECUTOR_ENABLE_BATCH_BIDING
    export EXECUTOR_PROCESS_ORDERS_ENABLED
    export EXECUTOR_PROCESS_CLAIMS_ENABLED
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API
    export EXECUTOR_PROCESS_ORDERS_API_ENABLED
    export EXECUTOR_MAX_L3_GAS_PRICE
    export PRIVATE_KEY_LOCAL
    export ENABLED_NETWORKS
    export RPC_ENDPOINTS="$RPC_ENDPOINTS_JSON"

    echo "✅ Environment variables to be set:"
    printenv | grep -E 'ENVIRONMENT|LOG_LEVEL|LOG_PRETTY|EXECUTOR|PRIVATE_KEY_LOCAL|ENABLED_NETWORKS|RPC_ENDPOINTS'

    while true; do
        read -p "Is the configuration correct? (y/n) [y]: " CONFIRM
        CONFIRM=${CONFIRM:-y}
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            break 2
        elif [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
            echo "🔄 Repeating configuration..."
            break
        else
            echo "❌ Enter 'y' for yes or 'n' for no."
        fi
    done
done

echo "🚀 Running executor..."
if [ -x "./executor" ]; then
    ./executor
else
    echo "❌ Error: Cannot find or run executor. Ensure the directory is correct."
fi
