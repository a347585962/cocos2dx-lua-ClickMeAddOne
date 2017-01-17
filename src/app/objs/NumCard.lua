--
-- Author: wusonglin
-- Date: 2016-09-08 14:06:24
-- 显示数字的卡牌  可点击
-- 
--

local NumCard = class("NumCard", function(number)
    return display.newNode()
end)

--[[
-- 参数 
	number   显示的数字
]]
function NumCard:ctor(number)
	
	number = number or 0
	-- 数字索引
	self.mNumberIndex = number

	-- 回调
	self.mCallBack = nil

	-- 卡片选中状态,标记
    self.mIsSelect = true

	self.mIsVisibleEffect = false
	-- 数字卡片
	self.mNumSprite = display.newSprite(string.format("card/numArray_%d.png", self.mNumberIndex % 10))
	self:addChild(self.mNumSprite)

	-- 显示的数字
	self.mNumberLabel = UIHelper.newNumberLabel({
			text = string.format("%d",self.mNumberIndex), -- 需要显示数字
			imgFile = "font/squareNum.png", -- 数字图片名
		})
	self.mNumberLabel:setPosition(cc.p(self.mNumSprite:getContentSize().width / 2, self.mNumSprite:getContentSize().height / 2))
	-- self.mNumberLabel:enableOutline(cc.c4b(0, 0, 0, 0), 10)
	self.mNumSprite:addChild(self.mNumberLabel)

	self.mTouchEffect = display.newSprite("card/squareTouchEffect.png")
	self.mTouchEffect:setAnchorPoint(cc.p(0, 0))
	self.mNumSprite:addChild(self.mTouchEffect,100)
	self.mTouchEffect:setVisible(self.mIsVisibleEffect)

	self:addListener()
end

function NumCard:getCardContentSize()
	return self.mNumSprite:getContentSize()
end

function NumCard:setEnabled(value)
	self.mNumSprite:setTouchEnabled(value)
end

-- 监听事件
function NumCard:addListener()
	self.mNumSprite:setTouchEnabled(true)
    self.mNumSprite:setTouchCaptureEnabled(true)
    self.mNumSprite:setTouchSwallowEnabled(true)
	self.mNumSprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

		if event.name == "began" then
			print("began")
			self.mIsVisibleEffect = true
			self.mTouchEffect:setVisible(self.mIsVisibleEffect)

			-- UIHelper.dump(event)
			print(self:getTag())
	        return true
        end

        if event.name == "moved" then
        	-- 各种变换坐标系	
        	-- local pos1 = self:getParent():convertToNodeSpace(cc.p(event.x,event.y))
        	-- local pos  = self:convertToNodeSpace(cc.p(pos1.x,pos1.y))
        	-- -- UIHelper.dump(self.mNumSprite:getBoundingBox())
        	-- if cc.rectContainsPoint(self.mNumSprite:getBoundingBox(),cc.p(pos.x, pos.y)) then
        	-- 	self.mIsVisibleEffect = true
        	-- 	print("rect")
        	-- else
        	-- 	self.mIsVisibleEffect = false
        	-- 	print("***")
        	-- end
        end

        if event.name == "ended" then
        	-- 没有显示则返回
 			if self.mIsVisibleEffect == false then return end

 			self.mNumberIndex = self.mNumberIndex + 1 
 			-- 处理数字
 			-- local tempSrc = self.mNumberIndex % 10 == 0 and ( math.random(9) + 1 ) or self.mNumberIndex % 10
 			local tempSrc = self.mNumberIndex % 10
 			self.mNumberLabel:setString(string.format("%d",self.mNumberIndex))
 			self.mNumSprite:setTexture(string.format("card/numArray_%d.png", tempSrc))
 			self.mTouchEffect:setVisible(false)

 			if self.mCallBack then
 				self.mCallBack(self:getTag())
 			end
        end

        if event.name == "cancelled" then
        	print("cancelled")	
        end

	end)
end

-- 点击正确的动画
function NumCard:clickRightAction()
	
	local cardSize = self.mNumSprite:getContentSize()

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
				self.mNumSprite:addChild(start2)
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
					self.mNumSprite:addChild(start3)
					start3:setOpacity(0)
					start3:setScale(0)
					start3:setRotation(rotation * (i - 3))
					start3:runAction(cc.Sequence:create(
						cc.DelayTime:create(0.25 * (i - 1)),
						cc.Spawn:create(cc.ScaleTo:create(0.25, 1.5 + (i - 1) * 0.5),cc.FadeIn:create(0.1)),
						cc.FadeOut:create(0.1),
						cc.CallFunc:create(function ()
							
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
			self.mNumSprite:addChild(start1)
			start1:setRotation(math.random(300))
			start1:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.01 * i),
				cc.FadeIn:create(0.025 + 0.1 * math.random(5)),
				cc.FadeOut:create(0.05 + 0.1 * math.random(5)),
				cc.RemoveSelf:create(),
				cc.CallFunc:create(function () 
					if i == 1 then
						addBigStart()
						self:addOneNumber()
					end
				end)
			))
		end
end

function NumCard:addOneNumber()

	self.mNumberIndex = self.mNumberIndex + 1 
 	-- 处理数字
	local tempSrc = self.mNumberIndex % 10 == 0 and ( math.random(9) + 1 ) or self.mNumberIndex % 10
	self.mNumberLabel:setString(string.format("%d",self.mNumberIndex))
	self.mNumSprite:setTexture(string.format("card/numArray_%d.png", tempSrc))

end

-- 获得数字
function NumCard:getNumIndex()
	return self.mNumberIndex
end

-- 设置数字
function NumCard:setNumIndex(num)
	self.mNumberIndex = num
end

-- 按钮可点击
function NumCard:setTouch(isTouch)
	self.mNumSprite:setTouchEnabled(isTouch)
end

-- 按钮可点击
function NumCard:setTouchCallback(func)
	self.mCallBack = func
end

-- 设置选中状态
function NumCard:setSelect(isSelect)
	self.mIsSelect = isSelect
end

-- 获得选中状态
function NumCard:getSelect()
	return self.mIsSelect
end

return NumCard