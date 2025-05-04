--- simple_argparse.lua

local simple_argparse = {}
simple_argparse.__index = simple_argparse

function simple_argparse.new_parser(name, description)
  local self = setmetatable({}, simple_argparse)
  self.name = name
  self.description = description or ""
  self.options = {}
  self.flags = {}
  self.arguments = {}
  return self
end

function simple_argparse:add_option(name, description, default)
  self.options[name] = {description = description, default = default}
end

function simple_argparse:add_flag(short, long, description)
  self.flags[long] = {short = short, description = description}
end

function simple_argparse:add_argument(name, description, required, default)
  table.insert(self.arguments, {
    name = name,
    description = description,
    required = required,
    default = default
  })
end

function simple_argparse:usage()
  local usage_str = ("Usage: %s [options] [arguments]\n\n%s\n\nOptions:\n"):format(self.name, self.description)
  for k, v in pairs(self.options) do
    usage_str = usage_str .. ("  --%s\t%s\n"):format(k, v.description)
  end
  for k, v in pairs(self.flags) do
    usage_str = usage_str .. ("  -%s, --%s\t%s\n"):format(v.short, k, v.description)
  end
  if #self.arguments > 0 then
    usage_str = usage_str .. "\nArguments:\n"
    for _, arg in ipairs(self.arguments) do
      usage_str = usage_str .. ("  %s\t%s\n"):format(arg.name, arg.description)
    end
  end
  return usage_str
end

function simple_argparse:parse(argv)
  local parsed = {
    options = {},
    flags = {},
    arguments = {}
  }

  local i = 1
  local arg_index = 1
  while i <= argv.n do
    local arg = argv[i]
    if arg:sub(1, 2) == "--" then
      local key = arg:sub(3)
      local value = argv[i + 1]
      if self.options[key] then
        parsed.options[key] = value
        i = i + 1
      else
        error("Unknown option: --" .. key)
      end
    elseif arg:sub(1, 1) == "-" then
      local key = arg:sub(2)
      for k, v in pairs(self.flags) do
        if v.short == key then
          parsed.flags[k] = true
        end
      end
    else
      local arg_def = self.arguments[arg_index]
      if arg_def then
        parsed.arguments[arg_index] = arg
        arg_index = arg_index + 1
      else
        error("Unexpected argument: " .. arg)
      end
    end
    i = i + 1
  end

  for k, v in pairs(self.options) do
    if parsed.options[k] == nil then
      parsed.options[k] = v.default
    end
  end

  for k, v in pairs(self.flags) do
    if parsed.flags[k] == nil then
      parsed.flags[k] = false
    end
  end

  for i, arg in ipairs(self.arguments) do
    if parsed.arguments[i] == nil then
      if arg.required then
        error("Missing required argument: " .. arg.name)
      else
        parsed.arguments[i] = arg.default
      end
    end
  end

  return parsed
end

return simple_argparse
