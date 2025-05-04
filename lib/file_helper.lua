--- file_helper.lua

local FileHelper = {}
FileHelper.__index = FileHelper

function FileHelper:exists(name)
  return fs.exists(fs.combine(self.working_directory, name))
end

function FileHelper:serialize(name, data, overwrite)
  local full_path = fs.combine(self.working_directory, name)
  if not overwrite and fs.exists(full_path) then
    error("File exists and overwrite not set", 0)
  end
  local handle = fs.open(full_path, "w")
  handle.write(textutils.serialize(data))
  handle.close()
end

function FileHelper:unserialize(name, default)
  local full_path = fs.combine(self.working_directory, name)
  if not fs.exists(full_path) then
    return default
  end
  local handle = fs.open(full_path, "r")
  local contents = handle.readAll()
  handle.close()
  local ok, result = pcall(textutils.unserialize, contents)
  if ok and type(result) == "table" then
    return result
  end
  return default
end

function FileHelper:delete(name)
  local full_path = fs.combine(self.working_directory, name)
  if fs.exists(full_path) then
    fs.delete(full_path)
  end
end

local function instanced(path)
  local obj = setmetatable({}, FileHelper)
  obj.working_directory = path ~= "" and path or "."
  return obj
end

return {
  instanced = instanced
}
