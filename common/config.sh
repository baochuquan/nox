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

function jira_token() {
    local configFile="$NOX_CONFIG/config.yaml"
    local token=`yq r $configFile jira-token`
    if [[ -z $token ]]; then
        error "The value of key \`jira-token\` in config.yaml is not initialized. Please initialize it. See example in \`$NOX_TEMPLATES/config-template.yaml.\`"
        echo "API Token 获取方式：\`https://jira.zhenguanyu.com\` -> 点击右上角用户名 -> 点击【 Configure 】-> 点击【 Add New Token 】"
        exit 1
    fi
    echo $token
}

function jenkins_token() {
    local configFile="$NOX_CONFIG/config.yaml"
    local token=`yq r $configFile jenkins-token`
    if [[ -z $token ]]; then
        error "The value of key \`jenkins-token\` in config.yaml is not initialized. Please initialize it. See example in \`$NOX_TEMPLATES/config-template.yaml.\`"
        echo "API Token 获取方式：\`https://build.zhenguanyu.com\` -> 点击右上角用户头像 -> 选择【 API Token Authentication 】-> 点击【 New API Token 】按钮"
        exit 1
    fi
    echo $token
}

function gerrit_token() {
    local configFile="$NOX_CONFIG/config.yaml"
    local token=`yq r $configFile gerrit-token`
    if [[ -z $token ]]; then
        error "The value of key \`gerrit-token\` in config.yaml is not initialized. Please initialize it. See example in \`$NOX_TEMPLATES/config-template.yaml.\`"
        echo "API Token 获取方式：\`https://gerrit.zhenguanyu.com\` -> 点击右上角用户名 -> 选择 HTTP Credentials -> 点击【 GENERATED NEW PASSWORD 】按钮"
        exit 1
    fi
    echo $token
}