local config = require("config")
local con  = require("luasql.mysql").mysql():connect(table.unpack(config.db))
local db = {
	files = {}
}
function db:quickExec(files)
	if type(files) ~= "table" then
		files = {files}
	end
	for key,filename in pairs(files) do
		self:readWholeFile(filename)
		self:runSQLfile(filename)
	end
end
function db:readWholeFile(fileName)
	if self.files[filename] then
		return
	end
	local file = assert(io.open(config.SQLFolder.."/"..fileName..".sql","rb"))
	local data = file:read("*all")
	local statements = {}
	file:close()
	for statement in data:gmatch("[^;]+") do
		if not (
				string.sub(statement,2,3)=="/*" and
				string.sub(statement,-2)=="*/"
			) and
			string.len(statement)>1
		then
			table.insert(statements,statement)
		end
	end
	self.files[fileName] = statements
end
function db:runSQLfile(fileName)
	local file = self.files[fileName] or error("File "..fileName.." not loaded.")
	for key,statement in ipairs(file) do
		local res = con:execute(statement)
		if res==nil then
			con:rollback()
			error("something wend wrong executing : " .. statement)
		end
	end
end
function db:getDB()
	return con
end
return db
