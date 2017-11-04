#!/bin/bash
# aws_sg_update.sh
#
# */2 * * * * PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/local/bin/aws_sg_update.sh >> /tmp/aws_sg_update_$(date +\%Y\%m\%d).log 2>&1
#
# aws ec2 describe-security-groups | jq -r .SecurityGroups[].GroupId
# aws ec2 describe-security-groups --group-id sg-xxxxxxxx
#
. /usr/local/bin/function_mail.sh
#
declare vGroupId="sg-xxxxxxxx"
declare vCurrentIp="$(curl -LRsS --connect-timeout 10 http://checkip.amazonaws.com/ | \egrep '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')"
declare vFile="${HOME:?}/${vGroupId}"
declare -i i=0
#
if [[ "$(< ${vFile})" != "${vCurrentIp:?}" ]]
then
    #
    if [[ -f ${vFile} ]]
    then
        #aws ec2 revoke-security-group-ingress --group-id ${vGroupId} --protocol tcp --port 22 --cidr $(< ${vFile})/32
        aws ec2 revoke-security-group-ingress --group-id ${vGroupId} \
            --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
    fi
    #
    printf "${vCurrentIp}" > "${vFile}"
    #aws ec2 authorize-security-group-ingress --group-id ${vGroupId} --protocol tcp --port 22 --cidr $(< ${vFile})/32
    while (! (aws ec2 describe-security-groups --group-id ${vGroupId} | \grep --quiet $(< ${vFile})))
    do
        aws ec2 authorize-security-group-ingress --group-id ${vGroupId} \
            --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
        i=$((i+1))
        sleep 10
        if [[ $i -gt 3 ]]
        then
            mailbash koginoadm@outlook.com "[AWS][SG][d1.djeeno.net] Failed to update IP Address." \
                '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
            break
        fi
    done
    mailbash koginoadm@outlook.com "[AWS][SG][d1.djeeno.net] IP Address was updated." \
        '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
fi
#

