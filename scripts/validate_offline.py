"""Validate disposable configuration copies without accessing AWS or state."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    subprocess.run(
        ["terraform", "fmt", "-check", "-recursive"],
        cwd=ROOT, check=True
    )
    with tempfile.TemporaryDirectory(prefix="terraform-validation-") as tmp:
        target = Path(tmp) / "repository"
        shutil.copytree(
            ROOT, target,
            ignore=shutil.ignore_patterns(
                ".git", ".terraform", "*.tfstate*", "*.tfplan",
                "*.tfvars", "__pycache__", ".venv", ".tools-venv"
            )
        )
        config = Path(tmp) / "terraform.rc"
        config.write_text("disable_checkpoint = true\n")
        env = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("AWS_", "TF_CLI_ARGS", "TF_VAR_"))
            and key not in ("TF_DATA_DIR", "TF_WORKSPACE")
        }
        env.update({
            "TF_CLI_CONFIG_FILE": str(config),
            "CHECKPOINT_DISABLE": "1",
            "AWS_EC2_METADATA_DISABLED": "true",
            "AWS_CONFIG_FILE": os.devnull,
            "AWS_SHARED_CREDENTIALS_FILE": os.devnull,
            "TF_IN_AUTOMATION": "true"
        })
        for directory in ("bootstrap", "environments/dev"):
            work = target / directory
            print(f"Validating {directory} without backend initialization...", flush=True)
            subprocess.run(
                ["terraform", "init", "-backend=false", "-input=false",
                 "-lockfile=readonly"],
                cwd=work, env=env, check=True
            )
            subprocess.run(
                ["terraform", "validate", "-no-color"],
                cwd=work, env=env, check=True
            )
    print("PASS: formatting and provider-schema validation")
    print("No plan, apply, refresh, import or remote-state operation performed.")


if __name__ == "__main__":
    main()
