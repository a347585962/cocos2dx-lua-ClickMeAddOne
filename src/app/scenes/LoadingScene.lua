--
-- Author: Your Name
-- Date: 2016-10-08 18:10:29
--
local HomeScene = require("app.scenes.HomeScene")
local LoadingScene = class("LoadingScene", function()
    return display.newScene("LoadingScene")
end)

function LoadingScene:ctor()
    
	-- 背景填充
	local layer = display.newColorLayer(cc.c4b(250,255,255,255))
	self:addChild(layer)

	-- 背景框
	self.mBgSprite = UIHelper.createSprite("image/baobiao.png")
	self.mBgSprite:setPosition(cc.p(display.cx, display.cy))
	self:addChild(self.mBgSprite)
	self.mBgSpriteSize = self.mBgSprite:getContentSize()

	self.mBgSprite:setOpacity(0)

end

function LoadingScene:onEnter()

	self.mBgSprite:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.DelayTime:create(2.0),cc.CallFunc:create(function ()
		display.replaceScene(HomeScene.new(), "fade", 1.5, cc.c3b(255, 2550, 255))
	end)))

end

function LoadingScene:onExit()
end

return LoadingScene
