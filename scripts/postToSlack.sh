#!/usr/bin/env bash

function usage {
    programName=$0
    echo "description: use this program to post messages to Slack channel"
    echo "usage: $programName [-t \"sample title\"] [-b \"message body\"] [-c \"mychannel\"] [-u \"slack url\"]"
    echo "	-t    the title of the message you are posting"
    echo "	-b    The message body"
    echo "	-c    The channel you are posting to"
    echo "	-s    The color of the message: good|warning|danger"
    echo "	-u    The slack hook url to post to"
    exit 1
}
msgColor="good"
while getopts ":s:t:b:c:u:h" opt; do
    case ${opt} in
    s) msgColor="$OPTARG"
    ;;
    t) msgTitle="$OPTARG"
    ;;
    u) slackUrl="$OPTARG"
    ;;
    b) msgBody="$OPTARG"
    ;;
    c) channelName="$OPTARG"
    ;;
    h) usage
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [[ ! "${msgTitle}" ||  ! "${slackUrl}" || ! "${msgBody}" || ! "${channelName}" ]]; then
    echo "all arguments are required"
    usage
fi

payLoad="{\"channel\": \"#${channelName}\",
        \"username\": \"$(hostname)\",
        \"icon_emoji\": \":sunglasses:\",
        \"attachments\": [
            {
                \"fallback\": \"${msgTitle}\",
                \"color\": \"${msgColor}\",
                \"title\": \"${msgTitle}\",
                \"fields\": [{
                    \"value\": \"${msgBody}\",
                    \"short\": false
                }]
            }
        ]
    }"


statusCode=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${payLoad}" ${slackUrl})

echo ${statusCode}
