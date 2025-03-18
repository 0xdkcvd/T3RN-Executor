#!/bin/bash

# Fungsi untuk meminta input dengan nilai default
ask_with_default() {
    local prompt="$1"
    local default_value="$2"
    read -p "$prompt [$default_value]: " input
    echo "${input:-$default_value}"
}

# Cek dan buat folder jika belum ada
check_and_create_folder() {
    local folder_name="$1"
    if [ "$(basename "$PWD")" = "$folder_name" ]; then
        echo "✅ Sudah berada di dalam folder '$folder_name'." 
    elif [ ! -d "$folder_name" ]; then
        echo "📂 Folder '$folder_name' tidak ditemukan. Membuat folder..."
        mkdir -p "$folder_name"
    else
        echo "📂 Folder '$folder_name' sudah ada."
    fi
    cd "$folder_name" || { echo "❌ Gagal berpindah ke folder $folder_name"; exit 1; }
}

# Setup folder kerja
check_and_create_folder "t3rn"

# Dapatkan versi terbaru dari GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -Po '"tag_name": "\K.*?(?=")')

echo "🔄 Versi terbaru: $LATEST_VERSION"

# Unduh file dari GitHub menggunakan wget
EXECUTOR_FILE="executor-linux-${LATEST_VERSION}.tar.gz"
echo "🆕 Mengunduh file executor versi ${LATEST_VERSION}..."
wget "https://github.com/t3rn/executor-release/releases/download/${LATEST_VERSION}/${EXECUTOR_FILE}"

# Ekstrak file
echo "📦 Mengekstrak file executor..."
tar -xzf "$EXECUTOR_FILE"

# Menghapus file tar setelah ekstraksi
rm -f "$EXECUTOR_FILE"

# Masuk ke direktori binary executor
cd executor/executor/bin || { echo "❌ Gagal masuk ke direktori executor"; exit 1; }

# Konfigurasi interaktif
echo "⚙️  Konfigurasi Executor"
ENVIRONMENT=$(ask_with_default "Masukkan ENVIRONMENT" "testnet")
LOG_LEVEL=$(ask_with_default "Masukkan LOG_LEVEL" "debug")
LOG_PRETTY=$(ask_with_default "LOG_PRETTY" "false")
EXECUTOR_PROCESS_ORDERS_ENABLED=$(ask_with_default "EXECUTOR_PROCESS_ORDERS_ENABLED" "true")
EXECUTOR_PROCESS_CLAIMS_ENABLED=$(ask_with_default "EXECUTOR_PROCESS_CLAIMS_ENABLED" "true")
EXECUTOR_PROCESS_BIDS_ENABLED=$(ask_with_default "EXECUTOR_PROCESS_BIDS_ENABLED" "true")
EXECUTOR_MAX_L3_GAS_PRICE=$(ask_with_default "Masukkan EXECUTOR_MAX_L3_GAS_PRICE" "100")
PRIVATE_KEY_LOCAL=$(ask_with_default "Masukkan PRIVATE_KEY_LOCAL" "")
ENABLED_NETWORKS=$(ask_with_default "Masukkan ENABLED_NETWORKS" "arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn")

# Konfigurasi RPC_ENDPOINTS
RPC_ENDPOINTS_L2RN=$(ask_with_default "Masukkan RPC_ENDPOINTS_L2RN" "https://b2n.rpc.caldera.xyz/http")
RPC_ENDPOINTS_ARBT=$(ask_with_default "Masukkan RPC_ENDPOINTS_ARBT" "https://arbitrum-sepolia.drpc.org,https://sepolia-rollup.arbitrum.io/rpc")
RPC_ENDPOINTS_BAST=$(ask_with_default "Masukkan RPC_ENDPOINTS_BAST" "https://base-sepolia-rpc.publicnode.com,https://base-sepolia.drpc.org")
RPC_ENDPOINTS_OPST=$(ask_with_default "Masukkan RPC_ENDPOINTS_OPST" "https://sepolia.optimism.io,https://optimism-sepolia.drpc.org")
RPC_ENDPOINTS_UNIT=$(ask_with_default "Masukkan RPC_ENDPOINTS_UNIT" "https://unichain-sepolia.drpc.org,https://sepolia.unichain.org")

# Format ulang sebagai JSON
RPC_ENDPOINTS_JSON=$(cat <<EOF
{
    "l2rn": ["$RPC_ENDPOINTS_L2RN"],
    "arbt": ["$(echo $RPC_ENDPOINTS_ARBT | sed 's/,/", "/g')"],
    "bast": ["$(echo $RPC_ENDPOINTS_BAST | sed 's/,/", "/g')"],
    "opst": ["$(echo $RPC_ENDPOINTS_OPST | sed 's/,/", "/g')"],
    "unit": ["$(echo $RPC_ENDPOINTS_UNIT | sed 's/,/", "/g')"]
}
EOF
)

# Set environment variable
export ENVIRONMENT
export LOG_LEVEL
export LOG_PRETTY
export EXECUTOR_PROCESS_BIDS_ENABLED
export EXECUTOR_PROCESS_ORDERS_ENABLED
export EXECUTOR_PROCESS_CLAIMS_ENABLED
export EXECUTOR_MAX_L3_GAS_PRICE
export PRIVATE_KEY_LOCAL
export ENABLED_NETWORKS
export RPC_ENDPOINTS="$RPC_ENDPOINTS_JSON"

echo "✅ Variabel lingkungan telah diatur:"
printenv | grep -E 'ENVIRONMENT|LOG_LEVEL|LOG_PRETTY|EXECUTOR|PRIVATE_KEY_LOCAL|ENABLED_NETWORKS|RPC_ENDPOINTS'

# Menjalankan executor
echo "🚀 Menjalankan executor..."
if [ -x "./executor" ]; then
    ./executor
else
    echo "❌ Error: Tidak dapat menemukan atau menjalankan executor. Pastikan direktori benar."
fi
