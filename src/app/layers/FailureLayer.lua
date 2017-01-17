--
-- Author: Your Name
-- Date: 2016-10-08 10:54:09
--
-- 失败界面


local AddDiamondLayer = require("app.layers.AddDiamondLayer")

local FailureLayer = class("FailureLayer",function()
    return display.newLayer()
end)

function FailureLayer:ctor(params)

	-- 背景填充
	local layer = display.newColorLayer(cc.c4b(96,96,96,180))
	self:addChild(layer)

	-- 背景
	self.mBgSprite = UIHelper.createSprite("image/failBg.png")
	self.mBgSprite:setPosition(cc.p(display.cx, display.cy))
	self:addChild(self.mBgSprite)
	self.mBgSprite:setScale(0)

	-- 复活按钮
	local reviceBtn = UIHelper.createButton({
		normal    = "image/btn_revive.png",
        pressed   = "image/btn_revive_1.png",  
        buttonClick = function ()
        	
        	-- 砖石数量
        	local diamondNum = GameData:getInstance():getDiamonNum()
        	if diamondNum > 4 then
        		GameData:getInstance():diamondSub(5)
     			self:removeFromParent()
     			GameData:getInstance():reviveHp()
     			Notification:postNotification(EventsName.eHpChange)
     			Notification:postNotification(EventsName.eDiamondChange)
     		else
     			-- 弹出增加钻石
     			self:addChild(AddDiamondLayer.new(),110)
        	end

        end
	})
	reviceBtn:setPosition(cc.p(255, 353))
	self.mBgSprite:addChild(reviceBtn)

	reviceBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.JumpBy:create(1.0, cc.p(0, 0), 20, 2),
		cc.DelayTime:create(2.0)

	   )))

	--  失败按钮
	local failBtn = UIHelper.createButton({
		normal    = "image/btn_no.png", 
        buttonClick = function ()
        	self:removeFromParent()
        	-- 发送游戏结束的消息
        	Notification:postNotification(EventsName.eGameOver)
        end
	})
	failBtn:setScale(0.4)
	failBtn:setPosition(cc.p(255, 220))
	self.mBgSprite:addChild(failBtn)

	self.mBgSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2),cc.ScaleTo:create(0.1, 1.0)))
end

return FailureLayer






















