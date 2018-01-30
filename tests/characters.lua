
local chars = {
	function(fun,conf)
		fun.db:quickExec("characters")
		print("Get all characters in an rp without characters.")
		local rpCode = "/1234567/"
		local suc, res= fun:get("rp"..rpCode.. "characters",{code = 404})
		print("Get all characters from an nonexinstant rp")
		local suc, res= fun:get("rp/NOTEXISTING/characters",{code = 404})
		print("make a character for an RP that we joined")
		fun:post(
			"rp"..rpCode.."characters",
			{
				name		=	"some test character",
				age			=	19,
				backstory	=	"a testBackstory",
				personality	=	"likes to break stuff"
				
			}
		)
		print("get all characters in an rp")
		local suc, res= fun:get("rp"..rpCode.."characters")
		print(res.text)
		local characterCode = res.json().data.characters[1].code

		print("get a specific character")
		fun:get("rp"..rpCode.."characters/"..characterCode)
		print("update our new character. Code=",characterCode)
		fun:patch("rp"..rpCode.."characters/"..characterCode,{name="new test"},{code = 200})
	end
}
return chars
