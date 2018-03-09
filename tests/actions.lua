local acts = {
	
	function(fun,conf)
		fun.db:quickExec{"characters","battle","actions"}
		print("get all actions")
		local id,res = fun:generateGetTests{
			urlParts = {"rp","rpCode","actions"},
			urlData  = {rpCode="1234567"},
			method   = fun:switch(fun.get) 
		}
		print("execute actions")
		local id,deltas = fun:generateGetTests{
			urlParts = {"rp","rpCode","battles","battleId","actions","actionId","run"},
			urlData  = {rpCode="1234567",battleId=1,actionId=res.data[1].id},
			requiredData = {
				user       = "char123",
				target     = "char321",
				autoUpdate = 0
			},
			checkData = {
				correct = {hasCreateId = false}
			},
			method = fun.post
		}
		print("save deltas")
		for k,v in pairs(deltas.data.deltas[1]) do print(k,v) end
		fun:generateGetTests{
			urlParts     = {"rp","rpCode","battles","battleId","env"},
			urlData      = {rpCode = "1234567",battleId = 1},
			requiredData = deltas.data.deltas,
			method       = fun.put
		}
	end
}
return acts
