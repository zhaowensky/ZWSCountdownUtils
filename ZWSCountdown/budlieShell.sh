# 工程名
APP_NAME="ZWSCountdown"

# 证书
CODE_SIGN_DISTRIBUTION="iPhone Distribution: Guangzhou Yunkang Information Technology Co., Ltd."
# info.plist路径
project_infoplist_path="./${APP_NAME}/Info.plist"

#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")
DATE="$(date +%Y%m%d)"
IPANAME="${APP_NAME}_V${bundleShortVersion}_${DATE}.ipa"

#要上传的ipa文件路径
IPA_PATH="$HOME/${IPANAME}"
echo ${IPA_PATH}
#echo "${IPA_PATH}">> text.txt

#下面2行是没有Cocopods的用法
echo "=================clean================="
xcodebuild -target "${APP_NAME}"  -configuration 'Release' clean
#xcodebuild -project "${APP_NAME}/${APP_NAME}.xcodeproj"  -configuration 'Release' cl
echo "+++++++++++++++++build+++++++++++++++++"
xcodebuild -target "${APP_NAME}" -sdk iphoneos -configuration 'Release' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)'
#xcodebuild -project "${APP_NAME}/${APP_NAME}.xcodeproj" -sdk iphoneos -configuration 'Release' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)'

#下面2行是集成有Cocopods的用法
#echo "=================clean================="
#xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}"  -configuration 'Release' clean
#echo "+++++++++++++++++build+++++++++++++++++"
#xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}" -sdk iphoneos -configuration 'Release' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)'

#上传脚本
curl -F ${IPA_PATH} -F "uKey=8a72c2a7b20f11ca2459ae5f42d2191c" -F "_api_key=24d5536d2a82bf02c7c2d1adccb3da9d" https://qiniu-storage.pgyer.com/apiv1/app/upload


#调用
#cd ${JENKINS_HOME}/workspace/ZWSCountdown/ZWSCountdown
#sh budlieShell.sh
