#!/bin/bash
# aws_sg_update.sh
#
# aws ec2 describe-security-groups | jq -r .SecurityGroups[].GroupId
# aws ec2 describe-security-groups --group-id sg-xxxxxxxx
#
. /usr/local/bin/function_mail.sh
#
declare vGroupId="sg-xxxxxxxx"
declare vCurrentIp="$(curl -LRsS --connect-timeout 10 http://checkip.amazonaws.com/ | \egrep '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')"
declare vFile="${HOME:?}/${vGroupId}"
#
if [[ "$(< ${vFile})" != "${vCurrentIp:?}" ]]
then
    #
    if [[ -f ${vFile} ]]
    then
        #aws ec2 revoke-security-group-ingress --group-id ${vGroupId} --protocol tcp --port 22 --cidr $(< ${vFile})/32
        aws ec2 revoke-security-group-ingress --group-id ${vGroupId} --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
    fi
    #
    printf "${vCurrentIp}" > "${vFile}"
    #aws ec2 authorize-security-group-ingress --group-id ${vGroupId} --protocol tcp --port 22 --cidr $(< ${vFile})/32
    aws ec2 authorize-security-group-ingress --group-id ${vGroupId} --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
    mailbash koginoadm@outlook.com "[AWS][SG][d1.djeeno.net] IP Address was changed." '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
fi

