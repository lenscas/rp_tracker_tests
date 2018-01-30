local roleplays = {
	function(fun,conf)
		print("If there are no RP's return 404")
		fun:get("rp",{code = 404})
		print("Make an RP")
		local suc,res= fun:post(
			"rp",
			{
				name					=	"This is a test",
				startingStatAmount		=	25,
				startingAbilityAmount	=	3,
				description				=	"Just a simple test",
				battleSystem			=	2,
			}
		)
		local rpCode = res.json().id
		print("now that there is one. We should see a 200")
		fun:get("rp")
		print("get an non-existand RP")
		fun:get("rp/DOESNOTEXIST",{code = 404})
		print("get the roleplay we just created")
		fun:get("rp/"..rpCode)
		print("look if we can join an existing RP")
		fun:get("rp/".. rpCode.."/join")
		print("look if we can join a non-existing RP")
		fun:get("rp/DOESNOTEXIST/join",{code=404})
		print("get a config of an RP")
		fun:get("rp/"..rpCode.."/config")
		print("get a config of a nonexistand RP")
		fun:get("rp/DOESNOTEXIST.config",{code = 404})
	end
}
return roleplays
