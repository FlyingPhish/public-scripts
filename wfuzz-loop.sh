#!/bin/bash
# USAGE
# wfuzz-loop.sh path/to/wordlist urls.txt

printf "\nRunning WFuzz with word list $1 against $2. Results saved to wfuzz-list-output.txt"
echo ""
while read -r url; do wfuzz --script=listing,robots,sitemap -c -L --no-cache --hc 418,404,403,401,301 -w $1 $url/FUZZ | tee -a wfuzz-list-output.txt; done < $2
