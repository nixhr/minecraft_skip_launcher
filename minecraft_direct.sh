#!/bin/bash

source $HOME/.mcdirectrc
eval "$(jq -r '@sh "offlineUuid=\(.selectedUser) username=\(.selectedProfile)"' < $HOME/.minecraft/launcher_profiles.json)"
offlineAccessToken="190fc99c03434de7a014e9cdd12b3122"
offlineUserType="legacy"


if ping -c 1 authserver.mojang.com &> /dev/null
then
	JSONREQ='{ "agent": {"name": "Minecraft", "version": 1 }, "username": "'${USERMAIL}'", "password": "'${PASSWORD}'" }'
	usertype="mojang"
	accessToken='null'
	retrySeconds=2
	while true 
	do
		echo $JSONREQ
		RESPONSE=$(curl -s -H "Content-Type: application/json" -X POST -d "$JSONREQ" https://authserver.mojang.com/authenticate)
		echo $RESPONSE
		eval "$(jq -r '@sh "accessToken=\(.accessToken) uuid=\(.selectedProfile.id)"' <<< $RESPONSE)"
		if [ "$accessToken" == "null" ]
		then
			sleep $retrySeconds
			retrySeconds=$(($retrySeconds * 2))
			if [ "$retrySeconds" -eq "16" ]
			then
				uuid=$offlineUuid
				accessToken=$offlineAccessToken
				userType=$offlineUserType
				break
			fi
		else
			break
		fi
	done
else
	uuid=$offlineUuid
	accessToken=$offlineAccessToken
	userType=$offlineUserType
fi
RUN="/usr/lib/jvm/java-8-oracle/jre/bin/java -Xmx1G -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:-UseAdaptiveSizePolicy -Xmn128M \
                                             -Djava.library.path=$HOME/.minecraft/versions/1.12.2/1.12.2-natives-static \
                                             -Dminecraft.launcher.brand=java-minecraft-launcher \
                                             -Dminecraft.launcher.version=1.6.84-j \
                                             -Dminecraft.client.jar=$HOME/.minecraft/versions/1.12.2/1.12.2.jar \
                                             -cp $HOME/.minecraft/libraries/com/mojang/patchy/1.1/patchy-1.1.jar:$HOME/.minecraft/libraries/oshi-project/oshi-core/1.1/oshi-core-1.1.jar:$HOME/.minecraft/libraries/net/java/dev/jna/jna/4.4.0/jna-4.4.0.jar:$HOME/.minecraft/libraries/net/java/dev/jna/platform/3.4.0/platform-3.4.0.jar:$HOME/.minecraft/libraries/com/ibm/icu/icu4j-core-mojang/51.2/icu4j-core-mojang-51.2.jar:$HOME/.minecraft/libraries/net/sf/jopt-simple/jopt-simple/5.0.3/jopt-simple-5.0.3.jar:$HOME/.minecraft/libraries/com/paulscode/codecjorbis/20101023/codecjorbis-20101023.jar:$HOME/.minecraft/libraries/com/paulscode/codecwav/20101023/codecwav-20101023.jar:$HOME/.minecraft/libraries/com/paulscode/libraryjavasound/20101123/libraryjavasound-20101123.jar:$HOME/.minecraft/libraries/com/paulscode/librarylwjglopenal/20100824/librarylwjglopenal-20100824.jar:$HOME/.minecraft/libraries/com/paulscode/soundsystem/20120107/soundsystem-20120107.jar:$HOME/.minecraft/libraries/io/netty/netty-all/4.1.9.Final/netty-all-4.1.9.Final.jar:$HOME/.minecraft/libraries/com/google/guava/guava/21.0/guava-21.0.jar:$HOME/.minecraft/libraries/org/apache/commons/commons-lang3/3.5/commons-lang3-3.5.jar:$HOME/.minecraft/libraries/commons-io/commons-io/2.5/commons-io-2.5.jar:$HOME/.minecraft/libraries/commons-codec/commons-codec/1.10/commons-codec-1.10.jar:$HOME/.minecraft/libraries/net/java/jinput/jinput/2.0.5/jinput-2.0.5.jar:$HOME/.minecraft/libraries/net/java/jutils/jutils/1.0.0/jutils-1.0.0.jar:$HOME/.minecraft/libraries/com/google/code/gson/gson/2.8.0/gson-2.8.0.jar:$HOME/.minecraft/libraries/com/mojang/authlib/1.5.25/authlib-1.5.25.jar:$HOME/.minecraft/libraries/com/mojang/realms/1.10.19/realms-1.10.19.jar:$HOME/.minecraft/libraries/org/apache/commons/commons-compress/1.8.1/commons-compress-1.8.1.jar:$HOME/.minecraft/libraries/org/apache/httpcomponents/httpclient/4.3.3/httpclient-4.3.3.jar:$HOME/.minecraft/libraries/commons-logging/commons-logging/1.1.3/commons-logging-1.1.3.jar:$HOME/.minecraft/libraries/org/apache/httpcomponents/httpcore/4.3.2/httpcore-4.3.2.jar:$HOME/.minecraft/libraries/it/unimi/dsi/fastutil/7.1.0/fastutil-7.1.0.jar:$HOME/.minecraft/libraries/org/apache/logging/log4j/log4j-api/2.8.1/log4j-api-2.8.1.jar:$HOME/.minecraft/libraries/org/apache/logging/log4j/log4j-core/2.8.1/log4j-core-2.8.1.jar:$HOME/.minecraft/libraries/org/lwjgl/lwjgl/lwjgl/2.9.4-nightly-20150209/lwjgl-2.9.4-nightly-20150209.jar:$HOME/.minecraft/libraries/org/lwjgl/lwjgl/lwjgl_util/2.9.4-nightly-20150209/lwjgl_util-2.9.4-nightly-20150209.jar:$HOME/.minecraft/libraries/com/mojang/text2speech/1.10.3/text2speech-1.10.3.jar:$HOME/.minecraft/versions/1.12.2/1.12.2.jar \
                                             net.minecraft.client.main.Main \
                                             --username ${username} \
                                             --version 1.12.2 \
                                             --gameDir $HOME/.minecraft \
                                             --assetsDir $HOME/.minecraft/assets \
                                             --assetIndex 1.12 \
                                             --uuid ${uuid} \
                                             --accessToken ${accessToken} \
                                             --userType ${userType} \
                                             --versionType release"
exec $RUN
