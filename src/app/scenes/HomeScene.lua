--
-- Author: Your Name
-- Date: 2016-09-28 14:30:15
--

-- local MainScene = require("app.scenes.MainScene")
local TransitionScene = require("app.scenes.TransitionScene")
local HomeScene = class("HomeScene", function()
    return display.newScene("HomeScene")
end)

function HomeScene:ctor()
    
	self:initUI()

	if device.platform == "android" then
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                -- 显示对话框  
                NativeHelper.showAlert("Confirm Exit", "Are you sure exit game ?", function (event)
                    cc.Director:getInstance():endToLua()
                end)      
            end
        end)
        self:setKeypadEnabled(true)
    end 
end

function HomeScene:onEnterTransitionFinish()
	
end

function HomeScene:onEnter()
end

function HomeScene:onExit()
end

function HomeScene:initUI()
	
	-- 底色
	local colorLayer = cc.LayerColor:create(cc.c4b(255,255,255,255))
	self:addChild(colorLayer)

	-- LOGO
	self.mLogo = UIHelper.createSprite("image/logo.png")
	self.mLogo:setPosition(cc.p(display.cx, display.height * 3 / 4))
	self:addChild(self.mLogo)

	-- 顶部内容
	self:addTopUI()

	-- 底部内容
	self:addBottomUI()

	-- 中间内容
	self:addMiddleUI()

	-- 添加按钮
	self.mStartBtn = UIHelper.createButton({
		normal   = "image/start.png",
        pressed  = "image/start_1.png",  
        buttonClick = function (event)
        	print("startBtn click")
        	-- display.replaceScene(MainScene.new(), "fade", 0.5, cc.c3b(255, 2550, 2550))
        	display.replaceScene(TransitionScene.new(), "fade", 0.1, cc.c3b(255, 2550, 255))
        end
	})
	self.mStartBtn:setPosition(cc.p(display.cx, display.height  / 4 + 80))
	self:addChild(self.mStartBtn)

end

function HomeScene:addTopUI()
	-- 分数
	local scoreNum = GameData:getInstance():getHightScore()
	self.mHightScore = display.newTTFLabel({
		    text = string.format("High Score:%s",scoreNum),
		    font = "Arial",
		    size = 30,
		    color = cc.c3b(255,140,0), 
		})
	self.mHightScore:setAnchorPoint(cc.p(0, 1.0))
	self.mHightScore:setPosition(cc.p(10, display.height - 20))
	self:addChild(self.mHightScore)

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

end

function HomeScene:addBottomUI()
	
	-- 声音开关按钮
	local soundBtn = UIHelper.createCheckButton({
		on  = "image/sound_on.png",
		off = "image/sound_off.png", --     关闭状态
        onButtonStateChanged = function (event)
        	
        end
	})
	soundBtn:setAnchorPoint(cc.p(0.5, 0))
	soundBtn:setPosition(cc.p(display.cx, 80))
	self:addChild(soundBtn)

	-- 分享按钮
	-- local shareBtn = UIHelper.createButton({
	-- 	normal   = "image/share.png",
 --        pressed  = "image/share_1.png",  
 --        buttonClick = function ()
 --        	print("share")
 --        end
	-- })
	-- shareBtn:setAnchorPoint(cc.p(1.0, 0))
	-- shareBtn:setPosition(cc.p(display.width - 40, 80))
	-- self:addChild(shareBtn)

	-- more按钮
	-- local moreBtn = UIHelper.createButton({
	-- 	normal   = "image/more.png",
 --        pressed  = "image/more_1.png",  
 --        buttonClick = function ()
 --        	print("more")
 --        end
	-- })
	-- moreBtn:setAnchorPoint(cc.p(0, 0))
	-- moreBtn:setPosition(cc.p(40, 70))
	-- self:addChild(moreBtn)

end

-- 添加中部展示动画
function HomeScene:addMiddleUI()
	
	local board = UIHelper.createSprite("image/guideBoard.png")
	board:setPosition(cc.p(display.cx, display.height * 0.5 + 50))
	self:addChild(board)
	local boardSize = board:getContentSize()

	local posTable = {
		[1] = cc.p(boardSize.width * 0.5 - 110,boardSize.height * 0.5),
		[2] = cc.p(boardSize.width * 0.5,      boardSize.height * 0.5),
		[3] = cc.p(boardSize.width * 0.5 + 110,boardSize.height * 0.5),
	}
	function initNumCard()
		local numTable = {2, 1, 2}
		local zorderTable = {1, 2, 1}
		for i=1,3 do
			local card = UIHelper.createSprite(string.format("image/num%s.png", numTable[i]))
			card:setPosition(posTable[i])
			card:setAnchorPoint(cc.p(0.5, 0.5))
			card:setTag(i)
			board:addChild(card, zorderTable[i])
		end

		local hand = UIHelper.createSprite("image/hand.png")
		hand:setAnchorPoint(cc.p(112/144, 27/146))
		hand:setPosition(cc.p(boardSize.width * 0.5 + 100, -20 - 100))
		board:addChild(hand, 100)
		hand:setOpacity(0)
		
		hand:runAction(cc.Sequence:create(
			cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 100)),cc.FadeIn:create(0.5)),
			cc.RotateTo:create(0.25, 30),
			cc.RotateTo:create(0.25, 0),
			cc.CallFunc:create(function ()
				-- 找到中间的card
				local card = board:getChildByTag(2)
				local cardSize = card:getContentSize()
				card:setTexture("image/num2.png")

				local card1 = board:getChildByTag(1)
				local card2 = board:getChildByTag(3)
				local card3 = board:getChildByTag(3)

				card1:runAction(cc.Sequence:create(cc.MoveBy:create(0.8, cc.p(110, 0)),cc.CallFunc:create(function ()
					
					card:setTexture("image/num3.png")
					
				end)))
				card3:runAction(cc.MoveBy:create(0.8, cc.p(-110, 0)))

				-- 添加card的动画
				function addBigStart()
					local posTable = {
						cc.p(cardSize.width / 4,     cardSize.height * 3 / 4),
						cc.p(cardSize.width * 3 / 4, cardSize.height * 3 / 4),
						cc.p(cardSize.width / 4,     cardSize.height / 4),
						cc.p(cardSize.width * 3 / 4, cardSize.height  / 4),
					}
					for i=1,4 do
						
						local start2 = UIHelper.createSprite("image/start2.png")
						start2:setPosition(posTable[i])
						card:addChild(start2)
						start2:setOpacity(0)
						start2:runAction(cc.Sequence:create(
							cc.DelayTime:create(0.09 * i),
							cc.FadeIn:create(0.1 + 0.05 * math.random(5)),
							cc.FadeOut:create(0.2 + 0.05 * math.random(5)),
							cc.RemoveSelf:create(),
							cc.CallFunc:create(function ()
								
							end)
						))
					end
					local rotation = math.random(300)
					for i=1,2 do
						local start3 = UIHelper.createSprite("image/start3.png")
							start3:setPosition(cc.p(cardSize.width * 0.5, cardSize.height * 0.5))
							card:addChild(start3)
							start3:setOpacity(0)
							start3:setScale(0)
							start3:setRotation(rotation * (i - 3))
							start3:runAction(cc.Sequence:create(
								cc.DelayTime:create(0.5 * (i - 1)),
								cc.Spawn:create(cc.ScaleTo:create(0.5, 1.5 + (i - 1) * 0.5),cc.FadeIn:create(0.2)),
								cc.FadeOut:create(0.1),
								cc.CallFunc:create(function ()
									
									if i == 2 then
										local numTable = {1,1}
										for i=1,2 do
											local detal = i == 1 and -1 or 1 
											local card = UIHelper.createSprite(string.format("image/num%s.png", numTable[i]))
											card:setPosition(cc.p(boardSize.width * 0.5 + 110 * detal,boardSize.height * 0.5 + 110))
											board:addChild(card)
											card:runAction(cc.Sequence:create(
												cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0,-110)),cc.FadeIn:create(0.5)),
												cc.DelayTime:create(i == 2 and 1.0 or 0.0),
												cc.CallFunc:create(function ()
													if i == 2 then
														guideAction()
													end
												end)
											))	
										end
									end
									
								end),
								cc.RemoveSelf:create()
							))
					end


				end

				-- 添加小星星
				for i=1,5 do
		
					local start1 = UIHelper.createSprite("image/start1.png") 
					start1:setPosition(cc.p(math.random(10, cardSize.width-10), math.random(15, cardSize.height-10)))
					start1:setOpacity(0)
					card:addChild(start1)
					start1:setRotation(math.random(300))
					start1:runAction(cc.Sequence:create(
						cc.DelayTime:create(0.02 * i),
						cc.FadeIn:create(0.05 + 0.1 * math.random(5)),
						cc.FadeOut:create(0.1 + 0.1 * math.random(5)),
						cc.RemoveSelf:create(),
						cc.CallFunc:create(function () 
							if i == 1 then
								addBigStart()
							end
							
						end)
					))

				end


			end),
			cc.FadeOut:create(0.2),
			cc.RemoveSelf:create()
			))

	end

	function guideAction()
		board:removeAllChildren()
		initNumCard()
	end
	guideAction()
end


return HomeScene













