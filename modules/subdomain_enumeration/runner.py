# modules/subdomain_enumeration/runner.py

import subprocess
from pathlib import Path
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(message)s")


class SubdomainRunner:
    """
    Runs the Bash subenum.sh script for a given domain.
    """

    def __init__(self, domain: str, out_base: str):
        self.domain = domain
        self.out_base = Path(out_base)
        self.script = Path(__file__).parent / "tools" / "subenum.sh"

    def run(self, force=False, probe=True):
        if not self.script.exists():
            raise FileNotFoundError(f"Missing script: {self.script}")

        cmd = [
            "bash",
            str(self.script),
            self.domain,
            str(self.out_base)
        ]

        if force:
            cmd.append("--force")
        if not probe:
            cmd.append("--no-probe")

        logger.info(f"⚙️ Running Bash script: {' '.join(cmd)}")
        subprocess.run(cmd, check=True)

        subenum_dir = self.out_base / self.domain / "subenum"
        return {
            "subdomains": subenum_dir / "subdomains.txt",
            "alive": subenum_dir / "alive.txt"
        }
