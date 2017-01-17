--
-- Author: Your Name
-- Date: 2016-09-30 15:25:16
--
--
-- 游戏玩成layer
--

local NumCard = require("app.objs.NumCard")
local GameDoneLayer = class("GameDoneLayer",function()
    return display.newLayer()
end)

function GameDoneLayer:ctor(params)

	-- 背景填充
	local layer = display.newColorLayer(cc.c4b(96,96,96,180))
	self:addChild(layer)

	self.mLight = UIHelper.createSprite("image/light.png")
	self.mLight:setPosition(cc.p(display.cx, display.cy))
	self.mLight:setScale(2.0)
	self.mLight:setOpacity(0)
	self:addChild(self.mLight)

	-- 背景框
	self.mBgSprite = UIHelper.createSprite("image/gamedone_bg.png")
	self.mBgSprite:setPosition(cc.p(display.cx, display.cy))
	self:addChild(self.mBgSprite)
	self.mBgSpriteSize = self.mBgSprite:getContentSize()
	self.mBgSprite:setScale(0)

	-- 最高分
	local label = display.newTTFLabel({
	    text = "High Score",
	    font = "Arial",
	    size = 40,
	    color = cc.c3b(255,255,255), 
	})
	label:setPosition(cc.p(self.mBgSpriteSize.width * 0.5, 630))
	self.mBgSprite:addChild(label)

	local scoreNum = GameData:getInstance():getHightScore()
	self.mHighScore = display.newTTFLabel({
	    text = string.format("%s", scoreNum),
	    font = "Arial",
	    size = 50,
	    color = cc.c3b(255,255,255), 
	})
	self.mHighScore:setPosition(cc.p(self.mBgSpriteSize.width * 0.5, 590))
	self.mBgSprite:addChild(self.mHighScore)

	-- 当前分数
	self.mScoreNow = UIHelper.newNumberLabel({
		text = string.format("%d",0), -- 需要显示数字
		imgFile = "font/nowScore_number.png", -- 数字图片名
	})
	self.mScoreNow:setPosition(cc.p(self.mBgSpriteSize.width * 0.5, 480))
	self.mBgSprite:addChild(self.mScoreNow)
	self.mScoreNow:setOpacity(0)

	-- 左右花瓣
	self.mLeftFlower = UIHelper.createSprite("image/flower_left.png")
	self.mLeftFlower:setAnchorPoint(cc.p(1.0, 0.5))
	self.mLeftFlower:setOpacity(0)
	self.mLeftFlower:setPosition(cc.p(self.mBgSpriteSize.width * 0.5, 320))
	self.mBgSprite:addChild(self.mLeftFlower)
	self.mLeftFlower:setScale(1.5)

	-- 左右花瓣
	self.mRightFlower = UIHelper.createSprite("image/flower_right.png")
	self.mRightFlower:setAnchorPoint(cc.p(0.0, 0.5))
	self.mRightFlower:setOpacity(0)
	self.mRightFlower:setPosition(cc.p(self.mBgSpriteSize.width * 0.5, 320))
	self.mBgSprite:addChild(self.mRightFlower)
	self.mRightFlower:setScale(1.5)

	local numMax = GameData:getInstance():getMaxNum()

	-- 当前最大数字
	self.mCard = NumCard.new(numMax)
	self.mCard:setScale(0)
	self.mCard:setEnabled(false)
	self.mCard:setPosition(cc.p(self.mBgSpriteSize.width * 0.5, 370))
	self.mBgSprite:addChild(self.mCard)

	-- 按钮
	-- home
	self.mHomeBtn = UIHelper.createButton({
		normal    = "image/home.png",
        pressed   = "image/home_1.png",  
        buttonClick = function ()
        	UIHelper.goHomeAlert()
        end
	})
	self.mHomeBtn:setOpacity(0)
	self.mHomeBtn:setAnchorPoint(cc.p(1.0, 0.5))
	self.mHomeBtn:setPosition(cc.p(self.mBgSpriteSize.width * 0.5 - 20, 220))
	self.mBgSprite:addChild(self.mHomeBtn)

	-- home
	self.mReplayBtn = UIHelper.createButton({
		normal    = "image/replay.png",
        pressed   = "image/replay_1.png",  
        buttonClick = function ()
        	display.replaceScene(require("app.scenes.TransitionScene").new(), "fade", 0.1, cc.c3b(255, 2550, 2550))
        end
	})
	self.mReplayBtn:setOpacity(0)
	self.mReplayBtn:setAnchorPoint(cc.p(0.0, 0.5))
	self.mReplayBtn:setPosition(cc.p(self.mBgSpriteSize.width * 0.5 + 20, 220))
	self.mBgSprite:addChild(self.mReplayBtn)

	-- share
	self.mShareBtn = UIHelper.createButton({
		normal    = "image/share_done.png",
        pressed   = "image/share_done_1.png",  
        buttonClick = function ()

        end
	})
	self.mShareBtn:setAnchorPoint(cc.p(0.5, 0.5))
	self.mShareBtn:setScale(0)
	self.mShareBtn:setPosition(cc.p(self.mBgSpriteSize.width * 0.5, 100))
	self.mBgSprite:addChild(self.mShareBtn)

	self.mBgSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.2),cc.ScaleTo:create(0.1, 1.0),cc.CallFunc:create(function ()
		self:showUIAction()
	end)))

end

function GameDoneLayer:showUIAction()
	-- 灯光
	self.mLight:runAction(cc.FadeIn:create(0.5))
	self.mLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, 60)))

	self.mScoreNow:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.CallFunc:create(function ()
		-- 分数
		print("getLastScore"..GameData:getInstance():getLastScore())
		self:scoreAction(self.mScoreNow,GameData:getInstance():getLastScore(),function ()
			self.mHomeBtn:runAction(cc.FadeIn:create(0.5))
			self.mReplayBtn:runAction(cc.FadeIn:create(0.5))
			self.mShareBtn:runAction(cc.ScaleTo:create(0.5,1.0))
		end)
		
	end)))

	self.mLeftFlower:runAction(cc.FadeIn:create(0.5))

	-- 左右花瓣
	self.mRightFlower:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.CallFunc:create(function ()
		
		self.mCard:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.5, 1.2),cc.RotateBy:create(0.5, 360 * 2)),cc.ScaleTo:create(0.1, 1.0)))

	end)))
end

function GameDoneLayer:scoreAction(node,score,callback)
	local time = 0.01
	local tempScore = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	local onScheduler = function()

		if tempScore >= score and self.mScheduleHandle ~= nil then
            scheduler:unscheduleScriptEntry(self.mScheduleHandle)
			self.mScheduleHandle = nil

			if callback then
				callback()
			end

			local scoreNum = GameData:getInstance():getHightScore()
			if tempScore > scoreNum then
				GameData:getInstance():setHightScore(tempScore)
				self:scoreAction(self.mHighScore,tempScore)
			end
        else
            tempScore = tempScore + 1
            node:setString(string.format("%s", tempScore))
		end

	end
    self.mScheduleHandle = scheduler:scheduleScriptFunc(onScheduler, time, false)
end

return GameDoneLayer