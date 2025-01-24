#!/bin/bash
# Installer for Piper TTS
# Author: bigun27 based

# Check architecture
if [ $(uname -m) == 'x86_64' ]; then
    pkgarch="x86_64"
elif [ $(uname -m) == 'aarch64' ]; then
    pkgarch="aarch64"
elif [ $(uname -m) == 'armv7l' ]; then
    pkgarch="armv7l"
else
    echo "Unsupported architecture. Please run on x86_64, aarch64, or armv7l."
    exit 1
fi

# Store Piper TTS in the /opt directory
cd /opt

# Download Piper TTS from GitHub releases
echo "Downloading Piper TTS..."
curl -s https://api.github.com/repos/rhasspy/piper/releases/latest | jq -r ".assets[] | select(.name == \"piper_linux_${pkgarch}.tar.gz\") | .browser_download_url" > piper_downloads.txt 2>&1
if [ $? != 0 ]; then
    echo "Failed to download Piper TTS. Check your internet connection and try again."
    exit 1
fi

wget -q -O piper_linux_${pkgarch}.tar.gz -i piper_downloads.txt
if [ $? != 0 ]; then
    echo "Failed to download Piper TTS package."
    exit 1
fi

# Clean up the temporary file after validation
rm -f piper_downloads.txt
tar -xf piper_linux_${pkgarch}.tar.gz
if [ $? != 0 ]; then
    echo "Error extracting Piper TTS package."
    exit 1
fi
rm -f piper_linux_${pkgarch}.tar.gz

# Download Piper TTS voice data
echo "Downloading en_US-lessac-medium voice model..."
cd ./piper
wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx -O en_US-lessac-medium.onnx
if [ $? != 0 ]; then
    echo "Failed to download voice model."
    exit 1
fi

wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json -O en_US-lessac-medium.onnx.json
if [ $? != 0 ]; then
    echo "Failed to download voice model configuration."
    exit 1
fi

# Set appropriate permissions
chmod 644 en_US-*.{onnx,onnx.json}

ln -sf /opt/piper/piper /usr/bin/piper
echo "Piper TTS installed successfully!"

# Optionally, add usage instructions:
echo "To use Piper TTS, run:"
echo "piper --help"
exit 0