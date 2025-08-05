function setCommonEnv() {
    echo ----- [1] .bash_profile
}

function sourceBashRc() {
    if [ -f "${HOME}/.bashrc" ] ; then
        source "${HOME}/.bashrc"
    fi
}

#################
# setCommonEnv
sourceBashRc
