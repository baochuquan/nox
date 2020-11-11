#!/bin/sh

source $NOX_COMMON/utils.sh

function ldap() {
    local configFile="$NOX_CONFIG/config.yaml"
    local ldap=`yq r $configFile ldap`
    if [[ -z $ldap ]]; then
        error "The value of key \`ldap\` in config.yaml is not initialized. Please initialize it. See example in \`$NOX_TEMPLATES/config-template.yaml.\`"
        exit 1
    fi
    echo $ldap
}
