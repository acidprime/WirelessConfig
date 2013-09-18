#!/bin/bash
#set -x
declare -x awk="/usr/bin/awk"
declare -x chown="/usr/sbin/chown"
declare -x git="/usr/local/git/bin/git"
declare -x mv="/bin/mv"
declare -x mkdir="/bin/mkdir"
declare -x xcodebuild="/usr/bin/xcodebuild"
declare -x pkgbuild="/usr/bin/pkgbuild"

declare -x SCRIPT="${0##*/}" ; SCRIPT_NAME="${Script%%\.*}"
declare -x SCRIPT_PATH="$0" RUN_DIRECTORY="${0%/*}"

declare -x PROJECT_NAME="PasswordUtility"
declare -x PACKAGE_NAME="util_passwordUtility"
declare -x COMMIT="$(cd "$RUN_DIRECTORY"; $git log | $awk '/commit/{print substr($2,1,10);exit}')"
declare -x PACKAGE_IDENT="com.github.wirelessconfig.passwordutility.$COMMIT"

declare -x TMP_PATH="/private/tmp/$PROJECT_NAME-$$$RANDOM"
declare -x TARGET_APP="$RUN_DIRECTORY/build/Release/$PROJECT_NAME.app"
declare -x INSTALL_SUFFIX="/Applications/Utilities"

$mkdir -p "$TMP_PATH/$INSTALL_SUFFIX"
$xcodebuild -project "$RUN_DIRECTORY/PasswordUtility/PasswordUtility.xcodeproj" clean build
$xcodebuild -project "$RUN_DIRECTORY/PasswordUtilityWrapper/PasswordUtility/PasswordUtility.xcodeproj" clean build

$mv -v "$RUN_DIRECTORY/PasswordUtilityWrapper/PasswordUtility/build/Release/PasswordUtility.app" "$TMP_PATH/$INSTALL_SUFFIX/"
$mv -v "$RUN_DIRECTORY/PasswordUtility/build/Release/PasswordUtility.app" "$TMP_PATH/$INSTALL_SUFFIX/PasswordUtility.app/Contents/Resources/"

$chown -Rv acid "$RUN_DIRECTORY"
$chown -Rv 0:0 "$TMP_PATH/$INSTALL_SUFFIX/"

$pkgbuild --identifier "$PACKAGE_IDENT" \
--root "$TMP_PATH/" \
--scripts "$RUN_DIRECTORY/pkg_build/${PACKAGE_NAME}_scripts" \
"$RUN_DIRECTORY/pkg_build/${PACKAGE_NAME}_$COMMIT.pkg"
