#!/bin/sh

deleteLocalTag() {
	command="git tag -d $1"
	echo "Executing ---- ${command}"
	eval "$command"
}

deleteRemoteTag() {
	command="git push --delete origin $1"
	echo "Executing ---- ${command}"
	eval "$command"
	deleteLocalTag $1
}

createLocalTag() {
	command="git tag $1"
	echo "Executing ---- ${command}"
	eval "$command"
}

createRemoteTag() {
	command="git push origin $1"
	echo "Executing ---- ${command}"
	eval "$command"
	if [ $? -eq 0 ]; then
		echo "Tag created remotely"
	else
		echo "Failed to create tag remotely"
		deleteLocalTag $1
	fi
}

podLibLint() {
	command="pod lib lint $1 --allow-warnings --verbose"
	echo "Executing ---- ${command}"
	eval "$command"
}

podTrunkPush() {
	command="pod trunk push $1 --allow-warnings --verbose"
	echo "Executing ---- ${command}"
	eval "$command"
	if [ $? -eq 0 ]; then
		echo "Pod trunk successfully"
	else
		echo "Pod trunk failed"
		deleteRemoteTag $2
	fi
}

podName="PayUIndia-PG-SDK"
podVersion="8.5.0"

podSpec="${podName}.podspec"
tag="${podVersion}"

podLibLint ${podSpec} &&
createLocalTag ${tag} &&
createRemoteTag ${tag} &&
podTrunkPush ${podSpec} ${tag}

