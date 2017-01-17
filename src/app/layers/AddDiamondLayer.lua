--
-- Author: Your Name
-- Date: 2016-10-08 15:47:35
--
-- 增加钻石按钮
-- 

local AddDiamondLayer = class("AddDiamondLayer",function()
    return display.newLayer()
end)

function AddDiamondLayer:ctor(params)
	-- 背景填充
	local layer = display.newColorLayer(cc.c4b(96,96,96,180))
	self:addChild(layer)

	-- 背景
	self.mBgSprite = UIHelper.createSprite("image/shopBoard.png")
	self.mBgSprite:setPosition(cc.p(display.cx, display.cy))
	self:addChild(self.mBgSprite)
	self.mBgSprite:setScale(0)

	-- 按钮
	local oneBtn = UIHelper.createButton({
		normal    = "image/btnBg.png",
        pressed   = "image/btnBg_1.png",  
        buttonClick = function ()
        	
        	-- 显示广告 回调
        	Notification:postNotification(EventsName.eDiamondChange)

        end
	})
	oneBtn:setPosition(cc.p(255, 323))
	self.mBgSprite:addChild(oneBtn)

	local diamond = UIHelper.createSprite("image/diamond.png")
	diamond:setPosition(cc.p(81 - 120, 55 - 50))
	oneBtn:addChild(diamond)

	local num = display.newTTFLabel({
		    text = string.format(" × 5",rand),
		    font = "Arial",
		    size = 60,
		    color = cc.c3b(255,255,255), 
		})
	num:setPosition(cc.p(175 - 150, 55 - 50))
	oneBtn:addChild(num)

	-- 按钮
	local twoBtn = UIHelper.createButton({
		normal    = "image/btnBg.png",
        pressed   = "image/btnBg_1.png",  
        buttonClick = function ()
        	
        	-- 显示广告 回调
        	Notification:postNotification(EventsName.eDiamondChange)

        end
	})
	twoBtn:setPosition(cc.p(255, 190))
	self.mBgSprite:addChild(twoBtn)

	local diamond = UIHelper.createSprite("image/diamond.png")
	diamond:setPosition(cc.p(81 - 120, 55 - 50))
	twoBtn:addChild(diamond)

	local num = display.newTTFLabel({
		    text = string.format(" × 10",rand),
		    font = "Arial",
		    size = 60,
		    color = cc.c3b(255,255,255), 
		})
	num:setPosition(cc.p(175 - 130, 55 - 50))
	twoBtn:addChild(num)

	--  失败按钮
	local failBtn = UIHelper.createButton({
		normal    = "image/btn_no.png", 
        buttonClick = function ()
        	self:removeFromParent()
        end
	})
	failBtn:setScale(0.3)
	failBtn:setPosition(cc.p(255, 80))
	self.mBgSprite:addChild(failBtn)

	self.mBgSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2),cc.ScaleTo:create(0.1, 1.0)))

end

return AddDiamondLayer