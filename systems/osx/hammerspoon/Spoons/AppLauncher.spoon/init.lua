--- === AppLauncher ===
---
--- Simple spoon for launching apps with single letter hotkeys.
---
--- Example configuration using SpoonInstall.spoon:
--- ```
--- spoon.SpoonInstall:andUse("AppLauncher", {
---   hotkeys = {
---     c = "Calendar",
---     d = "Discord",
---     f = "Firefox Developer Edition",
---     n = "Notes",
---     p = "1Password 7",
---     r = "Reeder",
---     t = "Kitty",
---     z = "Zoom.us",
---   }
--- })
--- ```
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/AppLauncher.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/AppLauncher.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppLauncher"
obj.version = "1.0.0"
obj.author = "Mathias Jean Johansen <mathias@mjj.io>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "ISC - https://opensource.org/licenses/ISC"

--- AppLauncher.modifiers
--- Variable
--- Modifier keys used when launching apps
---
--- Default value: `{"ctrl", "alt"}`
obj.modifiers = {"ctrl", "alt"}

--- AppLauncher:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for AppLauncher
---
--- Parameters:
---  * mapping - A table containing single characters with their associated app
function obj:bindHotkeys(mapping)
  for _, binding in ipairs(mapping) do
    local modifier = binding[1][1]
    local key = binding[1][2]
    local app = binding[2]
    hs.hotkey.bind(modifier, key, function()
      local existing_app = hs.application.get(app)
      if existing_app and existing_app:isFrontmost() then
        existing_app:hide()
      else
        hs.application.launchOrFocus(app)
      end
    end)
  end
end

return obj
