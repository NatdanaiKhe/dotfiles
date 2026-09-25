#!/bin/bash

# Make sure these are exported in your shell first:
export COMPARTMENT_ID=$(grep tenancy ~/.oci/config | cut -d'=' -f2)
export IMAGE_ID="ocid1.image.oc1.ap-singapore-1.aaaaaaaarvebhiz35pmlhie7zzshzia7d473n4mrcz4inbwex2xh577rakoq"
export SUBNET_ID="ocid1.subnet.oc1.ap-singapore-1.aaaaaaaawjpyzr7a3uooqv3rh5cs2smwp35qav7r4ymfbwdhe5mtt2iindaq"

SSH_KEY_PATH="$HOME/.ssh/ssh-oci-key.pub"

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "SSH public key not found at $SSH_KEY_PATH"
  exit 1
fi

while true; do
  oci compute instance launch \
    --availability-domain "AD-1" \
    --compartment-id "$COMPARTMENT_ID" \
    --shape "VM.Standard.A1.Flex" \
    --shape-config '{"ocpus":4,"memoryInGBs":24}' \
    --image-id "$IMAGE_ID" \
    --subnet-id "$SUBNET_ID" \
    --assign-public-ip true \
    --display-name "main-vps" \
    --metadata "{\"ssh_authorized_keys\":\"$(cat $SSH_KEY_PATH)\"}" \
    --wait-for-state RUNNING

  if [ $? -eq 0 ]; then
    echo "✅ Instance created successfully!"
    break
  fi

  echo "❌ Out of capacity, retrying in 60s... ($(date))"
  sleep 60
done
