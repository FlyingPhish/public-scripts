## Public Scripts

A small collection of various homemade or modified scripts that may prove useful to people. Nothing amazing or ground-breaking but useful.


## satisfied.php

This is a small php script that takes two or three files which contain IP addresses and counts each reoccurance of that IP in those files. This is designed to make sure that the scope has been fully scanned. Useful for ITHC and PCI jobs.

:~/tools$ php satisfied.php original-scope.txt nessus-results.txt

Array
(

    [1.1.1.1] => 2
    [1.1.1.2] => 1
    [1.1.1.3] => 2
    [1.1.1.4] => 1
)

## gips.sh

A very simple script that takes greps IPs from a file or piped output, sorts it and removes any duplicates. Useful for grabbing IPs from a tool output or a mixed format scope.

gips.sh file.txt

nmap x x x | gips.sh

## no_prison

A small ruby script that creates a file with a list of IPs for your scope/test/assessment. You give it two files with IP addresses w/ CIDR notations, one which has in-scope IPs and the other with ones out of scope (if they intertwine). This then creates a final file that has all the IPs in scope, its great if you CANNOT even ping or touch an out of scope IP.

ruby no_prison.rb inscope.txt outscope.txt

## no_prison

Very barebones bash loop to run wfuzz against a list of URLs.

wfuzz-loop.sh path/to/wordlist path/to/file/with/urls.txt

## Advisory

All the scripts listed in this repository should only be used for authorized penetration testing and/or educational purposes. Any misuse of this software will not be the responsibility of the author or of any other collaborator. Use it on your own networks and/or systems with the network owner's permission. Furthermore, please use at your own risk as the author or any other collaborator are not responsible for any issues or trouble caused!
