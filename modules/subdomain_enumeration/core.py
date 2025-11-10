# modules/subdomain_enumeration/core.py

from modules.subdomain_enumeration.runner import SubdomainRunner
from modules.subdomain_enumeration.parser import SubdomainParser
from modules.subdomain_enumeration.manager import SubdomainManager
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(message)s")

class SubdomainEnumerator:
    """
    Main controller for subdomain enumeration.
    """

    def __init__(self, domain: str, out_base: str = "DESERT_out"):
        self.domain = domain
        self.out_base = out_base
        self.runner = SubdomainRunner(domain, out_base)
        self.parser = SubdomainParser(domain, out_base)
        self.manager = SubdomainManager(domain, out_base)

    def run(self, force=False, probe=True):
        logger.info(f"🚀 Starting Subdomain Enumeration for {self.domain}")
        raw_files = self.runner.run(force=force, probe=probe)
        subs, alive = self.parser.parse_results(raw_files)
        self.manager.save_results(subs, alive)
        self.manager.save_report({
            "total_subdomains": len(subs),
            "alive": len(alive),
            "tools": ["subfinder", "findomain", "assetfinder", "crt.sh"]
        })
        logger.info(f"✅ Enumeration completed for {self.domain}")
