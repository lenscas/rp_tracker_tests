local battle = {
	function(fun,conf)
		fun.db:quickExec({"characters","battle"})
		print("get all battles in an RP that does not exist")
		fun:get("rp/DOESNOTEXIST/battles",{code=404})
		print("get all battles in an RP without battles")
		fun:get("rp/1234567/battles",{code=404})
		print("make a battle without characters")
		local suc,res = fun:post(
			"rp/1234567/battles",
			{
				name = "a test battle",
				characters = {}
			}
		)
		local id1 = res.json().id
		print(res.text)
		print("make a battle with characters")
		local suc,res = fun:post("rp/1234567/battles",{
			name = "A second test battle",
			characters = {
				"char123"
			}
		})
		local id2 = res.json().id
		
		print("get a battle without characters")
		fun:get("rp/1234567/battles/"..id1)
		print("get a battle with characters")
		fun:get("rp/1234567/battles/"..id2,{checl = function(response)
			if #response.json().data.characters ~= 1 then
				fun:printColor("red", "Not enough characters")
				error(response.text)
			end
		end})
		print("get all available battle systems")
		fun:get("system")
		print("get all battles in an rp")
		fun:get("rp/1234567/battles")
		print("get all users in a battle from an rp that does not exist(pad server only)")
		fun:get("rp/1234567/battles/"..id2.."/users",{code=422})
	end
}
return battle
