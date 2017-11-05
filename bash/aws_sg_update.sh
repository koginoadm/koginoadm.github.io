#!/bin/bash
# aws_sg_update.sh
#
# */2 * * * * PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/local/bin/aws_sg_update.sh >> /tmp/aws_sg_update_$(date +\%Y\%m\%d).log 2>&1
#
# aws ec2 describe-security-groups | jq -r .SecurityGroups[].GroupId
# aws ec2 describe-security-groups --group-id sg-xxxxxxxx
#
declare vGroupId="sg-xxxxxxxx"
declare vCurrentIp="$(curl -LRsS --connect-timeout 10 http://checkip.amazonaws.com/ | \egrep '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')"
declare vFile="${HOME:?}/${vGroupId}"
declare -i i=0
#
. /usr/local/bin/function_mail.sh
#
if [[ "$(< ${vFile})" != "${vCurrentIp:?}" ]]
then
    #
    date -Is
    #
    if [[ -f ${vFile} ]]
    then
        aws ec2 revoke-security-group-ingress --group-id ${vGroupId} --protocol tcp --port 22 --cidr $(< ${vFile})/32
    fi
    #
    printf "${vCurrentIp}" > "${vFile}"
    while (! (aws ec2 describe-security-groups --group-id ${vGroupId} | \grep --quiet "$(< ${vFile})"))
    do
        aws ec2 authorize-security-group-ingress --group-id ${vGroupId} \
            --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "Dynamic"}]}]'
        i=$((i+1))
        sleep 10
        if [[ $i -gt 3 ]]
        then
            mailbash koginoadm@outlook.com "[AWS][SG][Dynamic] !!! Failed to update SecurityGroups !!!" \
                "$(
                    echo 'Failed to update Rule:'
                    echo '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "Dynamic"}]}]'
                    echo ""
                    echo "--"
                    aws ec2 describe-security-groups --group-id ${vGroupId:?}
                )"
            break
        fi
    done
    mailbash koginoadm@outlook.com "[AWS][SG][Dynamic] SecurityGroups updated" \
        "$(
            echo 'Rule updated:'
            echo '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "Dynamic"}]}]'
            echo ""
            echo "--"
            aws ec2 describe-security-groups --group-id ${vGroupId:?}
        )"
fi
#

