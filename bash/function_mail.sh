#!/bin/bash
# function_mail.sh

function mailbash() {
    # To Address
    declare vToAddress="${1:?'$1: Set e-mail address as "TO: "'}"
    egrep -q "[0-9a-zA-Z_\-\.]+@[0-9a-zA-Z_\-\.]+" <<<"${vToAddress}" || { echo '$1: Not a valid RFC-5321 address'; return 1; }
    declare vSubject="${2:?'$2: Set subject as "Subject: "'}"
    declare vBody="${3:?'$3: Set message content as "Body"'}"
    # SMTP-AUTH
    declare vSmtpPort="587"
    # Gmail https://myaccount.google.com/lesssecureapps
    declare vSmtpHost="smtp.gmail.com"
    declare vSmtpAuth="PLAIN"
    declare vSmtpUser="XXXXXXXX@gmail.com"
    declare vSmtpPass="XXXXXXXX"
    # Outlook.com
    #declare vSmtpHost="smtp-mail.outlook.com"
    #declare vSmtpAuth="LOGIN"
    #declare vSmtpUser="XXXXXXXX@outlook.com"
    #declare vSmtpPass="XXXXXXXX"
    # Office365
    #declare vSmtpHost="smtp.office365.com"
    #declare vSmtpAuth="LOGIN"
    #declare vSmtpUser="XXXXXXXX@XXXXXXXX.com"
    #declare vSmtpPass="XXXXXXXX"
    # function
    function _smtp_stdout() {
        sleep 2.5
        echo "EHLO $(uname -n)"
        sleep 1.5
        if [[ ${vSmtpAuth:?} == LOGIN ]]
        then
            echo "AUTH LOGIN"
            echo "$(printf "${vSmtpUser:?}" | openssl enc -e -base64)"
            echo "$(printf "${vSmtpPass:?}" | openssl enc -e -base64)"
            sleep 4.5
        elif [[ ${vSmtpAuth:?} == PLAIN ]]
        then
            echo "AUTH PLAIN $(printf "%s\0%s\0%s" "${vSmtpUser:?}" "${vSmtpUser:?}" "${vSmtpPass:?}" | openssl enc -e -base64 | tr -d '\n')"
            sleep 2.5
        else
            echo "${vSmtpAuth:?} not supported" 1>&2
            echo "QUIT"
        fi
        echo "MAIL FROM: <${vSmtpUser:?}>"
        sleep 1.5
        echo "RCPT TO: <${vToAddress:?}>"
        sleep 1.5
        echo "DATA"
        sleep 1.5
        # Mail Header
        echo "From: send-only <${vSmtpUser:?}>"
        echo "To: ${vToAddress:?}"
        echo "Subject: ${vSubject:?}"
        echo ""
        # Body
        echo "${vBody:?}"
        echo ""
        echo "--"
        echo "This message was sent at $(date -Is)."
        echo "."
        sleep 2.5
        echo "QUIT"
    }
    # main
    (_smtp_stdout | openssl s_client -connect ${vSmtpHost:?}:${vSmtpPort:?} -starttls smtp -crlf -ign_eof) #>> /tmp/mail_smtp_stdout_$(date +%Y%m%d).log 2>&1
}
#EOF
