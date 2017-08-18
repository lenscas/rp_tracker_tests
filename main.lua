con = require("config")
fun = require("functions")
print("Test login")
print("missing params")
fun:post("login",{username="root"},422)
print("Incorrect password")
fun:post("login",{username="root",password="root1"},422)
print("Correct loggedIn")
local suc, res = fun:post("login",{username="root",password="root"},200)
local userId   = res.json().userId
fun.loggedIn=true;
print("try to login while logged in")
fun:post("login",{username="root",password="root"},303,false) --we don't care if its json or not in this case
print("Get own profile")
fun:get("users/"..userId,{},200)
print("Get a fake profile")
fun:get("users/fake",{},404)
print("get all RP's")
fun:get("rp",{},200)
print("Make an RP")
local suc,res= fun:post(
	"rp",
	{
		name					=	"This is a test",
		startingStatAmount		=	25,
		startingAbilityAmount	=	3,
		description				=	"Just a simple test",
		statSheetCode			=	"Fantasy"
	},
	201
)
print("look if we can get a roleplay")
fun:get("rp/"..con.rpCode,{},200)
print("get an non-existand RP")
fun:get("rp/DOESNOTEXIST",{},404)
print("look if we can join an existing RP")
fun:get("rp/".. con.rp.."/join",{},200,false)
print("look if we can join a non-existing RP")
fun:get("rp/DOESNOTEXIST/join",{},404,false)
print("get a config of an RP")
fun:get("rp/".. con.rp.."/config",{},200)
print("get a config of a nonexistand RP")
fun:get("rp/DOESNOTEXIST.config",{},404,false)
print("make a character for an RP that we joined")
fun:post(
	"rp/".. con.rpCode .."/characters",
	{
		name		=	"some test character",
		age			=	19,
		backstory	=	"a testBackstory",
		personality	=	"likes to break stuff"
		
	},
	201
)
print("get all characters in an rp")
local suc, res= fun:get("rp/".. con.rp .."/characters",{},200)

local characterCode = res.json().characters[1].code

print("get a specific character")
fun:get("rp/".. con.rp .."/characters/"..characterCode,{},200)
print("update our new character. Code=",characterCode)
fun:patch("rp/".. con.rp.."/characters/"..characterCode,{name="new test"},200)
print("get all battles in an RP")
fun:get("rp/".. con.rp.."/battles",{},200)
print("make a battle")
fun:post(
	"rp/".. con.rp.."/battles",
	{
		name = "a test battle",
		characters = {
			characterCode
		}
	},
	201
)
fun:colorPrint("green",[[
!!!!!!!!!!!!!!!!!!
IT PASSED THE TEST
!!!!!!!!!!!!!!!!!!
]])
