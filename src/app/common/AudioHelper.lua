

AudioHelper = {}

-- 当前播放的背景音乐文件名
AudioHelper.name = ""

function AudioHelper.getAudioName()
    return AudioHelper.name
end

-- 判断是否正在播放背景音乐
function AudioHelper.isMusicPlaying()
    return audio.isMusicPlaying()
end

-- 停止播放游戏背景音乐
function AudioHelper.stopMusic()
    audio.stopMusic(true)
    AudioHelper.name = ""
end

-- 播放游戏背景音乐
function AudioHelper.playMusic(file, loop)
    if file and #file > 0 and file:match "[%w+.-]%.[%w+]" then
        -- 如正在播放音乐，则停止
        if AudioHelper.isMusicPlaying() then
            AudioHelper.stopMusic()
        end
        audio.playMusic(file, loop ~= false)
        AudioHelper.name = file
    end
end

function AudioHelper.pauseMusic()
    audio.pauseMusic()
end

function AudioHelper.resumeMusic()
    audio.resumeMusic()
end

-- 播放游戏音效
function AudioHelper.playEffect(file, loop)
    if file and #file > 0 and file:match "[%w+.-]%.[%w+]" then
        
        return audio.playSound(file, loop or false)
        
    end
end

function AudioHelper.stopEffect(soundId)
    print("stopEffect, soundId = ", soundId)
    if not soundId then
        return
    end
    audio.stopSound(soundId)
end

--------[[----------------播放具体音效的方法-----------------------]]------------

-- 首页背景音乐
function AudioHelper.playHomeBgMusic()
	AudioHelper.playMusic("music/homeBg.mp3", true)
end

-- 游戏背景音乐
function AudioHelper.playGameBgMusic()
	AudioHelper.playMusic("music/gameBg.mp3", true)
end

-- 游戏结束音乐
function AudioHelper.playGameOverMusic()
    AudioHelper.playMusic("music/happy.mp3", true)
end

-- 游戏点击颜色按钮音效
function AudioHelper.playShootEffect()
	local src = string.format("music/shoot.mp3")
    AudioHelper.playEffect(src)
end

-- 射击失败音效
function AudioHelper.playShootFailueEffect()
	local src = string.format("music/shoot_wrong.ogg")
    AudioHelper.playEffect(src)
end

-- 滑动选择类型音效
function AudioHelper.playSlideEffect()
	
    local index = math.random(4)
    local src = string.format("music/push%s.mp3", index)
    AudioHelper.playEffect(src)

end

-- 普通按钮音效
function AudioHelper.playButtonEffect()
	local src = string.format("music/button.mp3")
    AudioHelper.playEffect(src)
end

-- 开始按钮音效
function AudioHelper.playStartEffect()
	local src = string.format("music/start_btn.ogg")
    AudioHelper.playEffect(src)
end

-- 一组完成音效
function AudioHelper.playOneTableEffect()
	 local index = math.random(5)
    local src = string.format("music/p%s.ogg", index)
    AudioHelper.playEffect(src)
end

-- 游戏完成音效
function AudioHelper.playGameOverEffect()
	local src = string.format("music/lucy.ogg")
    AudioHelper.playEffect(src)
end

-- 物品展示的音效
function AudioHelper.playShowToolEffect()
    local src = string.format("music/show.mp3")
    AudioHelper.playEffect(src)
end

-- 数字滚动
function AudioHelper.playShowWatchEffect()
    local src = string.format("music/tap.mp3")
    AudioHelper.playEffect(src)
end





