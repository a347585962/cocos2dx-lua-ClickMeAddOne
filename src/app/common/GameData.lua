--
-- Author: wusonglin
-- Date: 2016-06-14 14:59:15
-- 存放游戏数据 单例
--

GameData = {}
function GameData:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    self.mIsTimeBar = true

    -- 砖石数量
    self.mDiamond  = cc.UserDefault:getInstance():getIntegerForKey(EventsName.eDiamond,10)

    -- 最高分
    self.mHightScore = cc.UserDefault:getInstance():getIntegerForKey(EventsName.eHightScoreNum,0)

    -- 中间的分数
    self.mScore = 0

    -- 最终的分数
    self.mLastScore = 0

    -- 血量
    self.mHp = 5

    -- 最大的数字
    self.mNumberMax = 1
    return o
end

function GameData:getInstance()
    if self.gameData == nil then
        self.gameData = self:new()
    end

    return self.gameData
end

function GameData:geleaseInstance()
	if self.gameData then
		self.gameData = nil
	end
end

-- 钻石数量增加
function GameData:diamondAdd(num)
    
    self.mDiamond = self.mDiamond + num

    cc.UserDefault:getInstance():setIntegerForKey(EventsName.eDiamond, tonumber(self.mDiamond))
    cc.UserDefault:getInstance():flush()
end

-- 钻石数量减少
function GameData:diamondSub(num)
    self.mDiamond = self.mDiamond - num
    -- 不能为负数
    self.mDiamond = self.mDiamond < 0 and 0 or self.mDiamond

    cc.UserDefault:getInstance():setIntegerForKey(EventsName.eDiamond, tonumber(self.mDiamond))
    cc.UserDefault:getInstance():flush()
end

function GameData:getDiamonNum()
    self.mDiamond = self.mDiamond < 0 and 0 or self.mDiamond
    return self.mDiamond
end

-- 设置中间过渡分数
function GameData:setScore(score)
    self.mScore = score
end

function GameData:getScore()
    return self.mScore
end

-- 设置最终分数
function GameData:setLastScore(score)
    self.mLastScore = score
end

function GameData:getLastScore()
    return self.mLastScore
end

-- 设置最高分
function GameData:setHightScore(value)
    cc.UserDefault:getInstance():setIntegerForKey(EventsName.eHightScoreNum, tonumber(value))
    cc.UserDefault:getInstance():flush()

    self.mHightScore = value
end

function GameData:getHightScore()
    return self.mHightScore 
end

-- 设置血量
function GameData:getHp()
    self.mHp = self.mHp > 0 and self.mHp or 0
    self.mHp = self.mHp < 6 and self.mHp or 5
    return self.mHp 
end

-- 恢复血量
function GameData:reviveHp()
    self.mHp = 5
end

-- 血量变化  是否增加或者减少
function GameData:subChage(isAdd)
    local detal = isAdd == true and 1 or -1
    self.mHp = self.mHp + detal 
end

-- 最大的数字
function GameData:getMaxNum()
    return self.mNumberMax
end

function GameData:setMaxNum(value)
    self.mNumberMax = value
end






