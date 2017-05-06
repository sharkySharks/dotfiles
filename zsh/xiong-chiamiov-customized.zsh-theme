# customized from the original with the name of the file, I have changed colors,
# changed the time output, added a zsh emoji, and made some other aesthetic changes
# main items of the prompt: user, host, full path, and time/date on two lines for easier vgrepping
# entry in a nice long thread on the Arch Linux forums: http://bbs.archlinux.org/viewtopic.php?pid=521888#p521888

PROMPT=$'%{\e[0;34m%}%B┌─[%b%{\e[0m%}%{\e[1;32m%}%n%{\e[1;30m%}@%{\e[0m%}%{\e[0;36m%}%m%{\e[0;34m%}%B]%b%{\e[0m%} - %b%{\e[0;34m%}%B[%b%{\e[1;30m%}%~%{\e[0;34m%}%B]%b%{\e[0m%} - %{\e[0;34m%}%B[%b%{\e[0;33m%}'%D{"%m.%d.%y|%H:%M:%S"}%b$'%{\e[0;34m%}%B]%b%{\e[0m%}
%{\e[0;34m%}%B└─%B$(echo $emoji[rocket])  $(git_prompt_info)%{\e[0m%}%b '
PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '
