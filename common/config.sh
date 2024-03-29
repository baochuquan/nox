#!/bin/sh

source $NOX_COMMON/utils.sh

function value_of_yaml() {
    local configFile="$2"
    local version=`yq --version | tr ' ' '\n' | tail -n1 | cut -d '.' -f1`
    version=`echo $version | sed  's/[^0-9.]*\([0-9.]*\).*/\1/'`
    local value
    if [[ $version -ge 4 ]]; then
        value=`yq e ".$1" $configFile`
    else
        value=`yq r $configFile $1`
    fi
    echo $value
}

function config_value_of() {
    local configFile="$NOX_CONFIG/config.yaml"
    local version=`yq --version | tr ' ' '\n' | tail -n1 | cut -d '.' -f1`
    version=`echo $version | sed  's/[^0-9.]*\([0-9.]*\).*/\1/'`
    local value
    if [[ $version -ge 4 ]]; then
        value=`yq e ".$1" $configFile`
    else
        value=`yq r $configFile $1`
    fi
    echo $value
}

function brewspec_value_of() {
    local configFile="$NOX_CONFIG/brewspec.yaml"
    local version=`yq --version | tr ' ' '\n' | tail -n1 | cut -d '.' -f1`
    version=`echo $version | sed  's/[^0-9.]*\([0-9.]*\).*/\1/'`
    local value
    if [[ $version -ge 4 ]]; then
        value=`yq e ".$1" $configFile`
    else
        value=`yq r $configFile $1`
    fi
    echo $value
}

function ldap() {
    local ldap=`config_value_of ldap`
    if [[ -z $ldap || $ldap == 'null' ]]; then
        error "The value of key \`ldap\` in $NOX_CONFIG/config.yaml is not initialized. Please initialize it."
        exit 1
    fi
    echo $ldap
}