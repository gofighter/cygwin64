### Cygwin에서는 /bin/bash와 /usr/bin/bash는 동일하게 배포
: /bin/bash 만 있고 /usr/bin/bash 는 실제 없지만 모두 사용 가능함

$ ls -l /bin/bash /usr/bin/bash
-rwxr-xr-x 2 jaeho Administrators 854035 2024년  1월 23일 /bin/bash
-rwxr-xr-x 2 jaeho Administrators 854035 2024년  1월 23일 /usr/bin/bash

$ which bash
/usr/bin/bash

$ /usr/bin/bash --version
$ /bin/bash --version
GNU bash, 버전 5.2.21(1)-release (x86_64-pc-cygwin)

$ cmp /bin/bash /usr/bin/bash && echo success
success

### 하기 실행 결과 동일
/usr/bin/ln.exe
/bin/ln.exe

==> ln 만 입력하면 git window 의 ln 과 PATH 이슈가 있으므로 PATH 설정 후 실행하는 습관이 좋겠다.
# /etc/profile
```
PATH="/usr/local/bin:/usr/bin${PATH:+:${PATH}}"
=>
/usr/bin 설정해서 무엇보다 cygwin terminal 환경에서는 /usr/bin/ln.exe 검색하라는 의미
```

PATH="/usr/local/bin:/usr/bin${PATH:+:${PATH}}" → 기존 PATH가 있으면 콜론 붙이고, 없으면 아예 덧붙이지 않아 깔끔함 → 추천되는 방식

PATH="/usr/local/bin:/usr/bin:${PATH:+:${PATH}}" → /usr/bin 뒤에 콜론이 무조건 있어, 기존 PATH 없을 때 끝에 콜론 생김 → 권장하지 않음

🔹 ${PATH:+:${PATH}} : parameter substitution
PATH가 비어 있지 않다면 :${PATH}로 확장한다.
PATH가 비어 있다면 아무 것도 출력하지 않는다.

## with PATH="/usr/bin${PATH:+:${PATH}}"
```All Pass
%CYG.B%bash.exe -c "/usr/bin/ln -s /bin/!target! /usr/local/bin/!target!"
%CYG.B%bash.exe -c "ln -s /bin/!target! /usr/local/bin/!target!"
```

## without PATH="/usr/bin${PATH:+:${PATH}}"
```Pass
%CYG.B%bash.exe -c "/usr/bin/ln -s /bin/!target! /usr/local/bin/!target!"
```
```Fail
%CYG.B%bash.exe -c "ln -s /bin/!target! /usr/local/bin/!target!"
```

### PATH
D:\02_sw\cygwin64
D:\02_sw\cygwin64\sbin
D:\02_sw\cygwin64\bin
D:\02_sw\cygwin64\usr\sbin
D:\02_sw\cygwin64\usr\local\bin

### New ENV Var
- CYG
D:\02_sw\cygwin64\

- CYG.SB
D:\02_sw\cygwin64\sbin\

- CYG.B
D:\02_sw\cygwin64\bin\

- CYG.ULB
D:\02_sw\cygwin64\usr\local\bin\

- CYG.USB
D:\02_sw\cygwin64\usr\sbin\

###
>%CYG%bin\ln --version
ln (GNU coreutils) 9.0

>%CYG.B%ln --version
ln (GNU coreutils) 9.0

### Cygwin64 Terminal
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Cygwin\Cygwin64 Terminal
```
Cygwin_Mintty_Home.bat 저장하면
D:\02_sw\cygwin64\Cygwin_Mintty_Home.bat 저장됨
```

### umask 022 -> umask 077
```
$ umask
0022

jaeho@jaeho /
$ mkdir AA

jaeho@jaeho /
$ ls -l
drwxr-xr-x 1 jaeho jaeho               0  8월  6일 01:20 AA

==>

jaeho@jaeho /
$ umask
0077

jaeho@jaeho /
$ mkdir AB

jaeho@jaeho /
$ ls -l
drwxr-xr-x 1 jaeho jaeho               0  8월  6일 01:20 AA
drwx------ 1 jaeho jaeho               0  8월  6일 01:21 AB
```

### bash --login -i
echo $-                               # himBH
: --login 옵션있다면 .bash_profile 실행
: --login 없다면 home directory 이동 과정 실행
: -i 옵션있다면 .bashrc 실행

### bash -i
echo $-                               # himBH
: --login 없어도 $- 결과는 동일
: --login 없다면 .bash_profile 실행 X
: --login 없다면 home directory 이동 과정 없음
: -i 옵션있다면 .bashrc 실행

### bash --login -i -c "some command"
echo $-                               # himBHc

################# cygwin version program 설치 여부 확인 및 perl 설치
```
[jaeho@/](develop)$which grep
/usr/bin/grep
[jaeho@/](develop)$which sed
/usr/bin/sed
[jaeho@/](develop)$which awk
/usr/bin/awk
[jaeho@/](develop)$which perl
/cygdrive/c/Program Files/Git/usr/bin/perl
[jaeho@/](develop)$ 
=>
[jaeho@/](develop)$which grep
/usr/bin/grep
[jaeho@/](develop)$which sed
/usr/bin/sed
[jaeho@/](develop)$which awk
/usr/bin/awk
[jaeho@/](develop)$which perl
/cygdrive/c/Program Files/Git/usr/bin/perl
[jaeho@/](develop)$which perl
/usr/bin/perl
```
