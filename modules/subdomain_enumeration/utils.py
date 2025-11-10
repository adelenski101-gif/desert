# modules/subdomain_enumeration/utils.py

def remove_duplicates(items):
    return sorted(set([x.strip() for x in items if x.strip()]))
