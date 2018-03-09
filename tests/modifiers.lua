local mods = {
	function(fun,conf)
		fun.db:quickExec({"characters","battle"})
		local simpleTestData = {
			name      = "testMod",
			value     =  4,
			countDown =  -2,
			intName   =  "ATK"
		}
		print("insert modifier")
		local id = fun:generateGetTests({
			urlParts = {"rp","rpCode","characters","charCode","modifiers"},
			urlData  = {rpCode = "1234567",charCode="char123"},
			method   = fun.post,
			requiredData = simpleTestData,
			checkData = {
				missing  = {code=422},
				notFound = {code=404},
				correct  = {code=201}
			}
		})
		print(id)
		simpleTestData.intName = nil
		print("update modifier")
		fun:generateGetTests({
			urlParts = {"rp","rpCode","characters","charCode","modifiers","modId"},
			urlData  = {rpCode = "1234567",charCode="char123",modId=id},
			method   = fun.put,
			requiredData = simpleTestData,
			checkData = {
				missing  = {code=422},
				notFound = {code=404},
				correct  = {code=200}
			}
		})
		print("delete modifier")
		fun:generateGetTests({
			urlParts = {"rp","rpCode","characters","charCode","modifiers","modId"},
			urlData  = {rpCode = "1234567",charCode="char123",modId=id},
			method   = fun:switch(fun.delete)
		})
	end
}
return mods
