--
-- Author: Your Name
-- Date: 2016-10-08 16:26:27
--
local MainScene = require("app.scenes.MainScene")

local TransitionScene = class("TransitionScene", function()
    return display.newScene("TransitionScene")
end)

function TransitionScene:ctor()
    
	-- 背景填充
	local layer = display.newColorLayer(cc.c4b(250,255,255,180))
	self:addChild(layer)

	self:showLogo()
	GameData:getInstance():reviveHp()
	-- 进度条
	self.mProgressBar = require("app.common.ProgressBar").new({
        bgImage  = "image/progressBg.png",
        barImage = "image/progress.png",
        maxValue = 100,
        currValue = 100,
    })
    self.mProgressBar:setPosition(cc.p(display.cx, 100))
    self.mProgressBar:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.mProgressBar, 10)

    local oneNum = math.random(90)
    local twoNum = math.random(oneNum, 99)

    local detalTime = 2.0
    self:runAction(cc.Sequence:create(
		cc.CallFunc:create(function ()
			self.mProgressBar:setCurrValue(oneNum, detalTime)
		end),
		cc.DelayTime:create(detalTime),
		cc.CallFunc:create(function ()
			self.mProgressBar:setCurrValue(twoNum, detalTime)
		end),
		cc.DelayTime:create(detalTime),
		cc.CallFunc:create(function ()
			self.mProgressBar:setCurrValue(100, detalTime)
		end),
		cc.DelayTime:create(0.2 + detalTime),
		cc.CallFunc:create(function ()
			display.replaceScene(MainScene.new(), "fade", 0.5, cc.c3b(255, 255, 255))
		end)
    ))

end

function TransitionScene:createNumRand()
	-- 生成数字表
	local tempTab = {}
	for i=1,9 do
		local temp = i
		table.insert(tempTab,temp)
	end

	local numTab = {}
	function randNum()
		-- 生成数字
		local num = table.nums(tempTab)
		local index = math.random(num)
		table.insert(numTab,tempTab[index])
		table.remove(tempTab, index)

		if next(tempTab) then randNum() end
	end
	randNum()

	return numTab
end

function TransitionScene:showLogo()
	-- 添加小星星
	local posTable = {
		cc.p(display.width / 6, display.height * 5 / 6),
		cc.p(display.width / 6, display.height * 3 / 6),
		cc.p(display.width / 6, display.height / 6),
		cc.p(display.width  * 3 / 6, display.height * 5 / 6),
		cc.p(display.width  * 3 / 6, display.height * 3 / 6),
		cc.p(display.width  * 3 / 6, display.height / 6),
		cc.p(display.width  * 5 / 6, display.height * 5 / 6),
		cc.p(display.width  * 5 / 6, display.height * 3 / 6),
		cc.p(display.width  * 5 / 6, display.height / 6),
	}

	local tempTable = self:createNumRand()

	for i=1,5 do
		local index = tempTable[i]
		local start1 = UIHelper.createSprite(string.format("image/%s.png",math.random(1,10)))
		start1:setPosition(posTable[index])
		start1:setOpacity(0)
		self:addChild(start1)
		-- start1:setRotation(math.random(300))
		start1:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.1 * i),
			cc.FadeIn:create(0.55 + 0.1 * math.random(5)),
			cc.DelayTime:create(0.25 * math.random(5)),
			cc.FadeOut:create(0.05 + 0.1 * math.random(5)),
			cc.RemoveSelf:create(),
			cc.CallFunc:create(function () 
				if i == 5 then
					self:showLogo()
				end
			end)
		))
	end
end

function TransitionScene:onEnter()
end

function TransitionScene:onExit()
end

return TransitionScene
