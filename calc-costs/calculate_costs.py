#!/usr/bin/env python3
import argparse
import re


def parse_services(filepath):
    """Extract service titles and days from text file."""
    services = []
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Match Title and Days pairs
    pattern = r'Title:\s*(.+?)\s*\nDays:\s*([\d.]+)'
    matches = re.findall(pattern, content)
    
    for title, days in matches:
        services.append({'title': title.strip(), 'days': float(days)})
    
    return services


def calculate_costs(services, day_rate, fee=None, discount=None):
    """
    Calculate costs with optional fee and discount.
    
    Calculation order: (base_cost + fee) * (1 - discount_rate)
    If no fee/discount provided, returns standard day_rate * days
    """
    results = []
    total = 0
    
    for service in services:
        base_cost = service['days'] * day_rate
        working_cost = base_cost
        adjustments = []
        
        # Apply fee first (flat addition)
        if fee is not None:
            fee_amount = base_cost * (fee / 100)
            working_cost += fee_amount
            adjustments.append(f"+{fee}% fee")
        
        # Apply discount to the cost (including any fee)
        if discount is not None:
            discount_amount = working_cost * (discount / 100)
            working_cost -= discount_amount
            adjustments.append(f"-{discount}% discount")
        
        # Format adjustment description
        if adjustments:
            adj_type = ", ".join(adjustments)
        else:
            adj_type = "standard rate"
        
        results.append({
            'title': service['title'],
            'days': service['days'],
            'base_cost': base_cost,
            'final_cost': working_cost,
            'adjustment': adj_type
        })
        total += working_cost
    
    return results, total


def main():
    parser = argparse.ArgumentParser(
        description='Calculate service costs from day rates',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s services.txt                           # Standard calculation
  %(prog)s services.txt --fee 15                 # Add 15%% fee
  %(prog)s services.txt --discount 10            # Apply 10%% discount  
  %(prog)s services.txt --fee 20 --discount 5    # Add 20%% fee, then 5%% discount
        """
    )
    
    parser.add_argument('file', help='Text file with services')
    parser.add_argument('--day-rate', type=float, default=1450, 
                       help='Day rate (default: 1450)')
    parser.add_argument('--fee', type=float, 
                       help='Fee percentage to add (e.g., 10 for 10%%)')
    parser.add_argument('--discount', type=float,
                       help='Discount percentage to subtract (e.g., 20 for 20%%)')
    
    args = parser.parse_args()
    
    services = parse_services(args.file)
    results, total = calculate_costs(services, args.day_rate, args.fee, args.discount)
    
    # Output header
    adjustment_info = []
    if args.fee:
        adjustment_info.append(f"{args.fee}% fee")
    if args.discount:
        adjustment_info.append(f"{args.discount}% discount")
    
    adj_text = f" ({', '.join(adjustment_info)})" if adjustment_info else ""
    
    print(f"\nDay Rate: ${args.day_rate:,.2f}{adj_text}")
    print("-" * 60)
    
    # Service details
    for r in results:
        print(f"\n{r['title']}")
        print(f"  Days: {r['days']}")
        print(f"  Base: ${r['base_cost']:,.2f}")
        print(f"  Calculation: {r['adjustment']}")
        print(f"  Final: ${r['final_cost']:,.2f}")
    
    print("-" * 60)
    print(f"TOTAL: ${total:,.2f}\n")


if __name__ == '__main__':
    main()