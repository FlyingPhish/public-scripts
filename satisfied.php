<?php
error_reporting(E_ERROR | E_PARSE);
/*
VERSION 1.0 - 12/2020
SCRIPT THAT COUNTS HOW MANY TIMES IPs ARE LISTED ACROSS MULTIPLE FILES.
THIS SCRIPT IS USED TO CHECK IF YOU'VE SCANNED/PENTESTED ALL IPs WITHIN THE CLIENT'S SCOPE.

EXAMPLE: php satisfied.php client-scope.txt scanned-hosts.txt optional-extra-files.txt

@FlyingPhishy

*/

//USER ARGS
$scope = file_get_contents($argv[1], true);
$nessusHosts = file_get_contents($argv[2], true);
$additionalFile = file_get_contents($argv[3], true);

//IP ARRAYS
$ipArray1 = [];
$ipArray2 = [];
$ipArray3 = [];

//FORMAT THE ARRAY AND POPULATE WITH FILES
$ipArray1 = explode(PHP_EOL, $scope);
$ipArray2 = explode(PHP_EOL, $nessusHosts);
$ipArray3 = explode(PHP_EOL, $additionalFile);

//MERGE ARRAYS
$result = array_merge($ipArray1, $ipArray2, $ipArray3);

print_r(array_count_values(array_filter($result)))
?>
