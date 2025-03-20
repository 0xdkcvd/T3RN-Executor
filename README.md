# t3rn Executor (V2)

This Bash script automates the process of downloading, extracting, configuring, and running the t3rn Executor binary on a Linux system. It fetches available versions from the t3rn GitHub repository, allows the user to select a version, and sets up environment variables interactively, including optional integration with Alchemy RPC endpoints.

## Features
- Downloads the latest or user-selected version of the t3rn Executor from GitHub.
- Creates a working directory (`t3rn`) if it doesn't exist.
- Configures environment variables.
- Supports Alchemy API key integration for RPC endpoints.

## Prerequisites
Ensure the following tools are installed on your system:
- `bash` 
- `curl` 
- `wget` 
- `tar` 

You can install these dependencies on a Debian-based system (e.g., Ubuntu) with:
```bash
sudo apt update
sudo apt install curl wget tar
```
## Usage
Clone or Download the Script
Save the script as setup_executor.sh (or any preferred name).
Make the Script Executable
```bash
chmod +x setup_executor.sh
```
Run the Script
```bash
./setup_executor.sh
```
## Follow the Prompts
- Select a version of the executor (1-5) from the displayed list.
- Provide configuration values or press Enter to accept defaults.
- Confirm the configuration when prompted.
