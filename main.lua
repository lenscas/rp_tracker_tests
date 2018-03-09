local args = {...}
local conf = require("config")
local fun  = require("functions")
local db   = require("db")

fun.db = db

local function getTestFile(name)
	return {file = dofile("tests/" .. name .. ".lua"),name = name}
end
local files = {
	"users",
	"roleplays",
	"characters",
	"battle",
	"modifiers",
	"actions"
}

local tests = {}
local toRun = files
if #args>0 then
	toRun = args
end
local containsUserFile = false
for key,value in ipairs(toRun) do
	table.insert(tests,getTestFile(value))
	if value =="users" then
		containsUserFile = true
	end
end
if not containsUserFile then
	table.insert(tests,1,getTestFile("users"))
end
local structFile = "rp_tracker"
local dataFile   = "rp_tracker_data"
db:readWholeFile(structFile)
db:readWholeFile(dataFile)

for fKey,file in ipairs(tests) do
	fun:colorPrint("yellow","Executing : ",file.name)
	for tkey,test in ipairs(file.file) do
		fun:colorPrint("cyan","Reset DB")
		db:runSQLfile(structFile)
		db:runSQLfile(dataFile)
		fun:colorPrint("yellow","DB got reset.")
		test(fun,conf)
	end
	fun:colorPrint("green","Passed test : ",file.name)
end
fun:colorPrint("green",[[
!!!!!!!!!!!!!!!!!!!
IT PASSED ALL TESTS
!!!!!!!!!!!!!!!!!!!
]])
