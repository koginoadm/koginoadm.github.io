#!/bin/bash -e
# aws-sg.sh
# aws ec2 describe-security-groups | jq -r .SecurityGroups[].GroupId
# aws ec2 describe-security-groups --group-id sg-xxxxxxxx
#
vCurrentIp="$(curl -LRsS http://checkip.amazonaws.com/ | \egrep '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')"
vGroupId="sg-xxxxxxxx"
vFile="${HOME:?}/${vGroupId}"
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
    echo "${vCurrentIp}" > "${vFile}"
    #aws ec2 authorize-security-group-ingress --group-id ${vGroupId} --protocol tcp --port 22 --cidr $(< ${vFile})/32
    aws ec2 authorize-security-group-ingress --group-id ${vGroupId} --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'"$(< ${vFile})"'/32", "Description": "d1.djeeno.net"}]}]'
fi
