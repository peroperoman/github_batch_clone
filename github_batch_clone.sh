#!/bin/bash

COMMON_URL=https://api.github.com

### Temp file
TMP=$(mktemp)
trap 'rm -f $TMP' EXIT

### Functions
display_usage()
{
cat <<EOF

Required settings for .env .
================================
    GITHUB_TOKEN=""
    GITHUB_ACCOUNT=""
    ORGANIZATION_NAME=""
================================

Usage:
    $(basename ${0}) <type>

Note:
    <type> are must arguments.

<type>:
    user => User Repository.
    org  => Organization Repository.

EOF
}

load_env(){
    if [ ! -s ./.env ] ; then
        display_usage
        exit 1
    else
        source ./.env
    fi
}

list_repos(){
    end_point=$1
    i=1
    while true ;do
        curl -s \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            ${COMMON_URL}/${end_point}/repos?page=$i \
            | jq ".[].clone_url" | grep [a-z] >> $TMP || break
        ((i++))
    done
}

clone_repos(){
    while read repo ;do
        git clone ${repo//\"/}
    done < $TMP
}

### Main
load_env
case "$1" in
    user)
        list_repos user 2>/dev/null ;;
    org)
        list_repos orgs/${ORG_NAME} 2>/dev/null ;;
    *)
        display_usage
        exit 1 ;;
esac
clone_repos

exit 0
