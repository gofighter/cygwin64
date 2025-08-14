function printCommonEnv() {
    echo ----- [2] .bashrc                #
    echo $0                               # /usr/bin/bash
    echo $-                               # himBH
    if [[ "$-" != *i* ]]; then            #
        echo ===================================== [No] InteractiveShell
        return                            #
    else                                  #
        echo ===================================== [Yes] InteractiveShell
    fi                                    #
    shopt login_shell                     # [[ login_shell ]] && login_shell on || login_shell off
}

function setTestEnv() {
    if env | egrep "HOST=vwp" ; then
        testEnv=VWP
    elif env | egrep 12.36.212.244 ; then
        testEnv=Linux244
    elif env | egrep mintty ; then
        testEnv=WindowMintty
    else
        testEnv=LinuxEtc
    fi
    [[ $log_level == "DEBUG" ]] && echo -e "testEnv: $testEnv\n"
}

function sourceBashrc() {
    if [[ $testEnv == "Linux244" ]] ; then
        source ~/.bashrc_244
    fi
}

function setLanguage() {
    export LANG=ko_KR.UTF-8
}

function set_PATH() {
    PATH_ARG=$* && echo $PATH | grep --quiet $PATH_ARG || export PATH=$PATH_ARG${PATH:+:${PATH}}
}

function set_LD_LIBRARY_PATH() {
    LD_LIB=$* && echo $LD_LIBRARY_PATH | grep --quiet $LD_LIB || export LD_LIBRARY_PATH=$LD_LIB${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
}

function setPath() {
    set_PATH ~/.local/bin
}

function setPathForNoLinuxPC() {
    set_PATH /usr/local/bin:/usr/bin

    ###### Git Bash
    # $uname
    # MINGW64_NT-10.0-26100
    ###### Cygwin_Mintty.bat
    # $uname
    # CYGWIN_NT-10.0-26100
    ###### Cygwin.bat
    # $uname
    # MSYS_NT-10.0-26100
}

function setToolPath_244() {
    gitUserName=$(git config --global user.name)

    if [[ $gitUserName == "jaeho_s.lee" ]] ; then
        set_PATH ~/.local/bin/gcc10.3.0
    else
        set_PATH ~/.local/bin/gcc5.5.0
    fi
}

function commonHelperFunction() {
    if [[ $HOME == "/home/jaeho_s.lee" ]] ; then
        HOME=/cygdrive/c/Users/jaeho_s.lee
        source ~/.local/bin/runBash/01_CB.sh
        HOME=/home/jaeho_s.lee
    else
        source ~/.local/bin/runBash/01_CB.sh
    fi
}

function setUserBitMask() {
    umask 077
    [[ $log_level == "DEBUG" ]] && cmd="umask" && CommandRunner0
}

function setToolPath() {
    if [[ $testEnv == "Linux244" ]] ; then
        setToolPath_244
    fi

    setCXX
}

function setCXX() {
    if [[ $testEnv == "VWP" ]] ; then
        setCXX_VWP
    else
        export CC=$(which gcc)
        export CXX=$(which g++)
    fi
}

function setCXX_VWP() {
    while read -r opt arg; do
        [[ $log_level == "DEBUG" ]] && LogInfoLev0 $opt : $arg
        case "${opt}" in
            PATH) set_PATH $arg ;;
            LD_LIB) set_LD_LIBRARY_PATH $arg ;;
            CC) export CC=$arg ;;
            CXX) export CXX=$arg ;;
        esac
    done <<< $(cat ~/PATH_VWP.txt)
}

function setAlias() {
    alias rm='rm -i'
    # alias cp='cp -i'                # cp Interactive 로 인해서 잘 안되면 /bin/cp 사용
    alias mv='mv -i'
    alias less='less -r'              # raw control characters
    alias grep='grep --color'
    alias egrep='grep --extended-regexp --color=auto'
    alias fgrep='grep --fixed-strings --color=auto'
    alias ls='ls --color'
    alias sort='LC_COLLATE=en_US.UTF-8 sort'
}

function sourceAliasFunc() {
    if [[ $HOME == "/home/jaeho_s.lee" ]] ; then
        HOME=/cygdrive/c/Users/jaeho_s.lee
        source ~/.alias
        HOME=/home/jaeho_s.lee
    else
        source ~/.alias
    fi

    if [[ $testEnv == "VWP" ]] ; then
        source ~/.alias_VWP
    elif [[ $testEnv == "Linux244" ]] ; then
        source ~/.alias_office
    fi
}

function printToolPath() {
    ###################################### sudo update-alternatives --config cmake
    # ~/.local/bin/cmake ## 3.22.1's link file

    cmd="which g++" && CommandRunner0
    cmd="which python" && CommandRunner0
    cmd="which bash" && CommandRunner0
    cmd="which cmake" && CommandRunner0
}

function printToolVersion() {
    cmd="g++ --version" && CommandRunner0
    cmd="python --version" && CommandRunner0
    cmd="bash --version" && CommandRunner0
    cmd="cmake --version" && CommandRunner0
    LogInfoRef_multiLine CC
    LogInfoRef_multiLine CXX
    LogInfoRef_multiLine SHELL
    LogInfoRef_multiLine PATH
    LogInfoRef_multiLine LD_LIBRARY_PATH
}

function commandPrompt() {
    if [[ $testEnv == "WindowMintty" ]] ; then
        setPromptColor_MINGW
    elif [[ $testEnv == "VWP" ]] ; then
        setPromptColorGreen
    else
        setPromptColorBlue
    fi
    [[ $command_prompt == "green" ]] && setPromptColorGreen

    getBranchName

    #\u     the username of the current user
    #\w     the fullPath of the current working directory
    #\W     the basename of the current working directory

    if [[ $testEnv == "WindowMintty" ]] ; then
        PS1='\[\033]0;$MSYSTEM : $branchName \w \007\]' # set window title
        PS1="$PS1"'\[\e[${attr};${clfg};${clbg}m\]'     # Color for user@workingDir
        PS1="$PS1"'[\u@\W]'                             # user@workingDir(basenameOfPath)
    else
        PS1='\[\e[${attr};${clfg};${clbg}m\]'           # Color for user@workingDir
        PS1="$PS1"'[\u@\w]'                             # user@workingDir(fullPath)
    fi
    PS1="$PS1"'\[\e[${attr};${clfg};${clbg_gb}m\]'  # Color for bash function
    PS1="$PS1"'$branchName'                         # bash function
    PS1="$PS1"'\$\[\e[0;0;0m\]'                     # reset format
}

function setPromptColor_MINGW() {
    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    ## Formatting
        # for attr in 0 1 2 4 5 7 ;
        # 1 Bold/Bright
        # 2 Dim
        # 4 Underlined
        # 5 Blink
        # 7 Reverse (invert the foreground and background colors)
        # 8 Hidden (useful for passwords)

    ## Foreground (text)
        # for clfg in {30..37} {90..97} 39(Default) ;
        # 39 Default foreground color (white 유사)
        # 30 Black
        # 31 Red
        # 32 Green
        # 33 Yellow
        # 34 Blue
        # 35 Magenta
        # 36 Cyan
        # 37 Light gray
        # 90 Dark gray
        # 91 Light red
        # 92 Light green
        # 93 Light yellow
        # 94 Light blue
        # 95 Light magenta
        # 96 Light cyan
        # 97 White

    ## Background
        # for clbg in {40..47} {100..107} 49(Default) ;
        # 49  Default background color (Black 유사)
        # 40  Black
        # 41  Red
        # 42  Green
        # 43  Yellow
        # 44  Blue
        # 45  Magenta
        # 46  Cyan
        # 47  Light gray
        # 100 Dark gray
        # 101 Light red
        # 102 Light green
        # 103 Light yellow
        # 104 Light blue
        # 105 Light magenta
        # 106 Light cyan
        # 107 White

    attr=5      # Blink (MinGW)
    clfg=30     # Black
    clbg=102    # Light green
    clbg_gb=106 # Light cyan
}

function setPromptColorBlue() {
    [[ $testEnv != "VWP" ]] && attr=1   # Bold/Bright # VS2022 terminal
    clfg=34                             # Blue
    clbg=34                             # Blue
    clbg_gb=34                          # Blue
}

function setPromptColorGreen() {
    [[ $testEnv != "VWP" ]] && attr=7   # Reverse (Linux PC)
    clfg=30                             # Black
    clbg=102                            # Light green
    clbg_gb=106                         # Light cyan
}

function getBranchName() {
    branchName_detach=`git branch 2> /dev/null | grep -oP --color "\* [(]\K.+(?=[)])"`
    if [[ $? == 0 ]]; then
        branchName=$branchName_detach
    else
        branchName_noDetach=`git branch 2> /dev/null | awk '/*/ {print $2}'`
        branchName=$branchName_noDetach
    fi

    [[ $branchName != "" ]] && branchName="(${branchName})"
    [[ $log_level == "DEBUG" ]] && LogInfoRef_multiLine branchName
}

function printArguments() {
    LogInfoRef_multiLine command_prompt
    LogInfoRef_multiLine log_level
}

##################################

command_prompt=
log_level=INFO

args=("${@//-/}") # 배열 확장

for i in "${!args[@]}" ; do
    next=$((i+1))
    arg=${args[$i]}
    case "${arg}" in
        c|command_prompt) command_prompt=${args[$next]} ;;
        l|log_level) log_level=${args[$next]} ;;
    esac
done

commonHelperFunction
[[ $log_level == "DEBUG" ]] && printArguments
[[ $log_level == "DEBUG" ]] && printCommonEnv
setTestEnv
sourceBashrc
setLanguage
setPath
[[ ! $(uname) == "Linux" ]] && setPathForNoLinuxPC
setUserBitMask
setToolPath
setAlias
sourceAliasFunc
[[ $log_level == "DEBUG" ]] && printToolPath
[[ $log_level == "DEBUG" ]] && printToolVersion
commandPrompt