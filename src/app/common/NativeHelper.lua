
-- 安卓本地辅助类

NativeHelper = {}


--[[
	调用安卓本地类，显示原生对话框
	默认按两个按钮 OK  Cancle
	title   : 标题
	message : 内容
	listener    : 回调，仅有OK按钮的回调
]]
function NativeHelper.showAlert(title, message, listener)
	-- body
	local javaClassName = "org/cocos2dx/lua/AppActivity"
	local javaMethodName = "showAlertDialog"
	local javaParams = {
	    title,
	    message,
	    listener,
	}
	local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;I)V"
	luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig) 
end

-- 显示banner
function NativeHelper:showBanner()
	local javaClassName = "org/cocos2dx/lua/AppActivity"
	local javaMethodName = "showAd"
	local javaParams = {
	    title,
	    message,
	    listener,
	}
	local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;I)V"
	luaj.callStaticMethod(javaClassName, javaMethodName) 
end

-- 隐藏banner
function NativeHelper:hideBanner()
	local javaClassName = "org/cocos2dx/lua/AppActivity"
	local javaMethodName = "hideAd"
	local javaParams = {
	    title,
	    message,
	    listener,
	}
	local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;I)V"
	luaj.callStaticMethod(javaClassName, javaMethodName) 
end

-- 显示全屏
function NativeHelper:showInterstitialAd()
	local javaClassName = "org/cocos2dx/lua/AppActivity"
	local javaMethodName = "showInterstitialAd"
	local javaParams = {
	    title,
	    message,
	    listener,
	}
	local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;I)V"
	luaj.callStaticMethod(javaClassName, javaMethodName) 

end

-- 显示Toast消息
-- message 消息内容
function NativeHelper:showToast(message)

	if ShowToast == false then
		return
	end

	local javaClassName = "org/cocos2dx/lua/AppActivity"
	local javaMethodName = "showToast"
	local javaParams = {
	    message,
	}
	-- local javaMethodSig = "(Ljava/lang/String)V"
	luaj.callStaticMethod(javaClassName, javaMethodName, javaParams) 

end


















