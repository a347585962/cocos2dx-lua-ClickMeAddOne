--
-- Author: wusonglin
-- Date: 2016-09-08 16:02:56
--

local NumCard = require("app.objs.NumCard")

local GameLayer = class("GameLayer",function()
    return display.newLayer()
end)

--[[
-- params 中的各项为
	{
	}
]]
function GameLayer:ctor(params)

	-- 背景填充
	local layer = display.newColorLayer(cc.c4b(220,255,255,255))
	self:addChild(layer)

	-- 卡片的背景框
	self.mCardBg = UIHelper.createSprite("numArraySceneBg.png")
	self.mCardBg:setPosition(cc.p(display.cx, display.cy - 60))
	self:addChild(self.mCardBg)
	self.mCardBg:setScale(0.8)

	-- 屏蔽页
	self.mStdLayer = nil

	-- 点击消除的tag
	self.mClickCardTag = -1

	-- 初始最大值
	self.m_end = 5

	-- math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6))) 
	-- math.randomseed(os.time())  
	-- 生成矩阵
	self:createVector()

	self:setLayerTouch(false)

	
	Notification:registerAutoObserver(self.mCardBg, function ()
		
		self:setLayerTouch(false)
		self:gameOver()

	end, EventsName.eGameOver)
end

-- 生成矩阵
function GameLayer:createVector()
	self.mColNum = 5   -- 列
	self.mRowNum = 5   -- 行

	-- 卡片的容器
	self.mCardVector = {}

	-- 遍历的索引值
	self.mIndex = 1

	-- 卡片矩阵的初始坐标
	self.mInitPos = cc.p(80, 85)

	-- 生成卡片矩阵
	local tempIndex = 1
	function createCardOneRow()
		local numTab = self:createNumRand(self.m_end)
		for j=1,self.mRowNum do
			
			-- 卡片
			local index = numTab[j]
			local card = NumCard.new(index)
			
			local cardSize = card:getCardContentSize()
			-- 初始坐标
			card:setPosition(
				self.mInitPos.x + cardSize.width  * (j - 1), 
				self.mInitPos.y + cardSize.height * ( self.mColNum - 0.5 )
				)
			card:setTag(tempIndex * 10 + j)
			self.mCardBg:addChild(card)
			card:setTouchCallback(handler(self, self.cardClick))
			table.insert(self.mCardVector, card)
			-- 真实坐标
			local realPos = cc.p(self.mInitPos.x + cardSize.width  * (j - 1), self.mInitPos.y + cardSize.height * (tempIndex  - 1))
			card:runAction(cc.Sequence:create(
				cc.MoveTo:create(((self.mColNum - tempIndex) / cardSize.height * 10) * j * 0.5,realPos),
				cc.CallFunc:create(function ()
					-- 动作完成
					if j == self.mRowNum and tempIndex < self.mColNum then	
						tempIndex = tempIndex + 1					
						createCardOneRow()
					elseif j == self.mRowNum and tempIndex == self.mColNum then
						print("done")
						self:setLayerTouch(true)
						self:autoCheckCard(self.mIndex)
					end
				end)
			))
		end
	end
	-- 创建
	createCardOneRow()
end

-- 游戏结束 计算分数 
function GameLayer:gameOver()
	
	local numTable = {}
	for i,v in ipairs(self.mCardVector) do
		table.insert(numTable,v)
	end
	table.sort(numTable, function (a, b)
        if tonumber(a:getNumIndex()) > tonumber(b:getNumIndex()) then
            return true
        else
            return false
        end
	end)

	local tempNum = numTable[1]:getNumIndex()
	-- 设置最大的数字
	GameData:getInstance():setMaxNum(tempNum)

	local tempTable = {}
	local allNumTable = {}
	for i,v in ipairs(numTable) do
		local num = v:getNumIndex()
		if tempNum ~= num  then
			tempNum = num
			table.insert(allNumTable, tempTable)
			tempTable = {}
		end

		if tempNum == num then
			table.insert(tempTable, v)
		end
		-- 处理最后一个
		if i == table.nums(numTable) then
			table.insert(allNumTable, tempTable)
		end

	end

	local allNum = table.nums(allNumTable)
	for i,v in ipairs(allNumTable) do
		local cardNum  = table.nums(v)
		local scoreNum = 0
		for j,k in ipairs(v) do
			
			-- 显示分数增加
			local numberIndex = k:getNumIndex()
			scoreNum = scoreNum + numberIndex * 1
			local score = display.newTTFLabel({
			    text = string.format("+%s",numberIndex * 1),
			    font = "Arial",
			    size = 60,
			    color = cc.c3b(0,0,0), 
			})
			score:setPosition(cc.p(k:getPositionX(),k:getPositionY()))
			self.mCardBg:addChild(score,100)
			score:setOpacity(0)

			k:runAction(cc.Sequence:create(
					cc.DelayTime:create(0.8 * (i - 1)),
					cc.Spawn:create(cc.RotateBy:create(0.5, 360 * math.random(-2, 2)), cc.ScaleTo:create(0.5, 0))
				))

			score:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.8 * (i - 1)),
				cc.FadeIn:create(0.1),
				cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 100)), cc.FadeOut:create(0.5)),
				cc.CallFunc:create(function ()
					if j == cardNum then
						-- 设置过度分数 发送分数变化消息
						GameData:getInstance():setScore(scoreNum)
						Notification:postNotification(EventsName.eScoreAdd)
					end

					if j == cardNum and i == allNum then
						self:setLayerTouch(true)
						Notification:postNotification(EventsName.eShowBoard)
					end
				end),
				cc.RemoveSelf:create()
			))
		end

	end

end


----------------[[---------页面功能函数-------]]----------------

-- 根据最大值，随机输出 
-- 生成一行 每个数字均不一样
function GameLayer:createNumRand(numMax)
	-- 生成数字表
	local tempTab = {}
	for i=1,self.mColNum do
		local temp = i
		temp = temp > numMax and numMax or temp
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

-- 屏蔽点击事件
function GameLayer:setLayerTouch(isTouch)
	-- 不可点击
	if isTouch == false and self.mStdLayer == nil then
		
		self.mStdLayer = UIHelper.createSwallowLayer(255)
		self:addChild(self.mStdLayer)

	-- 可以点击
	elseif isTouch == true and self.mStdLayer then

		self.mStdLayer:removeFromParent()
		self.mStdLayer = nil

	end
end

-- 根据tag获取对应table的索引  
function GameLayer:getIndexFromTag(tag)
	
	return (math.floor(tag / 10) - 1) * self.mRowNum + tag % 10
end

-- 根据table的索引获取对应tag  
function GameLayer:getTagFromIndex(index)
	local tempData = index % 5
	tempData = tempData == 0 and 5 or tempData
	return math.ceil(index / self.mRowNum) * 10 + tempData
end

-- 处理待删除队列
function GameLayer:doWithDeleteCardVector(callback)
	
	-- 根据目标小球，将待删除队列处理为三个
	-- 左 右 上 下
	local leftCardVecttor   = {}
	local topCardVecttor    = {}
	local rightCardVector   = {}
	local bottomCardVecttor = {}

	local tempCard = self.mWatiDeleteCard[1]
	local tempTag  = tempCard:getTag()
	local cardSize = tempCard:getCardContentSize()
	-- 卡片动画
	tempCard:clickRightAction()

	local scoreNum = 0
	local cardNum  = table.nums(self.mWatiDeleteCard)
	for k,v in ipairs(self.mWatiDeleteCard) do
		if k > 1 then
			local tag   = v:getTag()
			local index = self:getIndexFromTag(tag)
			self.mCardVector[index] = tag
		end
		-- 显示分数增加
		local numberIndex = v:getNumIndex()
		scoreNum = scoreNum + numberIndex * 1
		local score = display.newTTFLabel({
		    text = string.format("+%s",numberIndex * 1),
		    font = "Arial",
		    size = 60,
		    color = cc.c3b(0,0,0), 
		})
		score:setPosition(cc.p(v:getPositionX(),v:getPositionY()))
		self.mCardBg:addChild(score,100)

		score:runAction(cc.Sequence:create(
			cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 100)), cc.FadeOut:create(0.5)),
			cc.CallFunc:create(function ()
				if k == cardNum then
					-- 设置过度分数 发送分数变化消息
					GameData:getInstance():setScore(scoreNum)
					Notification:postNotification(EventsName.eScoreAdd)
				end
			end),
			cc.RemoveSelf:create()
		))
	end

	-- 分割待删除的小球  分为上下左右四个组
	for i,v in ipairs(self.mWatiDeleteCard) do
		if i > 1 then
			local tag = v:getTag()
			-- 左
			if  tag % 10 < tempTag % 10  then
				table.insert(leftCardVecttor, v)
			end
			-- 中
			if tag % 10 == tempTag % 10  then
				if math.floor(tag / 10) > math.floor(tempTag / 10) then
					table.insert(topCardVecttor, v)
				elseif math.floor(tag / 10) < math.floor(tempTag / 10) then
					table.insert(bottomCardVecttor, v)
				end
			end
			-- 右
			if tag % 10 > tempTag % 10  then
				table.insert(rightCardVector, v)
			end
		end
	end

	local countLRTable = {}
	table.insert(countLRTable, table.nums(leftCardVecttor))
	table.insert(countLRTable, table.nums(rightCardVector))
	table.sort(countLRTable, function (a, b)
        if tonumber(a) > tonumber(b) then
            return true
        else
            return false
        end
    end)

	local countTBTable = {}
	table.insert(countTBTable, table.nums(topCardVecttor))
	table.insert(countTBTable, table.nums(bottomCardVecttor))
	table.sort(countTBTable, function (a, b)
        if tonumber(a) > tonumber(b) then
            return true
        else
            return false
        end
    end)

	local detalTime = 0.1
	-- 处理这三个队列
	function moveCardInVector(tempTable,pos)
		-- 空
		if next(tempTable) == nil then
			return
		end

		local num = table.nums(tempTable)
		local i = num
		tempTable[num]:setLocalZOrder(100)
		while (i > 1) do
			local actionArry = {}
			local k = num
			while (k > 0) do
				if k <= i then
					table.insert(actionArry, cc.MoveTo:create(detalTime, cc.p(tempTable[k]:getPositionX(),tempTable[k]:getPositionY())))
					print("move")
					-- table.insert(actionArry, cc.MoveBy:create(detalTime, pos))
				else
					table.insert(actionArry, cc.DelayTime:create(detalTime))
				end
				k = k - 1
			end
			table.insert(actionArry, cc.RemoveSelf:create())
			tempTable[i]:runAction(cc.Sequence:create(actionArry))
			i = i - 1
		end
		local actionArry = {}
		for i=1,num do
			table.insert(actionArry, cc.DelayTime:create(detalTime))
		end
		table.insert(actionArry, cc.MoveBy:create(detalTime, pos))
		table.insert(actionArry, cc.RemoveSelf:create())
		tempTable[1]:runAction(cc.Sequence:create(actionArry))
	end
	-- 处理
	moveCardInVector(leftCardVecttor,  cc.p(cardSize.width, 0))
	moveCardInVector(rightCardVector,  cc.p(-cardSize.width, 0))
	self:runAction(cc.Sequence:create(cc.DelayTime:create(countLRTable[1] * detalTime),cc.CallFunc:create(function ()
		moveCardInVector(topCardVecttor,   cc.p(0, -cardSize.height))
		moveCardInVector(bottomCardVecttor,cc.p(0, cardSize.height))
	end)))

	self:runAction(cc.Sequence:create(cc.DelayTime:create((countLRTable[1] + countTBTable[1] + 1) * detalTime),cc.CallFunc:create(function ()
		
		-- 增加生命 发送消息
		GameData:getInstance():subChage(true)
		Notification:postNotification(EventsName.eHpChange)
		
		if callback then
			callback()
		else
			self:adjustVertical()
			self.mWatiDeleteCard = {}
		end	
	end)))

end

-- 卡片点击事件
function GameLayer:cardClick(tag)
	-- 点击一次，计算一次
	-- 添加屏蔽页，防止重复点击
	-- self:setLayerTouch(false)

	print("tag---->"..tag)

	-- 检测是否有符合条件的卡片
	self:checkCardIsLine(tag)

	-- 处理这些卡片
	self:dealWithWaitCard()

	-- 减少生命 发送消息
	GameData:getInstance():subChage(false)
	Notification:postNotification(EventsName.eHpChange)
end

----------------[[---------逻辑算法------]]----------------

-- 根据点击的卡片  检查周围符合条件的卡片
function GameLayer:checkCardIsLine(tag)
	-- 根据tag找到对应的卡片
	local index = self:getIndexFromTag(tag)
	local tempCard  = self.mCardVector[index]

	-- 存放条件满足的卡片
 	self.mWatiDeleteCard = {}

	-- 临时表，用于储存需要遍历的卡片
	local travelBallTable = {}
	-- 点击到的卡片首先进入，模拟队列
	table.insert(travelBallTable, tempCard)

	-- 遍历临时表
	for k,v in pairs(travelBallTable) do
		local ballTag    = v:getTag()
		-- 获取目标卡片四个方向的tag值
		local tagTop   = (math.floor(ballTag / 10) + 1) * 10 + ballTag % 10
		local tagDown  = (math.floor(ballTag / 10) - 1) * 10 + ballTag % 10
		local tagLeft  = (math.floor(ballTag / 10)) * 10 + ballTag % 10 - 1
		local tagRight = (math.floor(ballTag / 10)) * 10 + ballTag % 10 + 1

		-- 处理边缘的小球
		tagTop   = tagTop          > 55 and -1 or tagTop
		tagDown  = tagDown         < 11 and -1 or tagDown
		tagLeft  = (tagLeft  % 10) < 1  and -1 or tagLeft
		tagRight = (tagRight % 10) > 5  and -1 or tagRight

		-- 上
		if tagTop ~= -1 and self.mCardVector[self:getIndexFromTag(tagTop)] then
			local card = self.mCardVector[self:getIndexFromTag(tagTop)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end

		-- 下
		if tagDown ~= -1 and self.mCardVector[self:getIndexFromTag(tagDown)] then
			local card = self.mCardVector[self:getIndexFromTag(tagDown)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end

		-- 左
		if tagLeft ~= -1 and self.mCardVector[self:getIndexFromTag(tagLeft)] then
			local card = self.mCardVector[self:getIndexFromTag(tagLeft)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end

		-- 右
		if tagRight ~= -1 and self.mCardVector[self:getIndexFromTag(tagRight)] then
			local card = self.mCardVector[self:getIndexFromTag(tagRight)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end
		v:setSelect(false)
		table.insert(self.mWatiDeleteCard,k,v)
	end
end 

-- 自适应 将连续的卡片消除
function GameLayer:autoCheckCard(index)
	-- 根据tag找到对应的卡片

	local tempCard  = self.mCardVector[index]

	-- 存放条件满足的卡片
 	self.mWatiDeleteCard = {}

	-- 临时表，用于储存需要遍历的卡片
	local travelBallTable = {}
	-- 点击到的卡片首先进入，模拟队列
	table.insert(travelBallTable, tempCard)

	-- 遍历临时表
	for k,v in pairs(travelBallTable) do
		local ballTag    = v:getTag()
		-- 获取目标卡片四个方向的tag值
		local tagTop   = (math.floor(ballTag / 10) + 1) * 10 + ballTag % 10
		local tagDown  = (math.floor(ballTag / 10) - 1) * 10 + ballTag % 10
		local tagLeft  = (math.floor(ballTag / 10)) * 10 + ballTag % 10 - 1
		local tagRight = (math.floor(ballTag / 10)) * 10 + ballTag % 10 + 1

		-- 处理边缘的小球
		tagTop   = tagTop          > 55 and -1 or tagTop
		tagDown  = tagDown         < 11 and -1 or tagDown
		tagLeft  = (tagLeft  % 10) < 1  and -1 or tagLeft
		tagRight = (tagRight % 10) > 5  and -1 or tagRight

		-- 上
		if tagTop ~= -1 and self.mCardVector[self:getIndexFromTag(tagTop)] then
			local card = self.mCardVector[self:getIndexFromTag(tagTop)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end

		-- 下
		if tagDown ~= -1 and self.mCardVector[self:getIndexFromTag(tagDown)] then
			local card = self.mCardVector[self:getIndexFromTag(tagDown)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end

		-- 左
		if tagLeft ~= -1 and self.mCardVector[self:getIndexFromTag(tagLeft)] then
			local card = self.mCardVector[self:getIndexFromTag(tagLeft)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end

		-- 右
		if tagRight ~= -1 and self.mCardVector[self:getIndexFromTag(tagRight)] then
			local card = self.mCardVector[self:getIndexFromTag(tagRight)]
			if card:getNumIndex() == tempCard:getNumIndex() and card:getSelect() == true then
				table.insert(travelBallTable, card)
			end
		end
		v:setSelect(false)
		table.insert(self.mWatiDeleteCard,k,v)
	end

	--
	if table.nums(self.mWatiDeleteCard) < 3 then
		-- 不满足条件，重置卡片的选中状态
		for k,v in pairs(self.mCardVector) do
			v:setSelect(true)
		end
		self.mIndex = self.mIndex + 1
		if self.mIndex <= 25 then
			self:autoCheckCard(self.mIndex)
		else
			self.mIndex = 1
			self:setLayerTouch(true)
		end		
	else
		self.mIndex = 1
		self:doWithDeleteCardVector(function ()
			self:adjustVertical(function ()
				self:autoCheckCard(self.mIndex)
			end)
			self.mWatiDeleteCard = {}
		end)
	end 

end

-- 处理检查的这些卡片
function GameLayer:dealWithWaitCard()
	
	if table.nums(self.mWatiDeleteCard) < 3 then
		-- 不满足条件，重置卡片的选中状态
		for k,v in pairs(self.mCardVector) do
			v:setSelect(true)
		end
		self:setLayerTouch(true)
	else
		self:setLayerTouch(false)
		local count = table.nums(self.mWatiDeleteCard)

		self:doWithDeleteCardVector()

		-- -- 满足条件
		-- for k,v in pairs(self.mWatiDeleteCard) do
		-- 	local tag   = v:getTag()
		-- 	local index = self:getIndexFromTag(tag)
		-- 	-- v:removeFromParent()
		-- 	-- v:setVisible(false)
		-- 	v:runAction(cc.Sequence:create(cc.FadeOut:create(0.1),cc.DelayTime:create(0.1),cc.RemoveSelf:create(),cc.CallFunc:create(function ()
				
		-- 		if k == count then
		-- 			self:setLayerTouch(true)
		-- 			self:adjustVertical()
		-- 			self.mWatiDeleteCard = {}
		-- 		end

		-- 	end)))
		-- 	self.mCardVector[index] = tag
		-- end

	end
end

-- 调整所有卡片竖直方向的位置
function GameLayer:adjustVertical(callback)
	-- 倒序遍历table
	local index = #self.mCardVector
	while (index > 0) 
	do
		-- 获得遍历的卡片
		local card = self.mCardVector[index]
		-- 判断是否已经消除成为数字
		if type(card) == "number" then
			-- 获取长度
			local dis = math.floor(card / 10)
			local den = math.floor(card % 10)
			while(dis < self.mColNum)
			do
				dis = dis + 1
				-- 目标小球的tag值
				local tagCard      = (dis - 1) * 10 + den
				local tagCardIndex = self:getIndexFromTag(tagCard)

				-- 目标小球上方球的tag值
				local tagCardTop      = dis * 10 + den
				local tagCardTopIndex = self:getIndexFromTag(tagCardTop)

				-- 处理向下的动画
				local cardTopSprite = self.mCardVector[tagCardTopIndex]
				-- 容错处理
				if cardTopSprite and type(cardTopSprite) == "userdata" then
					-- 移动动画
					transition.moveBy(cardTopSprite, {y = -cardTopSprite:getCardContentSize().height,time = 0.2})
					-- 交换数组中的索引值
					self.mCardVector[tagCardTopIndex], self.mCardVector[tagCardIndex] = self.mCardVector[tagCardIndex], self.mCardVector[tagCardTopIndex]
					-- 交换tag值
					local cardSprite = self.mCardVector[tagCardIndex]	
					if type(cardSprite) == "number" then
						cardSprite = tagCardTop
					elseif type(cardSprite) == "userdata" then
						cardSprite:setTag(tagCardTop)
					end
					-- 交换tag值
					local cardSprite = self.mCardVector[tagCardTopIndex]	
					if type(cardSprite) == "number" then
						cardSprite = tagCard
					elseif type(cardSprite) == "userdata" then
						cardSprite:setTag(tagCard)
					end				
				end
			end
		end
		index = index - 1
	end

	-- 临时变量，记录哪儿没有卡片
	local tempPositionTable = {}
	-- 上面的算法好像有点问题
	-- 暴力处理   让索引值与tag值对应
	for k,v in ipairs(self.mCardVector) do
		if type(v) == "number" then
			v = v == self:getTagFromIndex(k) and v or self:getTagFromIndex(k)
			table.insert(tempPositionTable,v)
		elseif type(v) == "userdata" then
			local tag = v:getTag()
			v:setSelect(true)
			tag = tag == self:getTagFromIndex(k) and tag or self:getTagFromIndex(k)
			v:setTag(tag)
		end
	end
	-- 补充卡片
 	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
 		local count = table.nums(tempPositionTable)
 		
 		-- 生成新卡片的算法
 		local numTable = {}
 		for i,v in ipairs(self.mCardVector) do
 			if type(v) == "userdata" then
				local num = v:getNumIndex()
				table.insert(numTable,num)
			end
 		end
 		table.sort(numTable, function (a, b)
	        if tonumber(a) > tonumber(b) then
	            return true
	        else
	            return false
	        end
    	end)
    	-- 获得随机数范围
 		local tempNum  = table.nums(numTable)
 		local smallNum = numTable[1] + 1
 		local bigNum   = numTable[tempNum] + 1

 		-- 生成新的卡片以补充
		for k,v in pairs(tempPositionTable) do
			local card = NumCard.new(math.random(bigNum,smallNum))
			local cardSize = card:getCardContentSize()
			local realPos = cc.p(
				self.mInitPos.x + cardSize.width  * (v % 10  - 1), 
				self.mInitPos.y + cardSize.height * (math.floor(v / 10) - 1)
			)
			local detalY = self.mInitPos.y + cardSize.height * ( self.mColNum - 0.5 )
			card:setPosition(
				self.mInitPos.x + cardSize.width  * (v % 10 - 1), 
				self.mInitPos.y + cardSize.height * ( self.mColNum - 0.5 )
				)
			card:setTag(v)
			card:setTouchCallback(handler(self, self.cardClick))
			self.mCardBg:addChild(card)
			self.mCardVector[self:getIndexFromTag(v)] = card

			card:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, realPos),cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
				-- 回调
				if k == count then
					if callback then
						callback()
					else
						self:autoCheckCard(self.mIndex)
					end
				end
			end)))
		end
 	end)))

end

return GameLayer