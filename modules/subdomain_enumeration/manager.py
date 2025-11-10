# modules/subdomain_enumeration/manager.py

from pathlib import Path
from datetime import datetime
import json
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(message)s")

class SubdomainManager:
    """
    Handles saving, structuring, and reporting for Subdomain Enumeration outputs.
    """

    def __init__(self, domain: str, out_base: str = "DESERT_out"):
        self.domain = domain
        self.out_base = Path(out_base)
        self.work_dir = self.out_base / domain / "subenum"
        self.work_dir.mkdir(parents=True, exist_ok=True)

    def _write_file(self, filename: str, data):
        path = self.work_dir / filename
        if isinstance(data, list):
            data = "\n".join(data)
        path.write_text(data, encoding="utf-8", errors="ignore")
        logger.info(f"💾 Saved: {path}")
        return path

    def save_results(self, subdomains, alive=None):
        alive = alive or []
        self._write_file("subdomains.txt", subdomains)
        self._write_file("alive.txt", alive)

    def save_report(self, meta):
        meta["timestamp"] = datetime.utcnow().isoformat()
        json_path = self.work_dir / "subenum_report.json"
        json_path.write_text(json.dumps(meta, indent=4))
        logger.info(f"📄 Report saved: {json_path}")
