local Silentium = LibStub("AceAddon-3.0"):NewAddon("Silentium", "AceConsole-3.0", "AceHook-3.0")

function Silentium:OnInitialize()
  self.errors = {};
  self.errors.disabled = nil;

  self.sound = {};
  self.sound.disabled = false;
  self.sound.restore = nil;

  self:RawHookScript(UIErrorsFrame, "OnEvent", function(...) self:OnEvent(...) end);

  self:RegisterChatCommand("e", "DisableErrors");
  self:RegisterChatCommand("r", "DisableReadyErrors");
  self:RegisterChatCommand("s", "ToggleSound");
end

function Silentium:ToggleSound()
  self.sound.disabled = not self.sound.disabled;
  if (self.sound.disabled) then
    self.sound.restore = GetCVar("Sound_EnableSFX");
    SetCVar("Sound_EnableSFX", 0);
  else
    SetCVar("Sound_EnableSFX", self.sound.restore);
  end
end

function Silentium:DisableReadyErrors()
  if (not self.errors.disabled) then
    self.errors.disabled = {
      [52] = true;
      [55] = true;
    };

    self:ScheduleEnableErrors();
  end
end

function Silentium:DisableErrors(varargs)
  if (not self.errors.disabled) then
    self.errors.disabled = {
      ["all"] = true;
    };

    for arg in varargs:gsub("[^%d%s]", ""):gmatch("%d+") do
      self.errors.disabled[tonumber(arg)] = true;
      self.errors.disabled["all"] = false;
    end

    self:ScheduleEnableErrors();
  end
end

function Silentium:ScheduleEnableErrors()
  C_Timer.After(0, function()
    self.errors.disabled = nil;
  end);
end

function Silentium:OnEvent(frame, event, messageType, ...)
  if (event ~= "UI_ERROR_MESSAGE"
      or not self.errors.disabled
      or (
        not self.errors.disabled[messageType]
        and not self.errors.disabled["all"])
      ) then
    self.hooks[frame].OnEvent(frame, event, messageType, ...);
  end
end