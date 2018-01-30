local conf = require("config")
local fun  = require("functions")
local db   = require("db")

fun.db = db

local function getTestFile(name)
	return {file = dofile("tests/" .. name .. ".lua"),name = name}
end

local tests = {
	getTestFile("users"),
	getTestFile("roleplays"),
	getTestFile("characters"),
	getTestFile("battle")
}
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
