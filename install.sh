#!/bin/zsh

set -e

if command -v nox >/dev/null 2>&1; then
    echo "[nox] nox is already installed."
    exit 1
fi

echo "[nox] ========================================"
echo "[nox] nox may trigger \`brew update\`, please waiting for a while if it triggered."

export NOX_ROOT=`pwd`
export NOX_NAME="nox"
export NOX_COMMON=$NOX_ROOT/common
export NOX_CONFIG=$NOX_ROOT/config
export NOX_SCRIPTS=$NOX_ROOT/scripts
export NOX_TEMPLATES=$NOX_ROOT/templates
source $NOX_COMMON/logo.sh
source $NOX_COMMON/utils.sh
source $NOX_COMMON/dependency.sh

# installing dependencies
echo "[nox] ========================================"
echo "[nox] start register nox dependencies..."
register_nox_dependency

# installing nox
echo "[nox] ========================================"
echo "[nox] start installing \`nox\`..."
_TARGET="/usr/local/bin"
_TARGET_NOX="${_TARGET}/${NOX_NAME}"
if [[ -w $_TARGET_NOX ]]; then
    ln -s $NOX_ROOT/nox.sh $_TARGET_NOX
else
    sudo ln -s $NOX_ROOT/nox.sh $_TARGET_NOX
fi

# initialize .noxrc
echo "[nox] ========================================"
echo "[nox] start initializing \`.noxrc\`..."
echo "" > .noxrc
echo "export NOX_ROOT=\"$NOX_ROOT\"" >> .noxrc
echo "export NOX_NAME=\"$NOX_NAME\"" >> .noxrc
echo "export NOX_COMMON=\"$NOX_COMMON\"" >> .noxrc
echo "export NOX_CONFIG=\"$NOX_CONFIG\"" >> .noxrc
echo "export NOX_SCRIPTS=\"$NOX_SCRIPTS\"" >> .noxrc
echo "export NOX_TEMPLATES=\"$NOX_TEMPLATES\"" >> .noxrc
echo "fpath=($NOX_ROOT/fpath \$fpath)" >> .noxrc
echo "autoload -U compinit" >> .noxrc
echo "compinit" >> .noxrc
echo "unfunction _nox" >> .noxrc
echo "autoload -U _nox" >> .noxrc
echo "source $NOX_ROOT/.noxrc" >> ~/.zshrc

# building completions
echo "[nox] ========================================"
echo "[nox] start building completions for \`nox\`..."
nox system build -s

# initialize config.yaml
echo "[nox] ========================================"
echo "[nox] start initializing \`$NOX_CONFIG/config.yaml\`..."
if [[ -e $NOX_CONFIG/config.yaml ]]; then
    # backup previous config.yaml
    timestamp=$(date "+%Y%m%d-%H%M%S")
    backupfile=".config-backup-$timestamp.yaml"
    cat $NOX_CONFIG/config.yaml > $NOX_CONFIG/$backupfile
fi
cp $NOX_TEMPLATES/config-template.yaml $NOX_CONFIG/config.yaml
ldap=`git config user.email | sed "s/@.*//g"`
gsed -i "s/^#ldap: [a-z]*/ldap: $ldap/" $NOX_CONFIG/config.yaml

# Install success
success ""
success ""
print_colorful_logo
success "                                                                   ... is now installed!"
success ""
success "        Before you use nox! Please execute \"source ~/.zshrc\" to make sure that the nox configurations are ready!"
success ""
success "        • The project is technically supported by @baochuquan"
success "        • View nox on github: https://github.com/baochuquan/nox"
success "        • View wiki on github: https://github.com/baochuquan/nox-wiki"
success "        • Follow author: http://chuquan.me"
success "        • If you have any problem or suggestion, please contact me. Email: baochuquan@163.com"
success ""