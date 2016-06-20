#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: checkdep repo_name [optional: custom yum.conf]"
	echo "Example: checkdep centos7-rutgers-testing-temp"
	exit 0
fi

if [[ $# -eq 2 && ! -f "$2" ]]; then
    echo "That file does not exist"
    exit 1
fi

input=$1
ver=${input//[^0-9]/}
error=false

echo "Checking Dependencies"

if [[ $ver -lt 7 ]]; then
    if [[ $# -eq 2 ]]; then
        repoclosure -t -r $1 --config=/etc/repotools2-yum.conf --config=$2 \
            -l base$ver-32 -l updates$ver-32 -l extras$ver-32 \
            -l base$ver -l updates$ver -l extras$ver > /tmp/repolines.txt
    else
        repoclosure -t -r $1 --config=/etc/repotools2-yum.conf \
            -l base$ver-32 -l updates$ver-32 -l extras$ver-32 \
            -l base$ver -l updates$ver -l extras$ver > /tmp/repolines.txt
    fi
else
    if [[ $# -eq 2 ]]; then
        repoclosure -t -r $1 --config=/etc/repotools2-yum.conf --config=$2 \
            -l base$ver -l updates$ver -l extras$ver > /tmp/repolines.txt
    else
        repoclosure -t -r $1 --config=/etc/repotools2-yum.conf \
            -l base$ver -l updates$ver -l extras$ver > /tmp/repolines.txt
    fi
fi

sed -n '/unresolved\ deps/{:a;n;/package:\ /b;p;ba}' /tmp/repolines.txt \
    > /tmp/unresolved_deps.txt

touch /tmp/real_dep_problems.txt

while read line; do
    grep -q -i $line /etc/depcheck2.ignore
    if [[ "$?" != "0" ]]; then
        echo "Missing dependency: $line" > tee -a /tmp/real_dep_problems.txt
        error=true
    fi
done < /tmp/unresolved_deps.txt

if [ "$error" = true ]; then
    echo -e "\nDependency errors detected:"
    cat /tmp/real_dep_problems.txt
    echo "\nOutput from repoclosure:"
    cat /tmp/repolines.txt
    echo -e ""
    exit 1
fi

rm /tmp/real_dep_problems.txt
rm /tmp/repolines.txt
rm /tmp/unresolved_deps.txt

echo "No Dependency errors found"

exit 0
