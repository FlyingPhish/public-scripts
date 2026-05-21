#!/usr/bin/env python3
import re
import ipaddress
import sys

def extract_ips(text):
    """Extract individual IP addresses from text"""
    return re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', text)

def extract_cidrs(text):
    """Extract CIDR blocks from text"""
    return re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}/\d{1,2}\b', text)

def sort_ips(ip_list):
    """Sort IP addresses numerically"""
    return sorted(set(ip_list), key=lambda ip: tuple(map(int, ip.split('.'))))

def sort_cidrs(cidr_list):
    """Sort CIDR blocks numerically"""
    return sorted(set(cidr_list), key=lambda cidr: tuple(map(int, cidr.split('/')[0].split('.'))))

def is_private(ip_or_cidr):
    """Check if IP or CIDR is private"""
    if '/' in ip_or_cidr:
        return ipaddress.ip_network(ip_or_cidr, strict=False).is_private
    return ipaddress.ip_address(ip_or_cidr).is_private

def validate_ip(ip):
    """Validate individual IP address"""
    try:
        parts = ip.split('.')
        return all(0 <= int(part) <= 255 for part in parts)
    except ValueError:
        return False

def validate_cidr(cidr):
    """Validate CIDR block"""
    try:
        ipaddress.ip_network(cidr, strict=False)
        return True
    except ValueError:
        return False

def calculate_usable_ips(cidr):
    """Calculate number of usable IPs in a CIDR block"""
    try:
        network = ipaddress.ip_network(cidr, strict=False)
        prefix_len = network.prefixlen
        
        # Special cases for /31 and /32
        if prefix_len == 32:
            return 1  # Host route
        elif prefix_len == 31:
            return 2  # Point-to-point link
        else:
            # Standard calculation: total IPs minus network and broadcast
            total_ips = 2 ** (32 - prefix_len)
            return total_ips - 2
    except ValueError:
        return 0

def ip_in_cidr_list(ip, cidr_list):
    """Check if an IP address is contained within any CIDR block"""
    try:
        ip_addr = ipaddress.ip_address(ip)
        for cidr in cidr_list:
            network = ipaddress.ip_network(cidr, strict=False)
            if ip_addr in network:
                return True
        return False
    except ValueError:
        return False

def filter_standalone_ips(ips, cidrs):
    """Remove IPs that are already covered by CIDR blocks"""
    return [ip for ip in ips if not ip_in_cidr_list(ip, cidrs)]

def main(filename):
    with open(filename) as f:
        content = f.read()

    # Extract and validate IPs
    raw_ips = extract_ips(content)
    valid_ips = [ip for ip in raw_ips if validate_ip(ip)]
    
    # Extract and validate CIDRs
    raw_cidrs = extract_cidrs(content)
    valid_cidrs = [cidr for cidr in raw_cidrs if validate_cidr(cidr)]
    
    # Separate private/public
    private_cidrs = sort_cidrs([cidr for cidr in valid_cidrs if is_private(cidr)])
    public_cidrs = sort_cidrs([cidr for cidr in valid_cidrs if not is_private(cidr)])
    
    # Filter out IPs already covered by CIDRs
    private_ips_raw = [ip for ip in valid_ips if is_private(ip)]
    public_ips_raw = [ip for ip in valid_ips if not is_private(ip)]
    
    private_ips = sort_ips(filter_standalone_ips(private_ips_raw, private_cidrs))
    public_ips = sort_ips(filter_standalone_ips(public_ips_raw, public_cidrs))
    
    # Calculate totals
    private_ip_count = len(private_ips)
    public_ip_count = len(public_ips)
    private_cidr_ips = sum(calculate_usable_ips(cidr) for cidr in private_cidrs)
    public_cidr_ips = sum(calculate_usable_ips(cidr) for cidr in public_cidrs)
    
    # Output results
    print(f"=== STANDALONE IPs ===")
    print(f"Private IPs ({private_ip_count}):")
    if private_ips:
        print("\n".join(private_ips))
    else:
        print("(None - all IPs covered by CIDR blocks)")
    
    print(f"\nPublic IPs ({public_ip_count}):")
    if public_ips:
        print("\n".join(public_ips))
    else:
        print("(None)")
    
    print(f"\n=== CIDR BLOCKS ===")
    print(f"Private CIDRs ({len(private_cidrs)}):")
    for cidr in private_cidrs:
        usable = calculate_usable_ips(cidr)
        print(f"{cidr} ({usable} usable IPs)")
    
    print(f"\nPublic CIDRs ({len(public_cidrs)}):")
    for cidr in public_cidrs:
        usable = calculate_usable_ips(cidr)
        print(f"{cidr} ({usable} usable IPs)")
    
    # Summary
    total_private = private_ip_count + private_cidr_ips
    total_public = public_ip_count + public_cidr_ips
    total_scannable = total_private + total_public
    
    print(f"\n=== SCAN SUMMARY ===")
    print(f"Total private IPs to scan: {total_private}")
    print(f"Total public IPs to scan: {total_public}")
    print(f"TOTAL IPs to scan: {total_scannable}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} <file.txt>")
        sys.exit(1)
    main(sys.argv[1])