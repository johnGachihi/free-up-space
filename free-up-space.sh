#!/bin/bash

# Removes old disabled snap versions
echo -e "\e[32m1. Removing disabled snap versions\e[0m"

LANG=C snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done


# Reduce journalctl log size
echo
echo
echo -e "\e[32m2. Reducing journalctl log size to 100MB\e[0m"
journalctl --vacuum-size=100000000


# Delete node_modules for js project not accessed in a while
DELETE_THRESHOLD=30

echo
echo
echo -e "\e[32m3. Removing node_modules directory from projects that have not been used in the last $DELETE_THRESHOLD days\e[0m"
echo

js_project_homes=(~/ReactProjects ~/VueProjects ~/IdeaProjects /var/www/html)

for home in "${js_project_homes[@]}"; do
    for d in $home/*/; do
        secs_since_mtime=`expr $(date +%s) - $(date -r "$d" +%s)`
        days_since_mtime=`expr $secs_since_mtime / 86400`

        if [ $days_since_mtime -gt $DELETE_THRESHOLD -a -d "$d/node_modules" ]; then
            echo -e "\e[32m$d\e[0m"
            echo -e "Last accessed \e[31m$days_since_mtime\e[0m days ago"
            echo -e "\tDelete node_modules (y/n)"
            rm -r -I "$d/node_modules"
            
            if ! [ -d "$d/node_modules" ]; then
                echo "Deleted."
            else
                echo "Skipped."
            fi
            echo
        fi
    done
done
