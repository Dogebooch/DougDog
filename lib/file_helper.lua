local file_helper = {}
file_helper.__index = file_helper

-- Class method to create a new instance with a working directory
function file_helper:instanced(path)
  local base = shell.dir()
  local full_path = fs.combine(base, path)
  fs.makeDir(full_path)

  local obj = setmetatable({}, file_helper)
  obj.working_directory = full_path
  return obj
end

-- Serialize a table to file (pretty = true for textutils.serialize, false for JSON)
function file_helper:serialize(name, data, pretty)
  local file_path = fs.combine(self.working_directory, name)
  local file = fs.open(file_path, "w")
  if not file then error("Failed to open file for writing: " .. file_path, 0) end

  if pretty then
    file.write(textutils.serialize(data))
  else
    file.write(textutils.serializeJSON(data))
  end
  file.close()
end

-- Deserialize a file into a table, or return default if missing or corrupted
function file_helper:unserialize(name, default)
  local file_path = fs.combine(self.working_directory, name)
  if not fs.exists(file_path) then return default end

  local file = fs.open(file_path, "r")
  if not file then return default end

  local content = file.readAll()
  file.close()

  local success, result = pcall(textutils.unserialize, content)
  if success and type(result) == "table" then
    return result
  else
    return default
  end
end

function file_helper:exists(name)
  return fs.exists(fs.combine(self.working_directory, name))
end

function file_helper:delete(name)
  return fs.delete(fs.combine(self.working_directory, name))
end

return file_helper
