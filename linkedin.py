#!/usr/bin/env python3
"""
LinkedIn Google Search Parser for OSINT
Extracts names and generates username/email lists for penetration testing
"""

import re
import sys
from argparse import ArgumentParser
from pathlib import Path


def extract_names(text):
    """Extract names from LinkedIn search results."""
    names = []
    
    # Pattern: "LinkedIn · Name"
    for match in re.finditer(r'LinkedIn\s*·\s*([A-Z][a-zA-Z\s\'-]+)', text):
        name = match.group(1).strip()
        # Basic validation - must have at least 2 parts (first + last)
        if len(name.split()) >= 2:
            names.append(name)
    
    return names


def generate_usernames(name, formats=['filn']):
    """
    Generate username variations.
    
    Formats:
    - filn: first initial + last name (jdoe)
    - firstln: first name + last initial (johnd)
    - first.last: first.last (john.doe)
    - flast: full first + last (johndoe)
    """
    parts = name.lower().split()
    if len(parts) < 2:
        return []
    
    first = parts[0]
    last = parts[-1]
    
    # Remove non-alphanumeric
    first = re.sub(r'[^a-z]', '', first)
    last = re.sub(r'[^a-z]', '', last)
    
    usernames = []
    
    for fmt in formats:
        if fmt == 'filn':
            usernames.append(f"{first[0]}{last}")
        elif fmt == 'firstln':
            usernames.append(f"{first}{last[0]}")
        elif fmt == 'first.last':
            usernames.append(f"{first}.{last}")
        elif fmt == 'flast':
            usernames.append(f"{first}{last}")
    
    return usernames


def main():
    parser = ArgumentParser(description='Parse LinkedIn search results for OSINT')
    parser.add_argument('input_file', help='Input file with LinkedIn search results')
    parser.add_argument('-d', '--domain', help='Email domain (e.g., company.com)')
    parser.add_argument('-f', '--format', default='filn', 
                       help='Username format (comma-separated for multiple). Options: '
                            'filn=jdoe, firstln=johnd, first.last=john.doe, flast=johndoe '
                            '(default: filn)')
    parser.add_argument('-o', '--output', help='Output file (default: stdout)')
    
    args = parser.parse_args()
    
    # Read input
    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f"Error: {args.input_file} not found", file=sys.stderr)
        return 1
    
    text = input_path.read_text()
    
    # Extract names
    names = extract_names(text)
    
    # Deduplicate and sort
    names = sorted(set(names))
    
    # Parse formats
    formats = [f.strip() for f in args.format.split(',')]
    
    # Prepare output
    output_lines = []
    
    output_lines.append("# Names")
    output_lines.append("-" * 60)
    for name in names:
        output_lines.append(name)
    
    output_lines.append("\n# Usernames")
    output_lines.append("-" * 60)
    for name in names:
        usernames = generate_usernames(name, formats)
        for username in usernames:
            output_lines.append(username)
    
    if args.domain:
        output_lines.append("\n# Email Addresses")
        output_lines.append("-" * 60)
        for name in names:
            usernames = generate_usernames(name, formats)
            for username in usernames:
                output_lines.append(f"{username}@{args.domain}")
    
    # Write output
    result = '\n'.join(output_lines)
    
    if args.output:
        Path(args.output).write_text(result)
        print(f"Output written to {args.output}")
    else:
        print(result)
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
