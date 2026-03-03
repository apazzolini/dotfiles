local hyper = { 'shift', 'cmd' }

hs.loadSpoon('AppLauncher')
spoon.AppLauncher:bindHotkeys({
  { { 'ctrl', 'a' }, 'Ghostty' },
  { { 'alt', 'n' }, 'Notion' },
  { { 'alt', 's' }, 'Spotify' },
  { { 'alt', 'g' }, 'Firefox Developer Edition' },
  { { 'alt', 'd' }, 'Discord' },
  { { 'alt', 'f' }, 'Slack' },
  { { 'alt', 'i' }, 'Alacritty' },
})

hs.loadSpoon('MiroWindowsManager')
hs.window.animationDuration = 0
spoon.MiroWindowsManager:bindHotkeys({
  up = { hyper, 'k' },
  right = { hyper, 'l' },
  down = { hyper, 'j' },
  left = { hyper, 'h' },
  fullscreen = { hyper, 'm' },
})

hs.loadSpoon('ReloadConfiguration')
spoon.ReloadConfiguration:start()

local k = hs.hotkey.modal.new('cmd-shift-ctrl', '.')
function k:entered()
  local window = hs.window.focusedWindow()
  local frame = window:screen():fullFrame().string
  hs.alert(string.format('Window: %s\r Frame: %s', window:application():path(), frame), 123)
end

k:bind('', 'escape', function()
  hs.alert.closeAll()
  k:exit()
end)

k:bind('', 'S', 'Pressed S', function()
  local window = hs.window.focusedWindow()
  local frame = window:screen():fullFrame().string
  local key = string.format('%s:%s', window:application():path(), frame)
  hs.settings.set(key, window:frame().string)
  hs.alert.closeAll()
  k:exit()
end)

hs.hotkey.bind(hyper, ',', function()
  local window = hs.window.focusedWindow()
  local frame = window:screen():fullFrame().string
  local key = string.format('%s:%s', window:application():path(), frame)
  local stored = hs.settings.get(key)

  if stored then
    window:setFrame(stored)
  end
end)
