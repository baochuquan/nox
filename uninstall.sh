#!/bin/sh

if ! command -v nox >/dev/null 2>&1; then
  echo "[nox] nox is not installed."
  exit 1
fi

read -r -p "[nox] are you sure you want to uninstall nox? [y/N]" confirmation
if [ "$confirmation" != y  ] && [ "$confirmation" != Y ]; then
    echo "[nox] uninstall cancelled"
    exit
fi

if [[ -z $NOX_NAME ]]; then
    echo "[nox] nox environment variables is not initialized. Please check if you have executed \`source ~/.zshrc\`"
    exit 1
fi
source $NOX_COMMON/dependency.sh

unregister_nox_dependency

_TARGET="/usr/local/bin"
_TARGET_NOX="${_TARGET}/${NOX_NAME}"
rm $_TARGET_NOX
rm .noxrc
sed -i '' '/.noxrc/d' ~/.zshrc

source $NOX_COMMON/logo.sh
source $NOX_COMMON/utils.sh

# Uninstall success
success ""
success ""
print_logo
success "                                                                   ... is now uninstall!"
success ""
success "        Thanks for trying out nox."
success "        Byeeeeeee!"
success ""
success ""
