## Public Scripts

A small collection of various homemade or modified scripts that may prove useful to people. Nothing amazing or ground-breaking but useful.

Version 1.5 is the current version.

## count_ip.php

This is a small php script that takes two or three files which contain IP addresses and counts each reoccurance of that IP in those files. This is designed to make sure that the scope has been fully scanned. Useful for ITHC and PCI jobs.

:~/tools$ php count_ip.php original-scope.txt nessus-results.txt

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



## Advisory

All the scripts listed in this repository should only be used for authorized penetration testing and/or educational purposes. Any misuse of this software will not be the responsibility of the author or of any other collaborator. Use it on your own networks and/or systems with the network owner's permission. Furthermore, please use at your own risk as the author or any other collaborator are not responsible for any issues or trouble caused!
