#!/bin/bash
check_and_create_folder() {
    local folder_name="$1"
    if [ "$(basename "$PWD")" = "$folder_name" ]; then
        echo "Sudah berada di dalam folder '$folder_name'."
    elif [ ! -d "$folder_name" ]; then
        echo "Folder '$folder_name' tidak ditemukan. Membuat folder..."
        mkdir -p "$folder_name"
    else
        echo "Folder '$folder_name' sudah ada."
    fi
    echo "Lokasi folder: $(pwd)/$folder_name"
}

check_and_create_folder "t3rn"
cd t3rn || { echo "Gagal berpindah ke folder t3rn"; exit 1; }

# Input variabel
read -p "Masukkan NODE_ENV [testnet]: " NODE_ENV
NODE_ENV=${NODE_ENV:-testnet}

read -p "Masukkan LOG_LEVEL [debug]: " LOG_LEVEL
LOG_LEVEL=${LOG_LEVEL:-debug}

read -p "LOG_PRETTY [false]: " LOG_PRETTY
LOG_PRETTY=${LOG_PRETTY:-false}

read -p "EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API [false]: " EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API
EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=${EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API:-false}

read -p "EXECUTOR_PROCESS_ORDERS_API_ENABLED [false]: " EXECUTOR_PROCESS_ORDERS_API_ENABLED
EXECUTOR_PROCESS_ORDERS_API_ENABLED=${EXECUTOR_PROCESS_ORDERS_API_ENABLED:-false}

read -p "EXECUTOR_ENABLE_BATCH_BIDING [true]: " EXECUTOR_ENABLE_BATCH_BIDING
EXECUTOR_ENABLE_BATCH_BIDING=${EXECUTOR_ENABLE_BATCH_BIDING:-true}

read -p "EXECUTOR_PROCESS_BIDS_ENABLED [true]: " EXECUTOR_PROCESS_BIDS_ENABLED
EXECUTOR_PROCESS_BIDS_ENABLED=${EXECUTOR_PROCESS_BIDS_ENABLED:-true}

read -p "Masukkan EXECUTOR_MAX_L3_GAS_PRICE [e.g 1000]: " EXECUTOR_MAX_L3_GAS_PRICE
EXECUTOR_MAX_L3_GAS_PRICE=${EXECUTOR_MAX_L3_GAS_PRICE:-1000}

read -p "Masukkan PRIVATE_KEY_LOCAL: " PRIVATE_KEY_LOCAL

read -p "Masukkan ENABLED_NETWORKS [e.g arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn]: " ENABLED_NETWORKS
ENABLED_NETWORKS=${ENABLED_NETWORKS:-'arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'}

# Endpoint RPC
read -p "Masukkan RPC_ENDPOINTS_ARBT: " RPC_ENDPOINTS_ARBT
RPC_ENDPOINTS_ARBT=${RPC_ENDPOINTS_ARBT:-""}

read -p "Masukkan RPC_ENDPOINTS_BSSP: " RPC_ENDPOINTS_BSSP
RPC_ENDPOINTS_BSSP=${RPC_ENDPOINTS_BSSP:-""}

read -p "Masukkan RPC_ENDPOINTS_BLSS: " RPC_ENDPOINTS_BLSS
RPC_ENDPOINTS_BLSS=${RPC_ENDPOINTS_BLSS:-""}

read -p "Masukkan RPC_ENDPOINTS_OPSP: " RPC_ENDPOINTS_OPSP
RPC_ENDPOINTS_OPSP=${RPC_ENDPOINTS_OPSP:-""}

read -p "Masukkan RPC_ENDPOINTS_L1RN [e.g https://brn.rpc.caldera.xyz/ or https://brn.calderarpc.com/http]: " RPC_ENDPOINTS_L1RN
RPC_ENDPOINTS_L1RN=${RPC_ENDPOINTS_L1RN:-'https://brn.rpc.caldera.xyz/'}

export NODE_ENV
export LOG_LEVEL
export LOG_PRETTY
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API
export EXECUTOR_PROCESS_ORDERS_API_ENABLED
export EXECUTOR_ENABLE_BATCH_BIDING
export EXECUTOR_PROCESS_BIDS_ENABLED
export EXECUTOR_MAX_L3_GAS_PRICE
export PRIVATE_KEY_LOCAL
export ENABLED_NETWORKS
export RPC_ENDPOINTS_ARBT
export RPC_ENDPOINTS_BSSP
export RPC_ENDPOINTS_BLSS
export RPC_ENDPOINTS_OPSP
export RPC_ENDPOINTS_L1RN

echo "Variabel lingkungan telah diatur:"
printenv | grep -E 'NODE_ENV|LOG_LEVEL|LOG_PRETTY|EXECUTOR|PRIVATE_KEY_LOCAL|ENABLED_NETWORKS|RPC_ENDPOINTS'

# Menjalankan executor
echo "Menjalankan executor..."
if [ -x "./executor/executor/bin/executor" ]; then
    ./executor/executor/bin/executor
else
    echo "Error: Tidak dapat menemukan atau menjalankan executor. Pastikan direktori benar."
fi
