--[[
    文件名：ProgressBar
	描述：进度条
	创建人：liaoyuangang
	创建时间：2014.03.19
-- ]]

-- 进度条类型枚举
 ProgressBarType = {
    eVertical = 1,   -- 垂直进度条
    eHorizontal = 2, -- 水平进度条
 }

local ProgressBar = class("ProgressBar", function()
    return cc.Layer:create()
end)

--[[
    {
        bgImage = "",   -- 背景图片
        barImage = "",  -- 进度图片
        currValue = 1,  -- 当前进度
        maxValue = 100, -- 最大值
        contentSize = null, -- 进度条的大小，默认为背景图或进度图片大小
        barType = ProgressBarType.eHorizontal, -- 进度条类型，水平进度／垂直进度条，取值为ProgressBarType的枚举值。
        needLabel = true,   -- 是否需要文字显示进度
        needHideBg = false, -- 是否需要隐藏背景
        percentView = true  -- 以百分比方式显示(needLabel == true有效)
        font = _FONT_NUMBER, -- 文本的数字
        size = 20, -- 文本的大小
        color = Enums.Color.eWhite, 文本颜色
        shadowColor = nil,  -- 阴影的颜色，可选设置，不设置表示不需要阴影
        outlineColor = nil, -- 描边的颜色，可选设置，不设置表示不需要描边
        outlineSize = 1,    -- 描边的大小，可选设置，如果 outlineColor 为nil，该参数无效，默认为 1
    }
--]]
function ProgressBar:ctor(params)
    self.mCurrValue = params.currValue or 0
    self.mMaxValue = params.maxValue or 100
    self.mBarType = params.barType or ProgressBarType.eHorizontal

    local function getImageSize(filename, textureResType, texturePlist)
        local frameCache = cc.SpriteFrameCache:getInstance()
        local frame = frameCache:getSpriteFrame(filename)
        if textureResType == ccui.TextureResType.plistType then
            if not frame then
                if not texturePlist then
                    print("ui.getImageSize not found SpriteFrame:", filename)
                    return cc.size(0, 0)
                end
                frameCache:addSpriteFrames(texturePlist)
                frame = frameCache:getSpriteFrame(filename)
            end
            return frame:getOriginalSizeInPixels()
        else
            if frame then
                return frame:getOriginalSizeInPixels()
            else
                return cc.Director:getInstance():getTextureCache():addImage(filename):getContentSizeInPixels()
            end
        end
    end

    -- 设置进度条的大小
    if params.contentSize then
        self.mSize = params.contentSize
    elseif params.bgImage then
        self.mSize = getImageSize(params.bgImage)
    elseif params.barImage then
        self.mSize = getImageSize(params.barImage)
    else
        self.mSize = cc.size(100, 20)   -- 如果没有背景图片时的默认大小，暂时也没有多大用处。
    end
    self:setContentSize(self.mSize)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:ignoreAnchorPointForPosition(false)

    -- 创建进度条背景 并设置进度条的大小
    if (params.bgImage) then
        self.mBgSprite = cc.Sprite:create(params.bgImage)
        self.mBgSprite:setContentSize(self.mSize)
        self.mBgSprite:setPosition(cc.p(self.mSize.width / 2, self.mSize.height / 2))
        self:addChild(self.mBgSprite)
    end

    -- 创建进度bar
    if (params.barImage) then
        local barImgSize = getImageSize(params.barImage)
        local barScaleX = self.mSize.width / barImgSize.width
        local barScaleY = self.mSize.height / barImgSize.height

        local tempSprite = cc.Sprite:create(params.barImage)
        self.mProgressTimer = cc.ProgressTimer:create(tempSprite)
        self.mProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        if (self.mBarType == ProgressBarType.eHorizontal) then
            self.mProgressTimer:setMidpoint(cc.p(0, 0))
            self.mProgressTimer:setBarChangeRate(cc.p(1, 0))
        else
            self.mProgressTimer:setMidpoint(cc.p(0, 0))
            self.mProgressTimer:setBarChangeRate(cc.p(0, 1))
        end
        self.mProgressTimer:setPosition(cc.p(self.mSize.width / 2, self.mSize.height / 2))
        self.mProgressTimer:setScaleX(barScaleX)
        self.mProgressTimer:setScaleY(barScaleY)
        self:addChild(self.mProgressTimer)
    end

    -- 创建显示进度的label
    if (params.needLabel) then

    end

    local function onNodeEvent(event)
        if "enter" == event then
            self:doProgress(self.mCurrValue, 0)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function ProgressBar:getProgressStr()
    local textStr = string.format("%d / %d", self.mCurrValue, self.mMaxValue)
    if self.mPercentView == true then
        local percent = math.ceil(self.mCurrValue / self.mMaxValue * 100)
        textStr = string.format("%d%%",percent)
    end
    return textStr
end

--[[
-- 设置进度值
-- currValue: 当前进度
-- duration: 进度效果的持续时间
--]]
function ProgressBar:doProgress(currValue, duration)
    local fromProg = 0;
    -- 计算进度条的起始位置和终止位置
    local toProg = 0;
    if self.mMaxValue > 0 then
        fromProg = (self.mCurrValue / self.mMaxValue) * 100
        toProg = (currValue / self.mMaxValue) * 100
    end
    toProg = math.min(100, toProg)

    if toProg < fromProg then 
        --fromProg = 0
        fromProg = self.mProgressTimer:getPercentage()
    end
    if self.mAction then
        self.mProgressTimer:stopAction(self.mAction)
        --fromProg = self.mProgressTimer:getPercentage()

        if (self.mProgressLabel) then
            local progStr = self:getProgressStr()
            self.mProgressLabel:setString(progStr)
        end
    end

    -- 创建action对象
    if (self.mProgressTimer) then
        local actionArray = {
            cc.ProgressFromTo:create(duration or 0.5, fromProg, toProg),
            cc.CallFunc:create(function()
                if (self.mProgressLabel) then
                    local progStr = self:getProgressStr()
                    self.mProgressLabel:setString(progStr)
                end
                self.mAction = nil
            end),
        }
        self.mAction = cc.Sequence:create(actionArray)
        self.mProgressTimer:runAction(self.mAction)
    end
    -- 更新mCurrValue
    if (currValue < 0) then
        self.mCurrValue = 0
    else
        self.mCurrValue = currValue
    end
end

--[[
-- 获取进度条的当前进度值
-- 返回 mCurrValue
 ]]
function ProgressBar:getCurrValue()
    return self.mCurrValue
end

--[[
-- 设置进度值
-- currValue: 需要设置的当前进度
 ]]
function ProgressBar:setCurrValue(currValue, time)
    time = time or 0.3
    self:doProgress(currValue, time)
end

--[[
-- 设置最大进度值
-- currMaxValue: 需要设置最大进度值
 ]]
function ProgressBar:setMaxValue(currMaxValue)
    self.mMaxValue = currMaxValue
    local progStr = self:getProgressStr()
    if not tolua.isnull(self.mProgressLabel) then
        self.mProgressLabel:setString(progStr)
    end
end
--[[
--进度条动作
-- ]]
function ProgressBar:runAction(action)
    self.mProgressTimer:runAction(action)
end

return ProgressBar
