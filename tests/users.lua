local users = {
	function(fun,conf)
		print("Test login")
		print("missing params")
		local basicCheck = {code=422}
		fun:post("login",{username="root"},{code=422,hasCreateId=false})
		print("Incorrect password")
		--fun:post("login",{username="root",password="root1"},basicCheck)
		print("Correct loggedIn")
		local suc, res = fun:post("login",{username="root",password="root"},{code=200,ignoreUserId = true})
		local userId   = res.json().userId
		fun.loggedIn=true;
		print("try to login while logged in")
		fun:post("login",{username="root",password="root"},{code = 303,isJson = false}) --we don't care if its json or not in this case
		print("Get own profile")
		fun:get("users/"..userId)
		print("Get a fake profile")
		fun:get("users/fake",{code=404})
	end
}
return users
