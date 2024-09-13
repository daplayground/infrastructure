SHELL := /bin/bash

.PHONY: cleanup

packer-build:
	cd aws/packer && packer build packer-al2.pkr.hcl

cleanup-oldest-ami:
	@echo "Finding the oldest AMI..."
	@TEMP_AMI=$$(aws ec2 describe-images --owners self --query 'Images[*].[ImageId,CreationDate]' --output text | sort -k2 | head -n 1 | awk '{print $$1}'); \
	if [ -z "$$TEMP_AMI" ]; then \
		echo "No AMI found."; \
	else \
		echo "Oldest AMI found: $$TEMP_AMI"; \
		TEMP_SNAPSHOT_ID=$$(aws ec2 describe-images --image-ids $$TEMP_AMI --query "Images[*].BlockDeviceMappings[*].Ebs.SnapshotId" --output text); \
		if [ -n "$$TEMP_SNAPSHOT_ID" ]; then \
			echo "Deregistering AMI $$TEMP_AMI and deleting snapshot $$TEMP_SNAPSHOT_ID..."; \
			aws ec2 deregister-image --image-id $$TEMP_AMI; \
			aws ec2 delete-snapshot --snapshot-id $$TEMP_SNAPSHOT_ID; \
		else \
			echo "No snapshot ID found for AMI $$TEMP_AMI"; \
		fi \
	fi

terraform-02-apply:
	terraform -chdir=./aws/terraform/02-cluster apply -auto-approve

terraform-02-destroy:
	terraform -chdir=./aws/terraform/02-cluster destroy -auto-approve
