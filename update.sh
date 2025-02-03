# Download latest release
latest_tag=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
filename="executor-linux-${latest_tag}.tar.gz"

wget "https://github.com/t3rn/executor-release/releases/download/${latest_tag}/${filename}"

# Extract the downloaded tar.gz file
tar -xzf "$filename"
rm "$filename"

echo "Update success!"
echo "Enter ./t3rn.sh to start the executor!"
