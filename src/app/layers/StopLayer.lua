--
-- Author: Your Name
-- Date: 2016-09-30 14:46:41
--
-- 游戏暂停弹出框
--rest

local StopLayer = class("StopLayer",function()
    return display.newLayer()
end)

function StopLayer:ctor(params)

	-- 背景填充
	local layer = display.newColorLayer(cc.c4b(96,96,96,180))
	self:addChild(layer)

	-- 文字
	self.mLabel = display.newTTFLabel({
		    text = "Have a rest",
		    font = "Arial",
		    size = 60,
		    color = cc.c3b(255,255,255), 
		})
	self.mLabel:setPosition(cc.p(display.cx, display.cy + 100))
	self:addChild(self.mLabel,10)
	self.mLabel:setOpacity(0)

	-- home 按钮
	self.mHomeBtn = UIHelper.createButton({
		normal    = "image/home.png",
        pressed   = "image/home_1.png",  
        buttonClick = function ()
        	UIHelper.goHomeAlert()
        end
	})
	self.mHomeBtn:setAnchorPoint(cc.p(1.0, 1.0))
	self.mHomeBtn:setPosition(cc.p(display.cx - 30 - 1000, display.cy))
	self:addChild(self.mHomeBtn)

	-- play按钮
	self.mPlayBtn = UIHelper.createButton({
		normal    = "image/start.png",
        pressed   = "image/start_1.png",  
        buttonClick = function ()
        	self:clickPlay()
        end
	})
	self.mPlayBtn:setScale(0.55)
	self.mPlayBtn:setAnchorPoint(cc.p(0.0, 1.0))
	self.mPlayBtn:setPosition(cc.p(display.cx + 30 + 1000, display.cy))
	self:addChild(self.mPlayBtn)

	self.mPlayBtn:runAction(cc.Sequence:create(cc.EaseElasticOut:create(cc.MoveBy:create(0.5, cc.p(-1000, 0)),1.0)))
	self.mHomeBtn:runAction(cc.Sequence:create(cc.EaseElasticOut:create(cc.MoveBy:create(0.5, cc.p(1000, 0)),1.0)))
	self.mLabel:runAction(cc.FadeIn:create(0.9))
end

-- -- 调用本地对话框，回到home
-- function StopLayer:returnHome()
	
-- 	NativeHelper.showAlert("Confirm Exit", "Are you sure want to go home?", function (event)
-- 		-- 显示广告 回到home
--         NativeHelper:showInterstitialAd()
--         display.replaceScene(require("app.scenes.HomeScene").new(), "crossFade" , 0.5)
--     end)

-- end


function StopLayer:clickPlay()
	
	self.mPlayBtn:runAction(cc.Sequence:create(cc.EaseElasticIn:create(cc.MoveBy:create(0.5, cc.p(1000, 0)),1.0)))
	self.mHomeBtn:runAction(cc.Sequence:create(cc.EaseElasticIn:create(cc.MoveBy:create(0.5, cc.p(-1000, 0)),1.0)))
	self.mLabel:runAction(cc.Sequence:create(cc.FadeOut:create(1.0),cc.CallFunc:create(function ()
		self:removeFromParent()
	end)))

end

return StopLayer