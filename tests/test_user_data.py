from pathlib import Path
import os
import re
import shlex
import subprocess
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[1]


class UserDataTests(unittest.TestCase):
    def script(self):
        text = (ROOT / "modules/compute/main.tf").read_text()
        match = re.search(
            r"user_data\s*=\s*<<-EOF\n(.*?)^\s*EOF",
            text, re.S | re.M
        )
        self.assertIsNotNone(match)
        return textwrap.dedent(match.group(1))

    def test_shell_syntax(self):
        subprocess.run(["bash", "-n"], input=self.script(), text=True, check=True)

    def test_success_and_fail_fast(self):
        for failed in ("", "dnf", "nginx", "systemctl", "curl"):
            with self.subTest(failed=failed), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                calls = root / "calls"
                for name in ("dnf", "nginx", "systemctl", "curl"):
                    p = root / name
                    p.write_text(
                        '#!/bin/sh\n'
                        f'echo {name} >> "$CALL_LOG"\n'
                        f'[ "$FAIL_COMMAND" != "{name}" ] || exit 7\n'
                        'exit 0\n'
                    )
                    p.chmod(0o755)

                # Redirect only the test fixture's output into disposable storage.
                script = self.script().replace(
                    "/usr/share/nginx/html/index.html",
                    shlex.quote(str(root / "index.html"))
                )
                env = dict(
                    os.environ, PATH=tmp+":"+os.environ["PATH"],
                    CALL_LOG=str(calls), FAIL_COMMAND=failed
                )
                result = subprocess.run(
                    ["bash"], input=script, env=env, text=True,
                    capture_output=True, timeout=10
                )
                if failed:
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("Instance setup failed", result.stderr)
                    self.assertNotIn("setup completed successfully", result.stdout)
                    self.assertEqual(calls.read_text().splitlines()[-1], failed)
                else:
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn("setup completed successfully", result.stdout)
                    self.assertIn("Terraform AWS Platform Foundation",
                                  (root / "index.html").read_text())


if __name__ == "__main__":
    unittest.main()
