--
-- Author: Your Name
-- Date: 2016-09-29 19:47:49
--
local StopLayer     = require("app.layers.StopLayer")

local FailureLayer  = require("app.layers.FailureLayer")


local GameUILayer = class("GameUILayer",function()
    return display.newLayer()
end)

function GameUILayer:ctor(params)

	self:addTopUI()

	self:addHP()	

	self:setTouchSwallowEnabled(false)


end

-- 上部UI
function GameUILayer:addTopUI()
	-- 钻石背景
	local diamondBg = UIHelper.createSprite("image/diamond_bg1.png")
	diamondBg:setAnchorPoint(cc.p(1.0, 1.0))
	diamondBg:setPosition(cc.p(display.width - 20, display.height - 10))
	self:addChild(diamondBg)
	diamondBg:setScale(0.8)

	-- 钻石
	local diamond = UIHelper.createSprite("image/diamond.png")
	diamond:setPosition(cc.p(30, 37))
	diamondBg:addChild(diamond)
	diamond:setScale(1.1)

	-- 添加按钮
	local addBtn = UIHelper.createButton({
		normal   = "image/add.png",
        pressed  = "image/add_1.png",  
        buttonClick = function (event)
        	self:addChild(require("app.layers.AddDiamondLayer").new(), 100)
        end
	})
	addBtn:setScale(1.2)
	addBtn:setPosition(cc.p(161, 37))
	diamondBg:addChild(addBtn)

	local num = GameData:getInstance():getDiamonNum()
	-- 钻石数量
	local diamondNum = display.newTTFLabel({
		    text = string.format("%s", num),
		    font = "Arial",
		    size = 50,
		    color = cc.c3b(255,255,250), 
		})
	diamondNum:setPosition(cc.p(90, 37))
	diamondBg:addChild(diamondNum)

	Notification:registerAutoObserver(diamondNum,function ()
		
		local num = GameData:getInstance():getDiamonNum()
		diamondNum:setString(string.format("%s", num))

	end,EventsName.eDiamondChange)

	self.mScoreNum  = 0
	self.mTempScore = 0
	-- 添加分数
	self.mScore = UIHelper.newNumberLabel({
		text = string.format("%s", self.mScoreNum), -- 需要显示数字
        imgFile = "font/scoreNum.png", -- 数字图片名
    })
	self.mScore:setPosition(cc.p(display.cx, display.cy + 350))
	self:addChild(self.mScore)

	-- 注册分数监听
	Notification:registerAutoObserver(self.mScore,function ()
		
		self.mTempScore = GameData:getInstance():getScore()
		-- self.mScoreNum = self.mScoreNum + self.mTempScore
		self:scoreAction(self.mScoreNum)

	end,EventsName.eScoreAdd)

	-- home按钮
	local homeBtn = UIHelper.createButton({
		normal    = "image/stop.png",
        buttonClick = function ()
        	self:addChild(StopLayer.new(),100)
        	-- self:addChild(GameDoneLayer.new(),100)
        	
        end
	})
	homeBtn:setScale(1.2)
	homeBtn:setAnchorPoint(cc.p(0.5, 0.5))
	homeBtn:setPosition(cc.p(50, display.height - 40))
	self:addChild(homeBtn)


	
	
end

function GameUILayer:scoreAction()
	local time = 0.01
	local score = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	local onScheduler = function()

		if self.mTempScore <= score then
            scheduler:unscheduleScriptEntry(self.mScheduleHandle)
			self.mScheduleHandle = nil
			self.mTempScore = 0
			GameData:getInstance():setLastScore(self.mScoreNum)
        else
            score = score + 1
            self.mScoreNum = self.mScoreNum + 1
            self.mScore:setString(string.format("%s", self.mScoreNum))
		end

	end
    self.mScheduleHandle = scheduler:scheduleScriptFunc(onScheduler, time, false)
end

-- 增加生命值
function GameUILayer:addHP()
	
	self.mHPTable = {}

	local hpBg = UIHelper.createSprite("image/hp_1.png")
	hpBg:setPosition(cc.p(display.cx, display.cy + 250))
	self:addChild(hpBg)

	local hpBgSize = hpBg:getContentSize()
	local hpSize   = cc.size(100, 41)

	local detalWidth = (hpBgSize.width - 5 * hpSize.width) / 6

	for i=1,5 do
		local hp = UIHelper.createSprite("image/hp.png")
		hp:setAnchorPoint(cc.p(0, 0.5))
		hp:setPosition(cc.p(detalWidth * i + hpSize.width * (i - 1), hpBgSize.height * 0.5))
		hpBg:addChild(hp)
		hp:setOpacity(0)
		hp:runAction(cc.Sequence:create(cc.DelayTime:create((i - 1) * 0.15),cc.FadeIn:create(0.5)))
		table.insert(self.mHPTable, hp)
		hp:setTag(i)
	end

	
	-- 注册血量变化消息事件
	Notification:registerAutoObserver(hpBg, function ()
		
		-- 获取血量
		local hpNum     = GameData:getInstance():getHp()
		print(hpNum)

		local isVisible = true
		for i,v in ipairs(self.mHPTable) do
			isVisible = i <= hpNum and true or false
			v:setVisible(isVisible)
		end
		if hpNum == 0 then
			self:addChild(FailureLayer.new(),100)
			
		end


	end, EventsName.eHpChange)

end

return GameUILayer






