# Backend Access and Recovery

## State ownership and access

Bootstrap uses local state unless explicitly migrated. Keep encrypted,
access-restricted backups of its state outside Git. Development state uses
S3 at dev/terraform.tfstate with native S3 locking.

State and saved plans may contain sensitive values. Never commit them.

The backend policy in reference/backend-access-policy.template.json is an
illustrative identity policy for the default workspace. Replace its bucket
placeholder and review effective permissions before use. It permits state
read/write and lock-file management, without granting state deletion,
bucket administration or infrastructure provisioning. Other workspaces
require separately reviewed paths.

Use temporary role credentials. Actual IAM permissions remain unverified.

Reference: https://developer.hashicorp.com/terraform/language/backend/s3

## Deletion safeguards

The bucket configuration enables versioning, SSE-S3 encryption, public-access
blocking and HTTPS-only access. force_destroy is false; prevent_destroy
is true.

prevent_destroy protects Terraform operations while the resource remains
in configuration. It does not prevent console deletion or deletion after
removing the resource configuration. Versioning is not an independent backup.

## Recovery before future live work

1. Confirm the intended account, region, backend bucket and state key.
2. Securely preserve available bootstrap state, development state, backend
   configuration and S3 object versions before changing anything.
3. Inventory actual resources and compare them with state. Manual deletion
   can leave stale state entries. Never apply an old saved plan.
4. If the backend survives, review state lineage, serial, versions and locks.
   Recover a deleted object from a reviewed retained version where available,
   with all writers stopped.
5. Recreating an empty bucket does not recover lost state. If backups are
   unavailable, inventory surviving resources and deliberately reconstruct
   their mappings through reviewed imports. Use a fresh environment only
   after establishing that no existing resources will be orphaned.
6. Recover lost bootstrap state from backup or import surviving bootstrap
   resources through a reviewed procedure.
7. Reconcile state and configuration during separately authorised live work.
   Review a fresh plan, expected replacements and costs before applying.

Only force-unlock after confirming the original writer has stopped and
checking the lock identity. State removal is not a substitute for inventory.

No recovery, import, refresh, plan or deployment was performed during this
offline maintenance.
