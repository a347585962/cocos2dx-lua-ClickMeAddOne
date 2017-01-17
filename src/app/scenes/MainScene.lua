
--
-- Author: wusonglin
-- Date: 2016-09-08 16:02:56
--

local GameLayer   = require("app.layers.GameLayer")
local GameUILayer = require("app.layers.GameUILayer")
local GameDoneLayer = require("app.layers.GameDoneLayer")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    
	self:addChild(GameLayer.new(),0)
	self:addChild(GameUILayer.new(),1)
	
	Notification:registerAutoObserver(self, function ()
		self:addChild(GameDoneLayer.new(),110)
	end, EventsName.eShowBoard)

	if device.platform == "android" then
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                -- 显示对话框  
                UIHelper.goHomeAlert()     
            end
        end)
        self:setKeypadEnabled(true)
    end 
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
