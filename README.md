## Public Scripts

A small collection of various homemade or modified scripts that may prove useful to people. Nothing amazing or ground-breaking but useful.

## gips.sh

A very simple script that takes greps IPs from a file or piped output, sorts it and removes any duplicates. Useful for grabbing IPs from a tool output or a mixed format scope.
```
gips.sh file.txt
nmap x x x | gips.sh
```

## orderips

Smol script that does the same as gips but does not remove non IPs.
```
orderips file.txt
nmap x... | orderips
```

## jwt-decode.ps1

PowerShell script that used PSJWT module to take a JWT token, which is then decoded for JWT information, including pre-calcuated expiry dates and how long the token is active for.

```
./jwt-decode.ps1
# Paste the whole JWT into the Password field (done this way for local security of your JWTs)
```

## List-Resources.ps1

This small PowerShell script uses AZ CLI to get a list of resources for each environment you're logged into. You can use this tool for specific tenants and subscriptions. This tool will generate two csvs, one that contains all the resources and some details, the other only contains the total numbers of resources and the quanity per resource type 

```
.\List-Resources.ps1 -AllSubscriptions
.\List-Resources.ps1 -TenantId x-x-x-x -Subscriptions idOne,IdTwo,IdThree
.\List-Resources.ps1 -AllSubscriptions -TenantId x-x-x-x


```

## satisfied.php

This is a small php script that takes two or three files which contain IP addresses and counts each reoccurance of that IP in those files. This is designed to make sure that the scope has been fully scanned. Useful for ITHC and PCI jobs.
```
:~/tools$ php satisfied.php original-scope.txt nessus-results.txt

Array
(

    [1.1.1.1] => 2
    [1.1.1.2] => 1
    [1.1.1.3] => 2
    [1.1.1.4] => 1
)
```

## no_prison

A small ruby script that creates a file with a list of IPs for your scope/test/assessment. You give it two files with IP addresses w/ CIDR notations, one which has in-scope IPs and the other with ones out of scope (if they intertwine). This then creates a final file that has all the IPs in scope, its great if you CANNOT even ping or touch an out of scope IP.

```ruby no_prison.rb inscope.txt outscope.txt```

## nwfuzz-loop.sh

Very barebones bash loop to run wfuzz against a list of URLs.

```wfuzz-loop.sh path/to/wordlist path/to/file/with/urls.txt```

## Advisory

All the scripts listed in this repository should only be used for authorized penetration testing and/or educational purposes. Any misuse of this software will not be the responsibility of the author or of any other collaborator. Use it on your own networks and/or systems with the network owner's permission. Furthermore, please use at your own risk as the author or any other collaborator are not responsible for any issues or trouble caused!
