#!/bin/bash

scriptFile=$0
arg_number=$#

####

set -e  # set exit flag
set +e  # unset exit flag

function set_eXecution_dEbug() {
    return 1
}

function set_eXecution_dEbug_Runner() {
    # set -xe 사용 Case : git_submodule 참고
    ## 1. | (redirection 은 CommandRunner 방식으로 실행하면 message 전달이 fail 되므로 set -xe 활용해서 Debug Feature 사용하기)
    ## 2. '' 를 넘겨야 하는 경우
    set -xe
    set_eXecution_dEbug # set_eXecution_dEbug 함수에서는
                        #1. 실행 전에 Print Command
                        #2. Run Command
                        #3. Fail Case 라면 Direct Termination
    set +xe
}

function set_eXecution_dEbug_Runner_Grep_Fail() {
    # grep 이 항상 성공하지 않는다면 set -e 에 의해서 항상 terminate 되므로 Grep 인 경우는 "|| : " 과정 추가하자.
    set -xe
    git log --graph --decorate --oneline -1 --submodule=log | grep -E --color 'Submodule' # Fail
    set +xe
}

function set_eXecution_dEbug_Runner_Grep_Success() {
    # grep 이 항상 성공하지 않는다면 set -e 에 의해서 항상 terminate 되므로 Grep 인 경우는 set -e 사용하지 말자.
    set -xe
    git log --graph --decorate --oneline -1 --submodule=log | grep -E --color 'Submodule' || :
    set +xe
}

# /////////////////////////////////////////////////////////////////////////////// [Start] Common Setting
# cmd="commad" 방식으로 기술 필수 # [bash 주의 사항]

function PrintFunction() {
    arg_info="$@"
    echo -e "\n--------------------- [$arg_info]\n"
}

function LogInfoFt_Main() {
    arg_info="$@"
    echo -e "\n#####################################=========##################################### $arg_info \n"
}

function LogInfoFt() {
    arg_info="$@"
    echo -e "\n##################################### $arg_info \n"
}

function LogInfoFtWON() {
    arg_info="$@"
    echo "##################################### $arg_info"
}

function LogErrorControl() {
    errorlevel=$1
    if [[ $errorlevel -ne 0 ]]; then
        shift
        arg_info="$@"
        LogInfo [Error] [errorlevel : $errorlevel] $arg_info && exit 1
    else
        LogInfo [Success] $cmd
    fi
}

##################################

function LogError() {
    errorlevel=$1
    if [[ $errorlevel -ne 0 ]]; then
        shift
        arg_info="$@"
        LogInfo [Error] [errorlevel : $errorlevel] $arg_info && exit 1
    fi
}

function LogInfo() {
    arg_info="$@"
    echo -e "\n===================================== $arg_info\n"
}

function LogInfoLev0() {
    arg_info="$@"
    echo ===================================== $arg_info
}

function LogInfoSub() {
    arg_info="$@"
    echo -e "\n------------------------------------- $arg_info\n"
}

function LogInfoRef() {
    arg_info="$@"
    [[ $arg_info == "" ]] && return 0
    LogInfoLev0 $arg_info : "${!arg_info}"
}

function LogInfoRef_multiLine() {
    arg_info="$@"
    [[ $arg_info == "" ]] && return 0
    LogInfoLev0 $arg_info && echo -e "${!arg_info}"
}

# $ var="a b c"; LogInfoRef var
# ------------------------------------- var : a b c

# var="a b c"; LogInfoRef_multiLine var
# ------------------------------------- var
# a b c

# $ var="a\nb\nc"; LogInfoRef var
# ------------------------------------- var : a
# b
# c

# var="a\nb\nc"; LogInfoRef_multiLine var
# ------------------------------------- var
# a
# b
# c

##################################

function LogInfo_newLineOnly_Left() {
    arg_info="$@"
    echo -e "\n------------------------------------- $arg_info"
}

function LogInfo_newLineOnly_Right() {
    arg_info="$@"
    echo -e "------------------------------------- $arg_info\n"
}

function LogInfoSub_newLineOnly_Left() {
    arg_info="$@"
    echo -e "\n------------------------------------- $arg_info"
}

function LogInfoSub_newLineOnly_Right() {
    arg_info="$@"
    echo -e "------------------------------------- $arg_info\n"
}

function LogCmd() {
    arg_info="$@"
    echo -e "\n $arg_info\n"
}

function LogInfoLev0Sub() {
    arg_info="$@"
    echo ------------------------------------- $arg_info
}

function LogInfoLev0Ref() {
    arg_info="$@"
    [[ $arg_info == "" ]] && return 0
    LogInfoLev0 $arg_info : "${!arg_info}"
}

function CommandRunnerFunction() {
    LogInfo [Start] $FunctionCmd
    $FunctionCmd
    LogError $? $FunctionCmd
    LogInfo [End] $FunctionCmd
}

function CommandRunner() {
    LogInfo [Start][$(pwd)] $cmd
    eval $(echo ${cmd} | xargs --delimiter=" ") # "[1 2 3]" 에서 "" 보존 하면서 실행
    LogError $? $cmd
    LogInfo [End][$(pwd)] $cmd
}

function CommandRunner0() {
    LogInfoLev0 $cmd
    $cmd
}

function CommandTimeRunner() {
    LogInfo [Start][$(pwd)] $cmd
    time($cmd)
    LogError $? $cmd
    LogInfo [End][$(pwd)] $cmd
}

function CommandRunnerBash() {
    LogInfo [Start][$(pwd)] $cmd
    bash -c "$cmd"
    LogError $? $cmd
    LogInfo [End][$(pwd)] $cmd
}

function CommandRunnerBashNE() {
    LogInfo [Start][$(pwd)] $cmd
    bash -c "$cmd"
    LogInfo [End][$(pwd)] $cmd
}

function CommandRunnerBashRunner() {
    # bash -c "" 방식으로 처리하면 안정적으로 처리되는 경우 2가지
    #1. cmd 에 '' 포함된 경우
    #2. cmd 에 | 포함된 경우
    cmd="git for-each-ref --format='%(refname:strip=-1)' refs/tags"
    CommandRunnerBash
    cmd="git ls-tree HEAD -r . --abbrev=7 | grep --color 160000 || :"
    CommandRunnerBash
}

function CommandRunnerWON() {
    LogInfoLev0 [Start][$(pwd)] $cmd
    $cmd
    LogError $? $cmd
    LogInfoLev0 [End][$(pwd)] $cmd
}

function CommandRunnerSE() {
    LogInfo [Start][$(pwd)] $cmd
    $cmd
    LogErrorControl $? $cmd
    LogInfo [End][$(pwd)] $cmd
}

function CommandRunnerGrep() {
    LogInfo [Start] $cmd
    $cmd | grep $grepKeyword
    LogError $? $cmd
    LogInfo [End] $cmd
}

function CommandRunnerNE() {
    LogInfo [Start][$(pwd)] $cmd
    $cmd
    LogInfo [End][$(pwd)] $cmd
}

function CWD() {
    arg_info=$1

    if [[ $OSTYPE == "linux-gnu" || $OSTYPE == "linux" ]]; then
        currentFullPath=$(realpath .)
    else # msys
        currentFullPath=$(cygpath --windows $(realpath .))
    fi

    if [[ "$arg_info" -eq "WO_NL" ]]; then LogInfo [CWD] : $currentFullPath
    else LogInfoWithoutEchoNewLine [CWD] : $currentFullPath
    fi
}

function PushDirectory() {
    arg_Dir=$1
    pushd $(pwd) > /dev/null
    cd $arg_Dir
    LogInfoLev0 [CWD] $(pwd)
}

function PopDirectory() {
    popd > /dev/null
    LogInfoLev0 [CWD] $(pwd)
}

function PushDrive() {
    arg_Dir=$1
    pushd $arg_Dir > /dev/null
}

function RunScript() {
    run_path_arg=$1
    run_file_arg=$2
    shift 2
    run_arg="$@"
    LogInfoLev0Ref run_path_arg
    LogInfoLev0Ref run_file_arg
    echo
    PushDirectory $run_path_arg
    bash $run_file_arg $run_arg
    PopDirectory
}

function SetCmdTitle() {
    fileBaseName=$(basename $0)
    LogInfo $runArg [$fileBaseName] $(pwd)
}

function LogMainScriptStart() {
    SetCmdTitle
    echo -e "\n################################################ [Main Start][runArg] $runArg \n"
}

function LogMainScriptEnd() {
    echo -e "\n################################################ [Main End][runArg] $runArg \n"
}

function ConvertTabTo4Space() {
    convert_file_arg=$1
    cmd="perl -pi -e 's/\t/    /' $convert_file_arg"
    CommandRunner
}

function ConvertCrlf2Lf() {
    convert_file_arg=$1
    cmd="dos2unix $convert_file_arg"
    CommandRunner
}

function ConvertLf2CrLf() {
    convert_file_arg=$1
    cmd="perl -pi -e 's/\n/\r\n/' $convert_file_arg"
    CommandRunner
}

function ConvertAllCrlf() {
    convert_file_arg=$1
    ConvertCrlf2Lf $convert_file_arg
    ConvertLf2CrLf $convert_file_arg
}

function DetectFinalNewLine() {
    convert_file_arg=$1
    convert_file_baseName=$(basename $1)
    for var in $(tail --bytes=1 $runArg | wc --lines) ; do finalNewLineNo=$var ; done
    LogInfo [finalNewLineNo  $finalNewLineNo ] [$convert_file_baseName]
}

function InsertFinalNewLine() {
    convert_file_arg=$1
    convert_file_baseName=$(basename $1)
    for var in $(tail --bytes=1 $runArg | wc --lines) ; do finalNewLineNo=$var ; done
    LogInfo [finalNewLineNo  $finalNewLineNo ] [$convert_file_baseName]
    [[ "$finalNewLineNo" -eq "0" ]] && echo>> $runArg
}

function CheckCharSet() {
    convert_file_arg=$1
    cmd="file -b $convert_file_arg"
    CommandRunner
}

function SetLocalBranchName() {
    read -p "Please enter setLocalBranchMode (Enter develop/ 1develop1/ Otherwise, Enter branch) " setLocalBranchMode && echo

    if   [[ "$setLocalBranchMode" -eq ""  ]] ; then setLocalBranchName=develop
    elif [[ "$setLocalBranchMode" -eq "1" ]] ; then setLocalBranchName=develop1
    else                                            setLocalBranchName=setLocalBranchMode
    fi
    LogInfo [Local] setLocalBranchName  $setLocalBranchName
}

function SetLocalBranchHeadPosition() {
    for var in $(git rev-parse --short HEAD); do curHeadSha=$var ; done
    cmd="git checkout --force -B $setLocalBranchName $curHeadSha"
    CommandRunner
    cmd="git branch --verbose --set-upstream-to=origin/develop"
    CommandRunner
}

function GetDirname() {
    arg_info=$1
    arg_dirname=$(dirname $arg_info)
}

function GetBasename() {
    arg_info=$1
    arg_basename=$(basename $arg_info)
}

function GetPwdDirname() {
    pwd_dirname=$(dirname $(pwd))
}

function GetPwdBasename() {
    pwd_basename=$(basename $(pwd))
}

function gitLogGraph() {
    cmd="git log --graph --oneline -10"
    CommandRunner
}

function GitStatus() {
    cmd="git status ."
    CommandRunner
}

function GetHeadShortSha() {
    for var in $(git rev-parse --short HEAD); do curHeadSha=$var ;done && echo $curHeadSha
}

function makeFile() {
    arg_file=$1
    mkdir -p "$(dirname "$arg_file")" && touch "$arg_file"
}

function stringSplitByToken() {
    string="ab:cd:ef"
    IFS=":" read -r -a array <<< "$string"
    echo ------------- All : ${array[@]}

    for var in ${array[@]}; do
        echo $var
    done
}

function listFile() {
    while IFS= read -r file; do
        LogInfoLev0 $file
    done <<< $(cat input.txt)
}

function addFile() {
    while IFS= read -r file; do
        LogInfoLev0 $file
        makeFile $file
    done <<< $(cat input.txt)
}

function removeFile() {
    while IFS= read -r file; do
        LogInfoLev0 $file
        rm -f $file
    done <<< $(cat input.txt)
    git clean -xdf --quiet -- .
}

function FUNCTION_CALL() {
    functionName="$@"
    FunctionCmd=$functionName
    CommandRunnerFunction
}

function SetGitEnvFile() {
    gitDirSubModules=.git/modules
    gitConfigSystem=/etc/gitconfig
    gitConfigGlobal=~/.gitconfig
    gitConfigLocal=.git/config
    gitConfigModules=.gitmodules
}

declare -A subModulePathList
declare -A GetSubModuleUrlList

function GetSubModulePathList() {
    subModuleIndex=0
    for var in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }') ; do
        subModuleIndex=$((subModuleIndex+1))
        subModulePathList[$subModuleIndex]=$var
    done

    for var in $(seq 1 $subModuleIndex) ; do
        LogInfoLev0 [$var] ${subModulePathList[$var]}
    done && echo
}

function PrintSubModulePathList() {
    for var in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }') ; do
        echo $var
    done
}

function RunGetSubModuleUrlList() {
    cmd=GetSubModuleUrlList
    CommandRunner
}

function GetSubModuleUrlList() {
    subModuleUrlIndex=0
    for var in $(git config --file .gitmodules --get-regexp url | awk '{ print $2 }') ; do
        subModuleUrlIndex=$((subModuleUrlIndex+1))
        subModuleUrlList[$subModuleUrlIndex]=$var
    done

    for var in $(seq 1 $subModuleUrlIndex) ; do
        LogInfoLev0 [$var] ${subModuleUrlList[$var]}
    done && echo
}

function PrintSubModuleUrlList() {
    for var in $(git config --file .gitmodules --get-regexp url | awk '{ print $2 }') ; do
        echo $var
    done
}

function PrintAllSubmodulePath() {
    for var in $(seq 1 $subModuleIndex) ; do
        LogInfo ${subModulePathList[$var]}
    done && echo
}

function PrintAllSubmoduleUrl() {
    for var in $(seq 1 $subModuleUrlIndex) ; do
        LogInfo ${subModuleUrlList[$var]}
    done && echo
}

function CopyAllSubmodulePath() {
    base_pre_push=$1
    for var in $(seq 1 $subModuleIndex) ; do
        LogInfo ${subModulePathList[$var]}
        submodule_hook_pre_push=$gitDirSubModules/${subModulePathList[$var]}/hooks/pre-push
        LogInfoLev0 $submodule_hook_pre_push
        cmd="cp -f $base_pre_push $submodule_hook_pre_push"
        CommandRunnerWON
        cmd="ls $submodule_hook_pre_push"
        CommandRunnerWON
    done && echo
}

declare -A targetDirectory

function SelectTargetProject() {
    id=0
    for key in $(find . -maxdepth 1 -type d); do
        targetDirectory[$id]=$key
        echo $id : $key
        ((id++))
    done

    echo && read -p "--------------------- Please enter {id}. " reply && echo
    PushDirectory ${targetDirectory[$reply]}
    PopDirectory
}

function Inc() {
    arg_info="$@"
    out=$(($arg_info + 1))

    # var=$((var+1))
    # ((var=var+1))
    # ((var+=1))
    # ((var++))
}

function Dec() {
    arg_info="$@"
    out=$(($arg_info - 1))
}

function CheckGitRepo() {
    git rev-parse --is-inside-work-tree > /dev/null 2>&1
    [[ $? != 0 ]] && LogInfo || gitRepo=true
}

function RemoveLeadingTrailingSpace() {
    arg_info="$@"
    arg_out=$(echo $arg_info | xargs)
}

function RemoveLeadingTrailingSpace_runner() {
    cmd="   Ling   "
    RemoveLeadingTrailingSpace $cmd
    echo $arg_out
}

function CompareLeadingTrailingSpace() {
    arg1="$1"
    arg2="$2"
    [[ $(echo $arg1 | xargs) -eq $arg2 ]] && echo same || echo diff
}

function CompareLeadingTrailingSpace_runner() {
    cmd1="   Ling   "
    cmd2="Ling"
    CompareLeadingTrailingSpace $cmd1 $cmd2
}

function SuppressErrorMessage() {
    # /dev/null 은 임의의 다른 File로 지정해도 상관없음
    cmd_arg="$@"
    ${cmd_arg} 2> /dev/null
    # git branch 2> /dev/null
    #### 2> 와 같이 항상 2 와 > 는 붙여서 사용해야 동작
}

function SuppressSuccessMessage() {
    cmd_arg="$@"
    ${cmd_arg} > /dev/null
}

function SuppressSuccessAndErrorMessage() {
    cmd_arg="$@"
    ${cmd_arg} > /dev/null 2>&1
}

function SuppressSuccessAndErrorMessageCase2() {
    cmd_arg="$@"
    ${cmd_arg} > /dev/null 2> /dev/null
}

function SuppressSuccessAndErrorMessageCase3() {
    cmd_arg="$@"
    ${cmd_arg} 2> /dev/null > /dev/null
}

function SuppressSuccessAndErrorMessageCase4() {
    cmd_arg="$@"
    ${cmd_arg} 2> /dev/null 1>&1
}

function NoSuppressErrorMessage() {
    cmd_arg="$@"
    ${cmd_arg}
}

function GetCurrentGitBranch() {
    for var in $(git branch --show-current 2> /dev/null) ; do branchName=$var ; done
}

function PrintCurrentGitBranch() {
    GetCurrentGitBranch
    echo $branchName
}

function git_log_HEAD_default() {
    option="$@"
    cmd="git log --graph --format=format:'%C(yellow)%<|(20)%h%Creset%C(red)%<|(35,trunc)%ar%Creset%C(bold blue)%d%Creset%<(70,trunc) %s' $option"
    CommandRunnerBash
    LogInfo
}

function SelectRunArg() {
    [[ "$runArg" == "" ]] && read -p "Please enter runArg :" runArg && echo
}

function RunPause() {
    [[ "$autoRun" == "" ]] && read -p "[LF] Please enter to run next step, [1] enter to exit : " autoRun && echo
    [[ "$autoRun" == "1" ]] && exit 1
}

function Check_CopyRight() {
    # gdt_copy HEAD~3...HEAD
    # BaseCommit   HEAD~3
    # TargetCommit HEAD

    # gdt_rev 1{.2.3.}4

    multiThread=1 && range_arg="$@"
    BaseCommit=$(echo $range_arg | cut --fields=1 --delimiter='.')
    TargetCommit=$(echo $range_arg | cut --fields=4 --delimiter='.')
    TargetCommit=$TargetCommit:
    GitDifftool_CopyRight
}

function GitDifftool_CopyRight() {
    cmd="git diff --name-status $range_arg | sort" && CommandRunnerBash
    cmd="git diff --raw --stat $range_arg | sort" && CommandRunnerBash
    [[ $viewLog -ne 0 ]] && git_log_HEAD_default $range_arg
    cmd="git diff --name-status $range_arg | sort | grep --color '^[AR]'"
    CommandRunnerBashNE
    RunPause
    curYear=$(date +%Y)
    git diff --name-status $range_arg | grep --color "^[A]" | awk '{print $2}' | while read filename; do
        git diff $range_arg -- "$filename" | grep --color "^+" | grep --color "Copyright (C) $curYear"
        # git log --patch --oneline $range_arg -- "$filename" | grep --color --count "Copyright (C) $curYear"
        [[ $? -ne 0 ]] && LogInfo [Error][A $filename] Please set Copyright Year as $curYear. && exit 1
    done

    git diff --name-status $range_arg | grep --color "^[R]" | awk '{print $2, $3}' | while read filename1 filename2; do
        git diff $BaseCommit:$filename1 $TargetCommit$filename2 | grep --color "^+" | grep --color "Copyright (C) $curYear"
        [[ $? -ne 0 ]] && LogInfo [Error][R $filename2] Please set Copyright Year as $curYear. && exit 1
    done
}

function GitDifftool_Runner() {
    cmd="git diff --name-status $range_arg | sort" && CommandRunnerBash
    cmd="git diff --raw --stat $range_arg | sort" && CommandRunnerBash
    [[ $viewLog -ne 0 ]] && git_log_HEAD_default $range_arg
    cmd="git diff --name-status $range_arg | sort | grep --color '^[AMR]'"
    CommandRunnerBashNE
    RunPause
    git diff --name-status $range_arg | grep --color "^[AM]" | awk '{print $2}' | while read filename; do
        if [[ "$multiThread" == "1" ]] ; then
            git difftool $range_arg --no-prompt -- "$filename" &
        else
            git difftool $range_arg --no-prompt -- "$filename"
        fi
    done

    ### git mv 처리되면 항상 git rm & git add 처리되므로 항상 git index(stage) 상태가 된다.
    ### 따라서 $range_arg 없이 HEAD:{prevFile} {newFile} 비교가 맞다.
    ### rename 처럼 file 2개 비교하는 경우에는 -- 사용하지 말아야 함
    git diff --name-status $range_arg | grep --color "^[R]" | awk '{print $2, $3}' | while read filename1 filename2; do
        if [[ "$multiThread" == "1" ]] ; then
            git difftool --no-prompt $BaseCommit:$filename1 $TargetCommit$filename2 &
        else
            git difftool --no-prompt $BaseCommit:$filename1 $TargetCommit$filename2
        fi
    done

    # git difftool --no-prompt -- HEAD:test.sh test_re.sh
    #### R073    test.sh test_re.sh
    # git difftool --no-prompt -- HEAD~1:test.sh test_re.sh
    # git difftool --no-prompt -- HEAD~2:test.sh test_re.sh
    # git difftool --no-prompt -- HEAD~3:test.sh test_re.sh
}

function get_mergeBase_parent1_parent2() {
    mergeBase_parent1_parent2=$(git merge-base "HEAD^1" "HEAD^2" | cut --characters=-7)
}

function git_log_merge_all() {
    get_mergeBase_parent1_parent2
    range_arg="HEAD^1 HEAD^2 ^$mergeBase_parent1_parent2"
    git log --graph --format=format:'%C(yellow)%<|(20)%h%Creset%C(red)%<|(35,trunc)%ar%Creset%C(bold blue)%d%Creset%<(70,trunc) %s' $range_arg
}

function GitDifftool_stage_commit() {
    targetCommitBranch="$@"
    range_arg="--stage $targetCommitBranch"
    BaseCommit=HEAD
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_stage_mergeBaseCommit() {
    targetCommitBranch="$@"
    range_arg="--stage $(git merge-base $targetCommitBranch)"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_stage_mergeBaseCommit2() {
    targetCommitBranch="$@"
    range_arg="--stage --merge-base $targetCommitBranch"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_workingTree_commit() {
    targetCommitBranch="$@"
    range_arg="$targetCommitBranch"
    BaseCommit=$range_arg
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_workingTree_mergeBaseCommit() {
    targetCommitBranch="$@"
    range_arg="$(git merge-base $targetCommitBranch)"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_workingTree_mergeBaseCommit2() {
    targetCommitBranch="$@"
    range_arg="--merge-base $targetCommitBranch"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_base_merge1() {
    LogInfo 'git diff --merge-base A B is equivalent to git diff $(git merge-base A B) B'

    range_arg="--merge-base HEAD^2 HEAD^1"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_base_merge2() {
    LogInfo 'git diff --merge-base A B is equivalent to git diff $(git merge-base A B) B'

    range_arg="--merge-base HEAD^1 HEAD^2"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_merge1_merge2() {
    LogInfo 'git diff from merge1 to merge2'

    range_arg="HEAD^1 HEAD^2"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_merge2_merge1() {
    LogInfo 'git diff from merge2 to merge1'

    range_arg="HEAD^2 HEAD^1"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_mergeBase12_commit2() {
    LogInfo 'git diff --merge-base A B is equivalent to git diff $(git merge-base A B) B'
    targetCommitBranch1="$1"
    targetCommitBranch2="$2"
    range_arg="--merge-base $targetCommitBranch1 $targetCommitBranch2"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_commit1_commit2() {
    LogInfo 'from commit1 to commit2'
    targetCommitBranch1="$1"
    targetCommitBranch2="$2"
    range_arg="$targetCommitBranch1 $targetCommitBranch2"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_mergeCommit1_parentsCommit() {
    LogInfo 'from all parentsCommits to mergeCommit1'          # targetCommitBranch1 : merged commit 만 가능
    targetCommitBranch1="$1"                                   #
    range_arg="$targetCommitBranch1 ${targetCommitBranch1}^@"  #
    multiThread=1 && GitDifftool_Runner                        #
}

function GitDifftool_mergeCommit1_parentsCommit_case2() {
    LogInfo 'from all parentsCommits to mergeCommit1'          # targetCommitBranch1 : merged commit 만 가능
    targetCommitBranch1="$1"                                   #
    range_arg="${targetCommitBranch1}^!"                       #
    multiThread=1 && GitDifftool_Runner                        #
}

function GitDifftool_mergeCommit1_parentsCommit_case3() {
    LogInfo 'from all parentsCommits to mergeCommit1'          # targetCommitBranch1 : merged commit 만 가능
    targetCommitBranch1="$1"                                   #
    range_arg="${targetCommitBranch1}"
    BaseCommit=$range_arg
    cmd=git show $range_arg
}

function GitDifftool_commit1_commit2_dobule_dot() {
    targetCommitBranch1="$1"
    targetCommitBranch2="$2"
    range_arg="$targetCommitBranch1..$targetCommitBranch2"
    multiThread=1
    BaseCommit=$targetCommitBranch1
    TargetCommit=$targetCommitBranch2
    TargetCommit=$TargetCommit:
    GitDifftool_Runner
}

function GitDifftool_commit1_commit2_triple_dot() {
    LogInfo 'git diff A...B is equivalent to git diff $(git merge-base A B) B'
    targetCommitBranch1="$1"
    targetCommitBranch2="$2"
    range_arg="$targetCommitBranch1...$targetCommitBranch2"
    multiThread=1
    BaseCommit=$targetCommitBranch1
    TargetCommit=$targetCommitBranch2
    TargetCommit=$TargetCommit:
    GitDifftool_Runner
}

function GitDifftool_commit1_commit2_triple_dot_case2() {
    LogInfo 'git diff A...B is equivalent to git diff $(git merge-base A B) B'

    targetCommitBranch1="$1"
    targetCommitBranch2="$2"
    range_arg="git diff $(git merge-base $targetCommitBranch1 $targetCommitBranch2) $targetCommitBranch2"
    multiThread=1 && GitDifftool_Runner
}

function GitDifftool_Compare_RevRange_No_OpenAllFiles() {
    # gdt_rev_no HEAD 1
    # gdt_rev_no HEAD 2
    # gdt_rev_no HEAD 3
    multiThread=1 && TargetCommit="$1" && no="$2"
    BaseCommit=$TargetCommit~$no
    range_arg="$BaseCommit...$TargetCommit"
    TargetCommit=$TargetCommit:
    GitDifftool_Runner
}

function GitDifftool_Compare_RevRange_OpenAllFiles() {
    # gdt_rev HEAD~3...HEAD
    # BaseCommit   HEAD~3
    # TargetCommit HEAD

    # gdt_rev 1{.2.3.}4

    multiThread=1 && range_arg="$@"
    BaseCommit=$(echo $range_arg | cut --fields=1 --delimiter='.')
    TargetCommit=$(echo $range_arg | cut --fields=4 --delimiter='.')
    TargetCommit=$TargetCommit:
    GitDifftool_Runner
}

function GitDifftool_Compare_HEAD_OpenAllFiles() {
    multiThread=1 && range_arg=HEAD~...HEAD
    BaseCommit=HEAD~
    TargetCommit=HEAD
    TargetCommit=$TargetCommit:
    GitDifftool_Runner
}

function GitDifftool_Compare_BaseCommit_WorkingTree_OpenAllFiles() {
    # gdt_b_w HEAD~3
    # gdt_b_w HEAD~2
    # gdt_b_w HEAD~1
    # gdt_b_w HEAD

    multiThread=1 && range_arg="$@"
    BaseCommit=$range_arg
    GitDifftool_Runner
}

function GitDifftool_Compare_HEAD_WorkingTree_OpenAllFiles() {
    multiThread=1 && range_arg=HEAD
    BaseCommit=$range_arg
    GitDifftool_Runner
}

function GitDifftool_Compare_IndexStage_WorkingTree_OpenAllFiles() {
    multiThread=1 && viewLog=0 && range_arg=--staged
    BaseCommit=HEAD
    GitDifftool_Runner
}

function GitDifftool_Compare_IndexUnStage_WorkingTree_OpenAllFiles() {
    multiThread=1 && viewLog=0
    BaseCommit=HEAD
    GitDifftool_Runner
}

function GitDifftool_Compare_NoIndex() {
    # git diff --no-index a b
    #   compares two non-git things (1) and (2).
    fileTwoPath="$@"
    git diff --raw --stat --no-index $fileTwoPath && LogInfo
    git difftool --no-index --no-prompt $fileTwoPath
}

function GitDifftool_Compare_RevRange_OpenOneByOne() {
    range_arg="$@" && GitDifftool_Runner
}

function GitDifftool_Compare_HEAD_OpenOneByOne() {
    range_arg=HEAD~...HEAD
    BaseCommit=HEAD~
    TargetCommit=HEAD
    TargetCommit=$TargetCommit:
    GitDifftool_Runner
}

function GitDifftool_Compare_HEAD_WorkingTree_OpenOneByOne() {
    range_arg=HEAD
    BaseCommit=HEAD
    GitDifftool_Runner
}

function GitDifftool_Compare_IndexStage_WorkingTree_OpenOneByOne() {
    viewLog=0 && range_arg=--staged && GitDifftool_Runner
}

function GitDifftool_Compare_IndexUnStage_WorkingTree_OpenOneByOne() {
    viewLog=0 && GitDifftool_Runner
}

function GetVarLength() {
    arg_info="$@"
    arg_var_length=${#arg_info}    # ${#var} (OK) / $#var (X)
}

function GetOnlyAsciiVarLength() {
    arg_info="$@"
    arg_var_length=$(echo -n $arg_info | wc --bytes) # Ascii(no, eng) (OK) / Korean (1 char -> 3 char)
}

function GetGithubCommitSubjectMsgLength() {
    commitSubject=$(cat .git/COMMIT_EDITMSG | head -1 | xargs echo -n)
    commitSubjectLength=${#commitSubject}
}

function GetOnlyAsciiGithubCommitSubjectMsgLength() {
    commitSubjectLength=$(cat .git/COMMIT_EDITMSG | head -1 | xargs echo -n | wc --bytes)
}

function test_git_diff_index_exec() {
    # If there are whitespace errors, print the offending file names and fail.
    exec git diff-index --check --cached $against --  # [with    exec]     direct terminate shell script (errorlevel > 0)
    # git diff-index --check --cached $against --     # [without exec] not direct terminate shell script (errorlevel > 0)
    return 0
}

function test_git_diff_index_normal() {
    # exec git diff-index --check --cached $against --  # [with    exec]     direct terminate shell script (errorlevel > 0)
    git diff-index --check --cached $against --         # [without exec] not direct terminate shell script (errorlevel > 0)
    return 0
}

function for_read_var() {
    for var in $(echo 160000 commit 33ca31) ; do
        echo $var
    done
    # 160000
    # commit
    # 33ca31
}

function while_read_full_line() {
    # IFS="" 와 IFS= 설정은 동일 # 명확하게 하기 위해서 무조건 IFS="" 사용하자.
    # IFS="" # space를 delimiter 로 parsing하지 않고 전체 Line을 변수에 할당하겠다.
    while IFS="" read -r line; do
        echo $line
    done <<< $(echo 160000 commit 33ca31 submodule_CDE)
}

function whileReadArray() {
    # array 에서는 IFS=" " 사용하면 비정상 동작
    # while IFS=" " read -a arr; do  # 비정상
    while read -a arr; do
        echo ${arr[0]} - ${arr[1]} - ${arr[2]} - ${arr[3]}
    done <<< $(git ls-tree origin/develop -r . --abbrev=7 | grep --color 160000)
}

function check_Submodule_HEAD_Status() {
    if [[ -f .gitmodules ]]; then
        maingGit_default_remote_branch=HEAD
        submoduleGit_default_remote_branch=origin/develop
        cmd="git submodule foreach git rev-list --count $maingGit_default_remote_branch..$submoduleGit_default_remote_branch"
        CommandRunner

        submoduleNo=$(cat .gitmodules | grep --color url | wc --lines)
        syncSubmoduleNo=$(git submodule foreach git rev-list --count $maingGit_default_remote_branch..$submoduleGit_default_remote_branch | grep --color 0 | wc --lines)

        if [[ $syncSubmoduleNo != $submoduleNo ]]; then
            LogInfoLev0 submoduleNo $submoduleNo
            LogInfoLev0 syncSubmoduleNo $syncSubmoduleNo
            LogInfoLev0 [Error] "syncSubmoduleNo($syncSubmoduleNo) should be submoduleNo($submoduleNo)"
            LogInfoLev0 [Error] Please rebase submodule branch to $submoduleGit_default_remote_branch
            exit 1
        fi
    fi
}

function check_Submodule_remoteDefault_Status() {
    if [[ -f .gitmodules ]]; then
        maingGit_default_remote_branch=$1
        submoduleGit_default_remote_branch=$2
        LogInfo "Check if newCommit exists in submoduleGit_default_remote_branch($submoduleGit_default_remote_branch) based on maingGit_default_remote_branch($maingGit_default_remote_branch)"
        while read -a arr; do
            submoduleHead=${arr[2]}
            submodulePath=${arr[3]}
            PushDirectory $submodulePath
            set -xe
            newCommitNo_origin_develop=$(git rev-list --count $submoduleHead..$submoduleGit_default_remote_branch)
            set +xe
            if [[ $newCommitNo_origin_develop != 0 ]]; then
                LogInfoLev0 [Error] [$submodulePath] submoduleHead $submoduleHead
                LogInfoLev0 [Error] [$submodulePath] newCommitNo_origin_develop : $newCommitNo_origin_develop
                LogInfoLev0 [Error] "[$submodulePath] newCommitNo_origin_develop($newCommitNo_origin_develop) should be Zero"
                LogInfoLev0 [Error] "Please rebase submodule[$submodulePath]'s branch to $submoduleGit_default_remote_branch"
                exit 1
            else
                LogInfoLev0 [Info] [$submodulePath] submoduleHead $submoduleHead
                LogInfoLev0 [Info] [$submodulePath] newCommitNo_origin_develop : $newCommitNo_origin_develop
            fi
            PopDirectory
        done <<< $(git ls-tree $maingGit_default_remote_branch -r . --abbrev=7 | grep --color 160000)
    fi
}

function git_fetch_fail() {
    cmd=git_all_branch && CommandRunner
    cmd="git fetch --prune --prune-tags --tags --verbose --jobs=8 --recurse-submodules=on-demand" && CommandRunner
    [[ -f .gitmodules ]] && cmd="check_Submodule_remoteDefault_Status develop origin/develop" && CommandRunner
    cmd=git_all_branch && CommandRunner

    # maingGit_default_remote_branch=$1     // develop        // Main Git's Main Branch      // Main Git's  origin/develop 의 ls-tree 에 연결된 commit 이
    # submoduleGit_default_remote_branch=$2 // origin/develop // Submodule Git's Main Branch // Submodule 의 origin/develop 을 Rebase 하지 않고 있다면 Fail

    # fail test 를 위해서 maingGit_default_remote_branch = develop 설정하면 script 동작성 확인 가능함
    return 0
}

function git_fetch() {
    cmd=git_all_branch && CommandRunner
    cmd="git fetch --prune --prune-tags --verbose --jobs=8 --recurse-submodules=on-demand" && CommandRunner
    [[ -f .gitmodules ]] && cmd="check_Submodule_remoteDefault_Status origin/develop origin/develop" && CommandRunner
    cmd=git_all_branch && CommandRunner

    # maingGit_default_remote_branch=$1     // origin/develop // Main Git's Main Branch      // Main Git's  origin/develop 의 ls-tree 에 연결된 commit 이
    # submoduleGit_default_remote_branch=$2 // origin/develop // Submodule Git's Main Branch // Submodule 의 origin/develop 을 Rebase 하지 않고 있다면 Fail
    return 0
}

function gitLog_Submodule_HEAD_Status() {
    if [[ -f .gitmodules ]]; then
        maingGit_default_remote_branch=HEAD
        submoduleGit_default_remote_branch=origin/develop
        while read -a arr; do
            submoduleHead=${arr[2]}
            submodulePath=${arr[3]}
            PushDirectory $submodulePath
            LogInfo "[$submodulePath] HEAD : $submoduleHead"
            # git log (local branch revison) : commit + ar(author date) + subject
            cmd="git log --graph --format=format:'%C(yellow)%<|(20)%h%Creset%C(red)%<|(35,trunc)%ar%Creset%C(bold blue)%d%Creset%<(70,trunc) %s' $submoduleGit_default_remote_branch..$submoduleHead"
            CommandRunnerBash
            PopDirectory
        done <<< $(git ls-tree $maingGit_default_remote_branch -r . --abbrev=7 | grep --color 160000)
    fi
}

function git_submodule() {
    LogInfoFt_Main "Main Git Status"
    cmd="git remote --verbose" && CommandRunnerWON
    cmd="git status --short --branch" && CommandRunnerWON
    cmd="git ls-tree HEAD . --abbrev=7" && CommandRunnerWON
    cmd="git log --decorate --oneline -2" && CommandRunnerWON
    cmd="git cat-file -p HEAD" && CommandRunnerWON
    maingGit_default_remote_tracking_branch=origin/develop

    cmd="git log --graph --format=format:'%C(yellow)%<|(20)%h%Creset%C(red)%<|(35,trunc)%ar%Creset%C(bold blue)%d%Creset%<(70,trunc) %s' $maingGit_default_remote_tracking_branch.."
    CommandRunnerBash
    LogInfo

    cmd="git log --graph --decorate --oneline --patch --submodule=log $maingGit_default_remote_tracking_branch.. | grep -E --color '^[*| ]+([0-9a-f]{7} |Submodule |> )' || :"
    CommandRunnerBash
    LogInfo

    cmd="git ls-tree HEAD -r . --abbrev=7 | grep --color 160000 || :"
    CommandRunnerBash

    LogInfoFt_Main "Submodule Git Status"
    LogInfoLev0 "[git submodule summary] will not be printed if there are not changes in submodule path"
    LogInfoLev0 "[git submodule summary] will be printed"
    LogInfoLev0 "if there are changes in submodule path and does not run git add/commit in main git."
    LogInfoLev0 "All the [git submodule summary] must be run git add/commit in main git."]
    cmd="git submodule summary" && CommandRunnerWON

    cmd="git submodule foreach 'git checkout --force -B develop && git branch --verbose --set-upstream-to=origin/develop && git status --short --branch'"
    CommandRunnerBash

    cmd="gitLog_Submodule_HEAD_Status" && CommandRunnerWON
}

function git_submodule_all() {
    LogInfoFt_Main "Main Git Status"
    cmd="git remote --verbose" && CommandRunnerWON
    cmd="git status --short --branch" && CommandRunnerWON
    cmd="git ls-tree HEAD . --abbrev=7" && CommandRunnerWON
    cmd="git log --decorate --oneline -2" && CommandRunnerWON
    cmd="git cat-file -p HEAD" && CommandRunnerWON

    LogInfoFt_Main "Submodule Git Status"
    for var in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }') ; do
        PushDirectory $var
        cmd="git remote --verbose" && CommandRunnerWON
        cmd="git status --short --branch" && CommandRunnerWON
        cmd="git ls-tree HEAD . --abbrev=7" && CommandRunnerWON
        cmd="git log --decorate --oneline -2" && CommandRunnerWON
        cmd="git cat-file -p HEAD" && CommandRunnerWON
        PopDirectory
    done
}

function git_local_branch() {
    LogInfoFt_Main "Local Branch With Tags : refs/heads, refs/origin, refs/tags"

    LogInfoFt "[1] Name Only"
    cmd="git for-each-ref --format='%(refname:strip=-1)'"
    CommandRunnerBash

    LogInfoFt "[2] prefix(heads/origin/tags)"
    cmd="git for-each-ref --format='%(refname:strip=-2)'"
    CommandRunnerBash
}

function git_remote_branch() {
    LogInfoFt_Main "Remote Branch With Tags : HEAD, refs/heads, refs/pull, refs/tags"

    cmd="git ls-remote origin" && CommandRunner
}

function git_all_branch() {
    git_local_branch
    git_remote_branch
}

function git_local_refs_heads() {
    LogInfoFt_Main "Local refs/heads"

    LogInfoFt "[1] Name Only"
    cmd="git for-each-ref --format='%(refname:strip=-1)' refs/heads"
    CommandRunnerBash

    LogInfoFt "[2] prefix(heads)"
    cmd="git for-each-ref --format='%(refname:strip=-2)' refs/heads"
    CommandRunnerBash
}

function git_local_refs_remotes() {
    LogInfoFt_Main "Local refs/remotes"

    LogInfoFt "[1] Name Only"
    cmd="git for-each-ref --format='%(refname:strip=-1)' refs/remotes"
    CommandRunnerBash

    LogInfoFt "[2] prefix(origin)"
    cmd="git for-each-ref --format='%(refname:strip=-2)' refs/remotes"
    CommandRunnerBash
}

function git_local_refs_tags() {
    LogInfoFt_Main "Local refs/tags"

    LogInfoFt "[1] Name Only"
    cmd="git for-each-ref --format='%(refname:strip=-1)' refs/tags"
    CommandRunnerBash

    LogInfoFt "[2] prefix(tags)"
    cmd="git for-each-ref --format='%(refname:strip=-2)' refs/tags"
    CommandRunnerBash
}

function a__git_local_refs_tags() {
    LogInfoFt_Main "Local refs/tags"

    LogInfoFt "[1] Name Only"
    cmd="git for-each-ref --format='%(refname:strip=-1)' refs/tags"
    CommandRunnerBash

    LogInfoFt "[2] prefix(tags)"
    cmd="git for-each-ref --format='%(refname:strip=-2)' refs/tags"
    CommandRunnerBash
}

function git_remote_refs() {
    LogInfoFt_Main "Remote refs/heads, refs/pull, refs/tags"

    cmd="git ls-remote --refs origin" && CommandRunner
}

function git_remote_heads() {
    LogInfoFt_Main "Remote refs/heads"

    cmd="git ls-remote --heads origin" && CommandRunner
}

function git_remote_pull() {
    LogInfoFt_Main "Remote refs/pull"

    cmd="git ls-remote --refs origin *pull*" && CommandRunner
}

function git_remote_tags() {
    LogInfoFt_Main "Remote refs/tags"

    cmd="git ls-remote --tags origin" && CommandRunner
}

function RunPreserveQuoteAndPipe() {
    # var='123' && echo ${var@Q}
    cmd="echo '1 2 3' | grep --color 2" && CommandRunnerQuote $cmd # Error
    cmd="echo '1 2 3' | grep --color 2" && CommandRunner           # Error
    cmd="echo '1 2 3' | grep --color 2" && CommandRunnerBash       # OK
}

function CommandRunnerQuote() {
    LogInfoFt [Start] $cmd
    "$@"
    errorlevel=$?
    [[ $errorlevel -ne 0 ]] && LogInfo [Error][errorlevel $errorlevel] $cmd && exit 1
    LogInfoFt [End] $cmd
}

function CommandArgumentsRunner_setDebug() {
    cmd="1 2 3" && CommandArguments_setDebug $cmd
}

function CommandArguments_setDebug() {
    set -xe
    echo "$@"
    for var in "$@" ; do echo $var ; done
    set +xe
    LogInfo
    set -xe
    echo "$*"
    for var in "$*" ; do echo $var ; done
    set +xe
}

function CommandArgumentsRunner() {
    cmd="foo bar baz 'long arg'" && CommandArguments $cmd
}

function CommandArguments() {
    # The difference is subtle(미묘하게 different)
    # "$*" creates one argument separated by the $IFS variable,
    # "$@" will expand into separate arguments

    LogInfo "[echo each line] foo\nbar\nbaz\n'long\narg'"
    for i in "$@"; do echo $i; done
    # foo
    # bar
    # baz
    # 'long
    # arg'

    LogInfo [echo one line] foo bar baz 'long arg' # [cmd] for /f "tokens=*" %%f in (%*) do (echo %%f)
    for i in "$*"; do echo $i; done
    # foo bar baz 'long arg'  # IFS 에 의해서 구분된 상태 그대로 1 arg로 전달
    # batch 의 %* 기능과 동일하게 All Arg 를 한번에 받게 해주는데 for loop 에서는 1 time iteration
}

################# function and argument
########## "" 있어야지 "$@", "$*" 차이를 확인 가능
########## "" 없으면 $@, $* 결과는 모두 for loop 에서 개수별로 line 별 print

# $function fun() { for i in a b c; do echo $i; done; } && fun
# a
# b
# c
# $function fun() { for i in 'a b c'; do echo $i; done; } && fun
# a b c
# $function fun() { for i in "a b c"; do echo $i; done; } && fun
# a b c

# $function fun() { for i in "$@"; do echo $i; done; } && arr='a b c' && fun $arr
# a
# b
# c
# $function fun() { for i in "$*"; do echo $i; done; } && arr='a b c' && fun $arr
# a b c
# $function fun() { for i in $@; do echo $i; done; } && arr='a b c' && fun $arr
# a
# b
# c
# $function fun() { for i in $*; do echo $i; done; } && arr='a b c' && fun $arr
# a
# b
# c

# $function fun() { for i in "$@"; do echo $i; done; } && arr='a "b c" d' && fun $arr
# a
# "b
# c"
# d
# $function fun() { for i in "$*"; do echo $i; done; } && arr='a "b c" d' && fun $arr
# a "b c" d

###### array 의 "" 로 구분된 key 가 있다면 iteration 에서 "${arr[@]}" 와 같이 ""(quote) 필수

# $function fun() { for i in "${arr[@]}"; do echo $i; done; } && arr=(a "b c" d) && fun
# a
# b c
# d
# $function fun() { for i in ${arr[@]}; do echo $i; done; } && arr=(a "b c" d) && fun
# a
# b
# c
# d

function git_email_tags() {
    git for-each-ref --sort='-creatordate' \
    --format='From: %(authorname) %(authoremail)
    Subject: %(subject)
    Date: %(creatordate:relative)
    Ref: %(refname)
    SHA: %(objectname:short)
    ' 'refs/tags'
}

function git_email_heads() {
    git for-each-ref --sort='-authordate' \
    --format='From: %(authorname) %(authoremail)
    Subject: %(subject)
    Date: %(authordate:relative)
    Ref: %(refname)
    SHA: %(objectname:short)
    ' 'refs/heads'
}

function git_email_count3_remotes_origin() {
    git for-each-ref --count=3 --sort='-authordate' \
    --format='From: %(authorname) %(authoremail)
    Subject: %(subject)
    Date: %(authordate:relative)
    Ref: %(refname)
    SHA: %(objectname:short)
    ' 'refs/remotes/origin'
}

function eval_effect() {
    # file:///C:/Program%20Files/Git/mingw64/share/doc/git-doc/git-for-each-ref.html
    entry=ref=refs/heads/dev  #
    echo 1 $entry : $ref      # 1 ref=refs/heads/dev :
    eval "$entry"             #
    echo 2 $entry : $ref      # 2 ref=refs/heads/dev : refs/heads/dev

    # eval "$entry" 처리 이후 'entry=ref=refs/heads/dev' 에서 설정한
    # 'ref=refs/heads/dev' 를 shell 에서 evaluation 처리해서 $ref 변수 접근이 가능해진다.
}

function eval_effect_1() {
    entry=ref='refs/heads/dev'  #
    echo 1 $entry : $ref        # 1 ref=refs/heads/dev :
    eval "$entry"               #
    echo 2 $entry : $ref        # 2 ref=refs/heads/dev : refs/heads/dev
}

function git_latest_heads_dirname() {
    # file:///C:/Program%20Files/Git/mingw64/share/doc/git-doc/git-for-each-ref.html
    git for-each-ref --shell --count=1 --format="ref=%(refname)" refs/heads | while read entry
    do
        # entry=ref='refs/heads/dev' #
        echo 1 $entry : $ref         # 1 ref=refs/heads/dev :
        eval "$entry"                #
        echo 2 $entry : $ref         # 2 ref=refs/heads/dev : refs/heads/dev
        echo `dirname $ref`          # refs/heads
    done
}

function git_latest_heads_basename() {
    git for-each-ref --shell --count=1 --format="ref=%(refname)" refs/heads | while read entry
    do
        # entry=ref='refs/heads/dev' #
        echo 1 $entry : $ref         # 1 ref=refs/heads/dev :
        eval "$entry"                #
        echo 2 $entry : $ref         # 2 ref=refs/heads/dev : refs/heads/dev
        echo `basename $ref`         # dev
    done
}

function IsGitEnv() {
    SuppressSuccessAndErrorMessage git rev-parse --verify HEAD
    [[ "$?" -eq "0" ]] && echo IsGitEnv || echo IsNotGitEnv
}

function ExistRemoteUpstreamBranch() {
    SuppressSuccessAndErrorMessage git rev-parse --symbolic-full-name @{u}
    [[ "$?" -eq "0" ]] && echo ExistRemoteUpstream || echo NoExistRemoteUpstream
}

function git_ref_all_head() {
    git_ref_local_heads
    git_ref_upstream_top 3
}

function git_ref_local_heads() {
    if [[ "$(IsGitEnv)" == "IsGitEnv" ]]; then
        git for-each-ref --format='%(HEAD) %(align:35)%(refname:lstrip=2)%(end)%(objectname:short) %(align:13)%(authordate:relative)%(end) %(align:0)%(if)%(upstream)%(then)[%(upstream:lstrip=2)]%(end)%(upstream:track)%(end)%(contents:subject)' --sort='-authordate' refs/heads
    fi
}

function git_ref_upstream() {
    if [[ "$(IsGitEnv)" == "IsGitEnv" ]]; then
        if [[ "$(ExistRemoteUpstreamBranch)" == "ExistRemoteUpstream" ]]; then
            git for-each-ref --format='%(HEAD) %(align:34)%(refname:lstrip=2)%(end) %(objectname:short) %(align:13)%(authordate:relative)%(end) %(align:0)%(if)%(upstream)%(then)[%(upstream:lstrip=2)]%(end)%(upstream:track)%(end)%(contents:subject)' $(git rev-parse --symbolic-full-name @{u})
        fi
    fi
}

function git_ref_upstream_top() {
    if [[ "$(IsGitEnv)" == "IsGitEnv" ]]; then
        if [[ "$(ExistRemoteUpstreamBranch)" == "ExistRemoteUpstream" ]]; then
            git for-each-ref --format='%(HEAD) %(align:34)%(refname:lstrip=2)%(end) %(objectname:short) %(align:13)%(authordate:relative)%(end) %(align:0)%(if)%(upstream)%(then)[%(upstream:lstrip=2)]%(end)%(upstream:track)%(end)%(contents:subject)' $(git rev-parse --symbolic-full-name @{u})
        else
            top_no=$1
            git for-each-ref --format='%(HEAD) %(align:34)%(refname:lstrip=2)%(end) %(objectname:short) %(align:13)%(authordate:relative)%(end) %(align:0)%(if)%(upstream)%(then)[%(upstream:lstrip=2)]%(end)%(upstream:track)%(end)%(contents:subject)' --sort='-authordate' --count=$top_no refs/remotes
        fi
    fi
}

function stringCompare_EqualSign() {
    ############################### string case 는 ==, != 만 정상
    ############################### string case 는 -eq, -ne 만 비정상 --> 사용하지 말자.
    var="abc" && [[ "$var" == "abc" ]] && echo $var "== OK" || echo $var "== Issue"
    var="abc1" && [[ "$var" == "abc" ]] && echo $var "== Issue" || echo $var "== OK"
    LogInfo
    var="abc" && [[ "$var" != "abc" ]] && echo $var "!= Issue" || echo $var "!= OK"
    var="abc1" && [[ "$var" != "abc" ]] && echo $var "!= OK" || echo $var "!= Issue"
}

function stringCompare_EqNe() {
    ############################### string case 는 ==, != 만 정상
    ############################### string case 는 -eq, -ne 만 비정상 --> 사용하지 말자.
    var="abc" && [[ "$var" -eq "abc" ]] && echo $var "-eq OK" || echo $var "-eq Issue"
    var="abc1" && [[ "$var" -eq "abc" ]] && echo $var "-eq Issue" || echo $var "-eq OK"
    LogInfo
    var="abc" && [[ "$var" -ne "abc" ]] && echo $var "-ne Issue" || echo $var "-ne OK"
    var="abc1" && [[ "$var" -ne "abc" ]] && echo $var "-ne OK" || echo $var "-ne Issue"
}

function numberCompare_EqualSign() {
    ############################### number case 는 ==, !=, -eq, -ne 모두 정상
    var=1 && [[ "$var" == "1" ]] && echo $var "== OK" || echo $var "== Issue"
    var=2 && [[ "$var" == "1" ]] && echo $var "== Issue" || echo $var "== OK"
    LogInfo
    var=1 && [[ "$var" != "1" ]] && echo $var "!= Issue" || echo $var "!= OK"
    var=2 && [[ "$var" != "1" ]] && echo $var "!= OK" || echo $var "!= Issue"
}

function numberCompare_EqNe() {
    ############################### number case 는 ==, !=, -eq, -ne 모두 정상
    var="1" && [[ "$var" -eq "1" ]] && echo $var "-eq OK" || echo $var "-eq Issue"
    var="2" && [[ "$var" -eq "1" ]] && echo $var "-eq Issue" || echo $var "-eq OK"
    LogInfo
    var="1" && [[ "$var" -ne "1" ]] && echo $var "-ne Issue" || echo $var "-ne OK"
    var="2" && [[ "$var" -ne "1" ]] && echo $var "-ne OK" || echo $var "-ne Issue"
}

function RunWithExec() {
    exec ls --color && echo 1 || echo 2 # exec ls 만 하고 direct script 종료 // echo 1 / 2 과정 없음
}

function RunWithoutExec() {
    ls --color && echo 1 || echo 2      # exec ls 이후 echo 1 / 2 과정 진행
}

function GetGitTopLevel() {
    gitTopLevel=$(git rev-parse --show-toplevel)
    echo $gitTopLevel
}

function GetGitTopLevelDelim() {
    gitTopLevel=$(git rev-parse --show-toplevel)"/"
    echo $gitTopLevel
}

function GetSubString() {
    string_arg=$1
    startOffset=$2   # zero base offset
    stringLength=$3

    subStr=${string_arg:$startOffset:$stringLength}
}

function GetSubString0To2() {
    string_arg=$1
    subStr=${string_arg:0:2} # string_arg[0,2)
}

function GetSubString1To3() {
    string_arg=$1
    subStr=${string_arg:1:3} # string_arg[1,3)
}

function GetSubString3To1024() {
    string_arg=$1
    subStr=${string_arg:3:1024} # string_arg[3,1024)
}

function GetSubString3To1024() {
    string_arg=$1
    subStr=${1:3:1024} # string_arg[3,1024)
}

function GetSubStringRunner() {
    GetSubString abcdef 2 50
    GetSubString abcdef 2 -1
}

function CallSubString() {
    inputStr="abcdef"
    for offset in $(seq 0 3) ; do
        cmd="GetSubString $inputStr $offset 2"
        CommandRunnerWON
        echo $subStr
    done
}

function forInteration0() {
    libNo=0
    for ((i = 0 ; i < libNo ; i++ )); do # [0,0) # no print
        echo $i
    done
}

function forInteration1() {
    libNo=1
    for ((i = 0 ; i < libNo ; i++ )); do # [0,1) # print 0
        echo $i
    done
}

function forInteration() {
    for iter in $(seq 0 50) ; do # [0,50]
        echo $iter
    done
}

function RunGetOpts_longArgs_dash_plus() {
    # $0 -+j 3
    # ${arg}     # + #
    # ${OPTARG}  # j # key
    # ${!OPTIND} # 3 # value

    ### long arg 에 1st arg는 무조건 - 이고 그 이후 char를 $(arg}, $(OPTARG) 로 할당
    ### key   : -$(arg}$(OPTARG)
    ### value : ${!OPTIND}

    optstring=":+:"
    ### :{+:} 와 같이 $(arg}$(OPTARG) 뒤에 value (${!OPTIND}) 도 사용하려면 {1char:} 방식으로 : 를 뒤에 append 필수
    ### 맨 앞의 : 의 append 는 안정성을 위해서 필수적으로 사용하자.

    while getopts ${optstring} arg; do
        case "${arg}" in
            +)
                case "${OPTARG}" in
                    co|cmakeOff) cmakeOffEnable=1;;
                    b|build) buildOption=build;;
                    c|clean) buildOption=clean;;
                    cl|clang) clangEn=1; cmakeVsClangOption="-T LLVM";; ### Current (Error)
                    cp|cppcheck) cppCheckEn=1; compileCmdJsonOption="ON";;
                    cpp|cppcheckProj) cppCheckEn=2; cppCheckTarget=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpc|cppcheckConf) cppCheckConfig=${!OPTIND}; OPTIND=$(( $OPTIND + 1 )); cppCheckConfigOption="--project-configuration=$cppCheckConfig|x64";;
                    cpo|cppcheckOption) cppCheckOption=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpx|cppcheckXmlOutput) cppcheckXmlOutput="--xml";;
                    cpvs|cppcheckTemplateVs) cppcheckTemplate="--template=vs";;
                    cpgcc|cppcheckTemplateGcc) cppcheckTemplate="--template=gcc";; ### Default Option
                    cpstd|cppcheckStd) cppCheckStd=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpj|cppcheckJobs) cppCheckJobsNo=${!OPTIND}; cppCheckJobs="-j $cppCheckJobsNo"; OPTIND=$(( $OPTIND + 1 ));;
                    cm|cmake) cmakeOnlyEnable=1;;
                    com|compile) compileOnlyEnable=1;;
                    ce|compileExe) compileExeOnlyEnable=1;;
                    e|exe) exeRunOnlyEnable=1;;
                    ge|gwe|gccWarningAsError) gccTreatWarningAsErrorEn=1;;
                    go|gol|gccOptLevel) gccOptmizationLevel=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    h|help) optionHelp && exit 0;;
                    j|jobs) maxMakeJobNo=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    l|log-level) logLevel=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    p|pause) pauseModeEnable=1;;
                    r|rebuild) buildOption=rebuild;;
                    t|tee) teeEnable=1;;
                    v|version) getVersion; exit 0;;
                    vsg|vsgen) visualStudioGenMode=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vsa|vsArch) visualStudioArchitecture=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vst|vsToolset) visualStudioToolset=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vs) visualStudioModeEn=1;;
                    vsr|vsrun) visualStudioRunConfig=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    *)
                        echo "[$LINENO][$0] Unknown option --${OPTARG}" && exit 1;;
                esac;;
            ?)
                echo "Invalid option: -${OPTARG}." && exit 1;;
        esac
    done
}

function RunGetOpts_longArgs_doubleDash() {
    # $0 --j 3
    # ${arg}     # - #
    # ${OPTARG}  # j # key
    # ${!OPTIND} # 3 # value

    ### long arg 에 1st arg는 무조건 - 이고 그 이후 char를 $(arg}, $(OPTARG) 로 할당
    ### key   : -$(arg}$(OPTARG)
    ### value : ${!OPTIND}

    optstring=":-:"
    ### :{-:} 와 같이 $(arg}$(OPTARG) 뒤에 value (${!OPTIND}) 도 사용하려면 {1char:} 방식으로 : 를 뒤에 append 필수
    ### 맨 앞의 : 의 append 는 안정성을 위해서 필수적으로 사용하자.

    while getopts ${optstring} arg; do
        case "${arg}" in
            -)
                case "${OPTARG}" in
                    co|cmakeOff) cmakeOffEnable=1;;
                    b|build) buildOption=build;;
                    c|clean) buildOption=clean;;
                    cl|clang) clangEn=1; cmakeVsClangOption="-T LLVM";; ### Current (Error)
                    cp|cppcheck) cppCheckEn=1; compileCmdJsonOption="ON";;
                    cpp|cppcheckProj) cppCheckEn=2; cppCheckTarget=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpc|cppcheckConf) cppCheckConfig=${!OPTIND}; OPTIND=$(( $OPTIND + 1 )); cppCheckConfigOption="--project-configuration=$cppCheckConfig|x64";;
                    cpo|cppcheckOption) cppCheckOption=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpx|cppcheckXmlOutput) cppcheckXmlOutput="--xml";;
                    cpvs|cppcheckTemplateVs) cppcheckTemplate="--template=vs";;
                    cpgcc|cppcheckTemplateGcc) cppcheckTemplate="--template=gcc";; ### Default Option
                    cpstd|cppcheckStd) cppCheckStd=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpj|cppcheckJobs) cppCheckJobsNo=${!OPTIND}; cppCheckJobs="-j $cppCheckJobsNo"; OPTIND=$(( $OPTIND + 1 ));;
                    cm|cmake) cmakeOnlyEnable=1;;
                    com|compile) compileOnlyEnable=1;;
                    ce|compileExe) compileExeOnlyEnable=1;;
                    e|exe) exeRunOnlyEnable=1;;
                    ge|gwe|gccWarningAsError) gccTreatWarningAsErrorEn=1;;
                    go|gol|gccOptLevel) gccOptmizationLevel=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    h|help) optionHelp && exit 0;;
                    j|jobs) maxMakeJobNo=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    l|log-level) logLevel=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    p|pause) pauseModeEnable=1;;
                    r|rebuild) buildOption=rebuild;;
                    t|tee) teeEnable=1;;
                    v|version) getVersion; exit 0;;
                    vsg|vsgen) visualStudioGenMode=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vsa|vsArch) visualStudioArchitecture=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vst|vsToolset) visualStudioToolset=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vs) visualStudioModeEn=1;;
                    vsr|vsrun) visualStudioRunConfig=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    *)
                        echo "[$LINENO][$0] Unknown option --${OPTARG}" && exit 1;;
                esac;;
            ?)
                echo "Invalid option: -${OPTARG}. Please use two dash(--) with ${OPTARG}." && exit 1;;
        esac
    done
}

function RunGetOpts_build() {
    optstring=":bcehj:l:prtv-:"
    while getopts ${optstring} arg; do
        case "${arg}" in
            b) buildOption=build;;
            c) buildOption=clean;;
            e) exeRunOnlyEnable=1;;
            h) optionHelp && exit 0;;
            j) maxMakeJobNo=${OPTARG};;
            l) logLevel=${OPTARG};;
            p) pauseModeEnable=1;;
            r) buildOption=rebuild;;
            t) teeEnable=1;;
            v) getVersion; exit 0;;
            -)
                case "${OPTARG}" in
                    b|build) buildOption=build;;
                    co|cmakeOff) cmakeOffEnable=1;;
                    c|clean) buildOption=clean;;
                    cl|clang) clangEn=1; cmakeVsClangOption="-T LLVM";; ### Current (Error)
                    cp|cppcheck) cppCheckEn=1; compileCmdJsonOption="ON";;
                    cpp|cppcheckProj) cppCheckEn=2; cppCheckTarget=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpc|cppcheckConf) cppCheckConfig=${!OPTIND}; OPTIND=$(( $OPTIND + 1 )); cppCheckConfigOption="--project-configuration=$cppCheckConfig|x64";;
                    cpo|cppcheckOption) cppCheckOption=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpx|cppcheckXmlOutput) cppcheckXmlOutput="--xml";;
                    cpvs|cppcheckTemplateVs) cppcheckTemplate="--template=vs";;
                    cpgcc|cppcheckTemplateGcc) cppcheckTemplate="--template=gcc";; ### Default Option
                    cpstd|cppcheckStd) cppCheckStd=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    cpj|cppcheckJobs) cppCheckJobsNo=${!OPTIND}; cppCheckJobs="-j $cppCheckJobsNo"; OPTIND=$(( $OPTIND + 1 ));;
                    cm|cmake) cmakeOnlyEnable=1;;
                    com|compile) compileOnlyEnable=1;;
                    ce|compileExe) compileExeOnlyEnable=1;;
                    e|exe) exeRunOnlyEnable=1;;
                    ge|gwe|gccWarningAsError) gccTreatWarningAsErrorEn=1;;
                    go|gol|gccOptLevel) gccOptmizationLevel=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    h|help) optionHelp && exit 0;;
                    j|jobs) maxMakeJobNo=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    l|log-level) logLevel=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    p|pause) pauseModeEnable=1;;
                    r|rebuild) buildOption=rebuild;;
                    t|tee) teeEnable=1;;
                    v|version) getVersion; exit 0;;
                    vsg|vsgen) visualStudioGenMode=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vsa|vsArch) visualStudioArchitecture=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vst|vsToolset) visualStudioToolset=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    vs) visualStudioModeEn=1;;
                    vsr|vsrun) visualStudioRunConfig=${!OPTIND}; OPTIND=$(( $OPTIND + 1 ));;
                    *)
                        echo "[$LINENO][$0] Unknown option --${OPTARG}" && exit 1;;
                esac;;
            ?)
                echo "Invalid option: -${OPTARG}." && exit 1;;
        esac
    done
}

function pauseStep() {
    if [[ "${pauseModeEnable}" == "1" ]]; then
        pause
    fi
}

function pause() {
    echo && read -p "--------------------- ****** To continue, please enter anything. To exit, please enter {e} : " reply && echo
    [[ "$reply" == "e" ]] && exit 1
}

function RunGetopts_1stChar_Colon() {
    while getopts ":a:bc:" arg; do
        case "${arg}" in
            a|b|c) echo [Success] Key -$arg, Value $OPTARG;;
            :) echo "[$LINENO][$0] Please use -${OPTARG} with additional argument. Please use it as (key-value} pair." && exit 1;;
            ?)     echo [Error]   Key -$arg, Value $OPTARG;;
        esac
    done

#>bash 01_CB.sh script RunGetopts_1stChar_Colon -a 1 -b -c 2 -d
# [Success] Key -a, Value 1    #
# [Success] Key -b, Value      #
# [Success] Key -c, Value 2    #
# [Error] Key -?, Value d      # suppress stderr

### key value pair 설정 spec인데 key만 입력한 경우
#>bash 01_CB.sh script RunGetopts_1stChar_Colon -a 1 -b -c
# [Success] Key -a, Value 1
# [Success] Key -b, Value
# [1489][01_CB.sh] Please use -c with additional argument. Please use it as (key-value} pair.
}

function RunGetopts_without_1stChar_Colon() {
    while getopts "a:bc:" arg; do
        case "${arg}" in
            a|b|c) echo [Success] Key -$arg, Value $OPTARG;;
            :) echo "[$LINENO][$0] Please use -${OPTARG} with additional argument. Please use it as (key-value} pair." && exit 1;;
            ?)     echo [Error]   Key -$arg, Value $OPTARG;;
        esac
    done

#>bash 01_CB.sh script RunGetopts_without_1stChar_Colon -a 1 -b -c 2 -d
# [Success] Key -a, Value 1        #
# [Success] Key -b, Value          #
# [Success] Key -c, Value 2        #
# 01_CB.sh: illegal option -- d    # not suppress stderr
# [Error] Key -?, Value            #
}

function GetGitBaseNameCurrentWorkingDir() {
    CheckGitRepo
    if [[ $gitRepo == true ]]; then
        gitCwdBaseName = $(basename $(git rev-parse --show-toplevel))
        LogInfo "CWD(git) : $gitCwdBaseName"
    fi
}

function forLoopPathHash() {
    declare -A hash_map

    # Path
    for path in `ls path --indicator-style=none`; do
        [[ -e $path ]] && hash_map[$path]=True
    done

    # skip
    SKIP_SET=('A' 'B' '')
    for skip_var in ${SKIP_SET[@]} ; do
        unset hash_map[$skip_var]
    done

    # Keys
    for key in ${!hash_map[@]}; do
        echo $key
    done

    # Values
    for val in ${hash_map[@]}; do
        echo $val
    done
}

function forLoopHash() {
    declare -A hash_map
    hash_map['foo']=True
    hash_map['bar']=False

    # skip
    SKIP_SET=('A' 'B' '')
    for skip_var in ${SKIP_SET[@]} ; do
        unset hash_map[$skip_var]
    done

    # Keys
    for key in ${!hash_map[@]}; do
        echo $key
    done

    # Values
    for val in ${hash_map[@]}; do
        echo $val
    done
}

function makeHash() {
    declare -A hash_map
    hash_map['foo']=True
    hash_map['bar']=False
    echo size : ${#hash_map[@]}  # 2
    echo keys : ${!hash_map[@]}  # foo bar
    echo values : ${hash_map[@]} # True False
    echo ${hash_map['foo']}      # True
    echo ${hash_map['bar']}      # False
}

function makeArray() {
    ARRAY=()
    ARRAY+=('foo')
    ARRAY+=('bar')
    echo size : ${#ARRAY[@]} # 2
    echo all : ${ARRAY[@]}   # foo bar
    echo ${ARRAY[0]}         # foo
    echo ${ARRAY[1]}         # bar
}

# fun() { arr=(ab cd ef); echo ${#arr[@]}; } && fun               # 3
# fun() { arr=(ab cd ef); echo ${arr[@]}; } && fun                # ab cd ef
# fun() { arr=(ab cd ef); echo ${arr[0]}; } && fun                #
# fun() { arr=(ab cd ef); echo ${arr[1]}; } && fun                #
# fun() { arr=(ab cd ef); echo ${arr[2]}; } && fun                #
# fun() { arr=(ab cd ef); echo ${arr[@]:0}; } && fun              # [0,)
# fun() { arr=(ab cd ef); echo ${arr[@]:1}; } && fun              # [1,)
# fun() { arr=(ab cd ef); echo ${arr[@]:2}; } && fun              # [2,)
# fun() { arr=(ab cd ef); echo ${arr[@]:0:1}; } && fun            # [,1) = [,0]
# fun() { arr=(ab cd ef); echo ${arr[@]:0:2}; } && fun            # [0,2) = [,1]
# fun() { arr=(ab cd ef); echo ${arr[@]::1}; } && fun             # [,1) = [,0]
# fun() { arr=(ab cd ef); echo ${arr[@]::2}; } && fun             # [,2) = [,1]
# fun() { arr=(ab cd ef); echo ${arr[@]::${#arr[@]}}; } && fun    # [,3)
# fun() { arr=(ab cd ef); echo ${arr[@]::${#arr[@]}-1}; } && fun  # [,2)
# fun() { arr=(ab cd ef); echo ${arr[@]::${#arr[@]}-2}; } && fun  # [,1)
# fun() { arr=(ab cd ef); echo ${arr[@]:0:${#arr[@]}}; } && fun   # [0,3)
# fun() { arr=(ab cd ef); echo ${arr[@]:1:${#arr[@]}}; } && fun   # [1,3)
# fun() { arr=(ab cd ef); echo ${arr[@]:2:${#arr[@]}}; } && fun   # [2,3)
# fun() { arr=(ab cd ef); echo ${arr[@]:${#arr[@]}}; } && fun     # [3,)
# fun() { arr=(ab cd ef); echo ${arr[@]:${#arr[@]}-1}; } && fun   # [2,)
# fun() { arr=(ab cd ef); echo ${arr[@]:${#arr[@]}-2}; } && fun   # [1,)
# fun() { arr=(ab cd ef); echo ${arr[@]:${#arr[@]}-3}; } && fun   # [0,)

function echoDallar() {
    echo "\${CMAKE_SOURCE_DIR}\${CMAKE_SOURCE_DIR}"
}

function CheckDirExist() {
    arg_dir="$@"
    if [[ ! -d "$arg_dir" ]]; then
        LogInfo [Error] [$arg_dir] No Exist && exit 1
    fi
}

function getAbsPath() {
    arg="$@"
    echo $(realpath $arg)
}

function listUpperDirectory() {
    ls -p .. | grep '/$' | cut --fields=1 --delimiter='/'
}

# -eq -ne -lt -le -gt -ge
#### bash  : "" 유무 상관없이 operation 정상 동작 : bash 는 "" 제외 후 연산 수행하기 때문
#### batch : "" 제거없이 동작해서 "" 유무에 따라서 동작성 달라짐

function numberEq_OK1() {
    var=1
    [[ $var -eq 1 ]] && echo True || echo False
}

function numberEq_Ok2() {
    var=1
    [[ "$var" -eq "1" ]] && echo True || echo False
}

function numberGeq_OK1() {
    var=12
    [[ $var -ge 1 ]] && echo True || echo False
}

function numberGeq_Ok2() {
    var=12
    [[ "$var" -ge "1" ]] && echo True || echo False
}

function numberForGeq() {
    tar=5
    for var in $(seq 0 50) ; do
        if [[ $var -ge $tar ]]; then
            echo [True] "$var >= $tar"
        else
            echo [False] "$var >= $tar"
        fi
    done
}

function numberForLeq() {
    tar=5
    for var in $(seq 0 50) ; do
        if [[ $var -le $tar ]]; then
            echo [True] "$var <= $tar"
        else
            echo [False] "$var <= $tar"
        fi
    done
}

function printArrayAll() {
    arr=(1 2 3 4)
    for var in ${arr[@]}; do
        echo $var
    done
}

function printArrayFrom2ToInf() {
    arr=(1 2 3 4)
    for var in ${arr[@]:1}; do
        echo $var
    done
}

function printArrayFrom3ToInf() {
    arr=(1 2 3 4)
    for var in ${arr[@]:2}; do
        echo $var
    done
}

function printArrayFrom4ToInf() {
    arr=(1 2 3 4)
    for var in ${arr[@]:3}; do
        echo $var
    done
}

########################

# $1, $2, $3, ... are the positional parameters.
# "$@" is an array-like construct of all positional parameters, {$1, $2, $3 ...}.
# "$*" is the IFS expansion of all positional parameters, $1 $2 $3 ....

########################
# "$*" creates one argument separated by the $IFS variable,
# "$@" will expand into separate arguments.

function fun_arg_at_sign () {
    echo "$FUNCNAME : $@"
    for var in $@ ; do echo a $var ; done    # same with $*
    for var in "$@" ; do echo b $var ; done  # diff with $*
}

function fun_arg_star_sign () {
    echo "$FUNCNAME : $*"
    for var in $* ; do echo a $var ; done    # same with $@
    for var in "$*" ; do echo b $var ; done  # diff with $@
}

######################

function run_func_arg_star_at_sign () {
    fun_arg_star_at_sign 1 2 3
    fun_arg_star_at_sign 1 2 3

    return 0

    fun_arg_at_sign : 1 2 3
    a 1
    a 2
    a 3
    b 1
    b 2
    b 3
    fun_arg_star_sign : 1 2 3
    a 1
    a 2
    a 3
    b 1 2 3
}

### $- current options set for the shell.
run_arg_dash_sign() {
    echo $-

    return 0

    himBH  ## .bashrc / .bash_profile
    hB     ## normal script
}

### string 을 IFS 기준으로 분리 후 while loop 로 한줄씩 출력

function IFS_Print() {
    str="ab:cd:ef"
    while IFS=":" read -r -a arr; do
        for i in ${arr[@]}; do
            echo $i;
        done
    done <<< $(echo $str);
}

# $function fun() { str="ab:cd:ef"; while IFS=":" read -r -a arr; do for i in "${arr[@]}"; do echo $i; done; done <<< $(echo $str); } && fun
# ab
# cd
# ef

### nameing_check_OK
## @/* + [\w\d,._]+ 와 같은 형태 가능함

# function @1() {} && type @1
# function @a() {} && type @a
# function @_() {} && type @_
# function @,() {} && type @,
# function @.() {} && type @.

### nameing_check_Error
## @/* 로 function name 끝나면 안된다.

# function 1@() {} && type 1@
# function a@() {} && type a@
# function _@() {} && type _@
# function ,@() {} && type ,@
# function .@() {} && type .@

#####################

# $var=abcdef && [[ $var == *'cd'* ]] && echo 1 || echo 2
# 1

# $var=abcdef && echo $var | grep -oP 'cd' && echo 1 || echo 2
# cd
# 1

# $var=abcdef && echo $var | grep -oPq 'cd' && echo 1 || echo 2
# 1

function IsSubStr() {
    arg_fullStr="$1"
    arg_subStr="$2"

    echo "$arg_fullStr" | grep -oPq '$arg_subStr'
    return $?
}

function GetCurrentPath() {
    if [[ $OSTYPE == "linux-gnu" || $OSTYPE == "linux" ]]; then
        baseDir=$(realpath .)
    else # msys
        baseDir=$(cygpath --windows $(realpath .))
    fi
}

function GetCurrentPath_real() {
    baseDir=$(realpath .)
}

function GetCurrentPath_unix() {
    baseDir=$(cygpath --unix $(realpath .))
}

function GetCurrentPath_windows() {
   baseDir=$(cygpath --windows $(realpath .))
}

function GetReturnVal() {
    arg_info="$@"
    return $arg_info
}

function RunGetReturnVal() {
    for var in $(seq 0 257) ; do  # [0, 255] 사이를 순환
        GetReturnVal $var         # 256 -> return 0
        echo $?                   # 257 -> return 1
    done
}

function getOsPath() {
    arg_info="$@"

    if [[ $OSTYPE == "linux-gnu" || $OSTYPE == "linux" ]]; then
        osPathOutput=$(realpath $arg_info)
    else # msys
        osPathOutput=$(cygpath --windows $(realpath $arg_info))
    fi
}

function getEvenSize() {
    argSize="$@"
    halfSize=$((argSize / 2))
    evenSize=$((halfSize * 2))
}

function getHalfSize() {
    argSize="$@"
    halfSize=$((argSize / 2))
}

function getHalfEvenSize() {
    argSize="$@"
    getHalfSize $argSize
    getEvenSize $halfSize
}

function seq_Last() {
    for y in $(seq 10); do
        echo $y
    done
}

function seq_First_Last() {
    for y in $(seq 1 10); do
        echo $y
    done
}

function seq_First_Increment_Last() {
    for y in $(seq 1 10 100); do
        echo $y
    done
}

function checkModular() {
    arg_info="$@"
    for y in $(seq 32 2 50); do
        [[ $((y % 32)) -eq 0 ]] && LogInfo Multiple of 32
    done
}

function arithmetic() {
    arg_info="$@"
    out=$((arg_info + 32))
    out=$((arg_info - 32))
    out=$((arg_info * 32))
    out=$((arg_info % 32))
    out=$((arg_info / 32))
    out=$((--arg_info))
}

function printGitLsFiles() {
    for arg in $(git ls-files *.txt); do
        echo $arg
    done
}

function diff_files() {
    dir_1="$1"
    dir_2="$2"
    for arg in $(git ls-files *.txt); do
        diff --brief --recursive --strip-trailing-cr --exclude=*.cde $dir_1/$arg $dir_2/$arg
    done
}

function diff_files_error() {
    dir_1="$1"
    dir_2="$2"
    error=0
    for arg in $(git ls-files *.txt); do
        diff --brief --recursive --strip-trailing-cr --exclude=*.cde $dir_1/$arg $dir_2/$arg > /dev/null 2>&1
        [[ $? != 0 ]] && ((error++))
    done

    [[ $error == 0 ]] && exit 0 || echo; exit 1
}

function diff_directory() {
    dir_1="$1"
    dir_2="$2"
    diff --brief --recursive --strip-trailing-cr --exclude=*.cde $dir_1 $dir_2
}

function RunCmdFromVarString_0() {
    cmd=ls
    eval $cmd
}

function RunCmdFromVarString_1() {
    cmd=ls
    $cmd
}

function RunCmdFromVarString_2() {
    cmd=ls
    exec $cmd  # 현재 쉘이 'ls'로 대체 : 실행 후 바로 종료
    $cmd       # 실행되지 않음
}

function RunCmdFromVarString_3() {
    cmd=ls
    (exec $cmd)  # 별도의 하위 Process 실행으로 다른 Line 실행 가능
    $cmd         # 실행
}

function RunCmdFromVarString_Ex() {
    cmd='echo str="[1 2 3]"'
    $cmd                                        # str="[1 2 3]"
    eval $(echo ${cmd})                         # str=[1 2 3]
    eval $(echo ${cmd} | xargs --delimiter=" ") # str=[1 2 3]
}

function checkStringPrefixMatch() {
    str=ABC1
    [[ $str =~ AB ]] && echo PrefixMatch || echo NoPrefixMatch
    [[ $str == AB ]] && echo ExactMatch || echo NoExactMatch
}

function bashRegExpression() {
    str=ABC1
    [[ $str =~ AB ]] && echo 1
    [[ $str =~ ^AB ]] && echo 1
    # [[ $str =~ "^AB" ]] && echo 1 # RegEx에서는 "" 없어야지 정상 작동
}

function echoGrouping() {
    echo Test && (echo 1 && echo 2) || (echo 10 && echo 20)
    ls NoExist && (echo 1 && echo 2) || (echo 10 && echo 20)
}

function awk_multiple_delimiters() {
    git diff . | grep rewind | awk -F'[. ]' '{ print $5 }'
}

function awk_print_multiple_token_byComma() {
    git diff . | grep rewind | awk -F'[. ]' '{ print $3, $5 }'
}

function rm_groups_txt() {
    rm -f "test/*.{hex,txt,bin,dat}"
}

function rm_groups() {
    arg_info="$@"
    rm -f "test/*.{$arg_info}"
}

function OS_HOST() {
    env | grep "HOST=VWP" && echo VWP || echo ETC
}

function redirection_stderr_stdout() {
    echo text > out.txt 2>&1
    # 2(stderr) 도 1(stdout) 으로 전달하라는 의미
}

function redirection_stderr() {
    echo text 2> out.txt
    # 2(stderr) 도 1(stdout) 으로 전달하라는 의미
}

function redirection_stdout() {
    echo text > out.txt
    # 2(stderr) 도 1(stdout) 으로 전달하라는 의미
}

# /////////////////////////////////////////////////////////////////////////////// [End] Common Setting

CB_arg_1=$1
# -eq : only number / string error
# == !=  : string/number
if [[ "$CB_arg_1" == "script" ]]; then
    shift
    CB_arg_all="$@"
    $CB_arg_all
fi
