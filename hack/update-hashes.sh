#!/bin/bash

# Update Talos SHA hashes for a given version
# Example: ./hack/update-hashes.sh 1.10.8

set -euo pipefail

VERSION=${1:-}

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.10.8"
    exit 1
fi

# Remove 'v' prefix if present
VERSION=${VERSION#v}

echo "Updating Talos hashes for version $VERSION..."

# Base URL for Talos releases
BASE_URL="https://github.com/siderolabs/talos/releases/download/v${VERSION}"

# Download sha256sum.txt file
echo "Downloading sha256sum.txt for version $VERSION..."
SHA256SUM_URL="${BASE_URL}/sha256sum.txt"
SHA256_FILE=$(mktemp)

if ! curl -sL "$SHA256SUM_URL" -o "$SHA256_FILE"; then
    echo "Error: Failed to download sha256sum.txt from $SHA256SUM_URL"
    rm -f "$SHA256_FILE"
    exit 1
fi

# Function to extract hash from sha256sum.txt
get_hash_from_file() {
    local filename="$1"
    grep " ${filename}$" "$SHA256_FILE" | cut -d' ' -f1 || {
        echo "Error: Hash for $filename not found in sha256sum.txt"
        return 1
    }
}

# Get hashes for x86_64
echo "Getting x86_64 hashes from sha256sum.txt..."
X86_64_KERNEL_SHA=$(get_hash_from_file "vmlinuz-amd64")
X86_64_INITRD_SHA=$(get_hash_from_file "initramfs-amd64.xz")

# Get hashes for aarch64
echo "Getting aarch64 hashes from sha256sum.txt..."
AARCH64_KERNEL_SHA=$(get_hash_from_file "vmlinuz-arm64")
AARCH64_INITRD_SHA=$(get_hash_from_file "initramfs-arm64.xz")

# Update x86_64.yml
echo "Updating vars/x86_64.yml..."
sed -i.bak \
    -e "s/talos_kernel_sha: sha256:.*/talos_kernel_sha: sha256:${X86_64_KERNEL_SHA}/" \
    -e "s/talos_initrd_sha: sha256:.*/talos_initrd_sha: sha256:${X86_64_INITRD_SHA}/" \
    vars/x86_64.yml

# Update aarch64.yml
echo "Updating vars/aarch64.yml..."
sed -i.bak \
    -e "s/talos_kernel_sha: sha256:.*/talos_kernel_sha: sha256:${AARCH64_KERNEL_SHA}/" \
    -e "s/talos_initrd_sha: sha256:.*/talos_initrd_sha: sha256:${AARCH64_INITRD_SHA}/" \
    vars/aarch64.yml

# Clean up backup files and temporary sha256sum file
rm -f vars/x86_64.yml.bak vars/aarch64.yml.bak "$SHA256_FILE"

echo "Successfully updated Talos hashes for version $VERSION"
echo ""
echo "Updated files:"
echo "- vars/x86_64.yml"
echo "  - Kernel SHA: $X86_64_KERNEL_SHA"
echo "  - Initrd SHA: $X86_64_INITRD_SHA"
echo "- vars/aarch64.yml"
echo "  - Kernel SHA: $AARCH64_KERNEL_SHA"
echo "  - Initrd SHA: $AARCH64_INITRD_SHA"
