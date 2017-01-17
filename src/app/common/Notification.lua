--[[
    文件名：Notification.lua
    描述：自定义消息分发类，用于控制控件数据的自动更新
-- ]]

-- 消息通知类
Notification = {
    -- 消息通知保存
    mNotifyTable = {},
}

-- 事件通知的名称
EventsName = {
    eClick              = "click",
    eHightScoreNum      = "eHightScoreNum",
    eDiamond            = "eDiamond",
    eScoreAdd           = "eScoreAdd",
    eHpChange           = "eHpChange",   -- 血量改变
    eGameOver           = "eGameOver",   -- 游戏结束
    eShowBoard          = "eShowBoard",  -- 展示
    eDiamondNum         = "eDiamondNum", -- 钻石数量
    eDiamondChange      = "eDiamondChange" -- 钻石数量改变
}

--[[
    params:
    node: 绑定的结点, 不能设置为Layer中的self变量
    notifyFunc: 事件回调函数
    nameList: 事件名或者是事件列表
--]]
function Notification:registerAutoObserver(node, notifyFunc, nameList)
    local function registerOneObserver(name)
        --查找是否存在此name
        if not self.mNotifyTable[name] then
            self.mNotifyTable[name] = {}
        end

        -- 不能对相同node注册相同的事件
        for i,v in ipairs(self.mNotifyTable[name]) do
            if v.node == node then
                return
            end
        end
        table.insert(self.mNotifyTable[name], {node=node, func=notifyFunc})
    end
    
    if type(nameList) == "table" then
        for _, name in ipairs(nameList) do
            registerOneObserver(name)
        end
    else
        registerOneObserver(nameList)
    end

    -- 添加自动删除事件
    node:registerScriptHandler(function(eventType)
        if eventType == "cleanup" then
--        if eventType == "exit" then
            if type(nameList) == "table" then
                for _, name in ipairs(nameList) do
                    self:unregisterObserver(node, name)
                end
            else
                self:unregisterObserver(node, nameList)
            end
        end
    end)
end

function Notification:unregisterObserver(node, name)
    if self.mNotifyTable[name] then
        -- 移除事件对应的node
        for i,v in ipairs(self.mNotifyTable[name]) do
            if node == v.node then
                table.remove(self.mNotifyTable[name], i)
                break
            end
        end
    end
end

--[[
    参数: name:可以是字符串,也可以是字符串列表
    返回值: 
    说明: 
--]]
function Notification:postNotification(_name)
    local function _postNotification(name)
        if self.mNotifyTable[name] then
            -- 调用注册的函数
            for i, v in ipairs(self.mNotifyTable[name]) do
                if not tolua.isnull(v.node) then
                    v.func(v.node)
                end
            end
        end
    end
    
    if type(_name) == "table" then
        for i, tmpName in ipairs(_name) do
             _postNotification(tmpName)
        end
    else
        _postNotification(_name)
    end
end

function Notification:clean()
    -- 清空所有通知消息
    self.mNotifyTable = {}
end