--- logging.lua

local Logging = {}
Logging.__index = Logging

Logging.LOG_LEVEL = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  FATAL = 4,
}

local current_level = Logging.LOG_LEVEL.INFO
local log_window = nil
local log_cache = {} -- store logs for later dumping if needed

function Logging.set_level(level)
  current_level = level
end

function Logging.set_window(window)
  log_window = window
end

local function log_line(level_name, title, message)
  local line = ("[%s] [%s] %s"):format(level_name, title, message)
  table.insert(log_cache, line)
  if log_window then
    log_window.scroll(1)
    log_window.setCursorPos(1, select(2, log_window.getSize()))
    log_window.write(line:sub(1, log_window.getSize()))
  end
end

function Logging.log(level, title, message)
  if level >= current_level then
    local level_name = "UNKNOWN"
    for k, v in pairs(Logging.LOG_LEVEL) do
      if v == level then level_name = k break end
    end
    log_line(level_name, title, message)
  end
end

function Logging.debug(title, message)
  Logging.log(Logging.LOG_LEVEL.DEBUG, title, message)
end

function Logging.info(title, message)
  Logging.log(Logging.LOG_LEVEL.INFO, title, message)
end

function Logging.warn(title, message)
  Logging.log(Logging.LOG_LEVEL.WARN, title, message)
end

function Logging.fatal(title, message)
  Logging.log(Logging.LOG_LEVEL.FATAL, title, message)
end

function Logging.dump_log(path)
  local handle = fs.open(path, "w")
  for _, line in ipairs(log_cache) do
    handle.writeLine(line)
  end
  handle.close()
end

function Logging.create_context(title)
  local ctx = {}
  function ctx.debug(...)
    Logging.debug(title, table.concat({...}, " "))
  end
  function ctx.info(...)
    Logging.info(title, table.concat({...}, " "))
  end
  function ctx.warn(...)
    Logging.warn(title, table.concat({...}, " "))
  end
  function ctx.fatal(...)
    Logging.fatal(title, table.concat({...}, " "))
  end
  function ctx.log(level, ...)
    Logging.log(level, title, table.concat({...}, " "))
  end
  return ctx
end

return Logging
