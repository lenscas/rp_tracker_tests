local acts = {
	function(fun,conf)
		fun.db:quickExec{"roleplay","characters","battle","actions"}
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
		if not deltas.data.deltas then
			for k,v in pairs(deltas.data) do
				print(k,v)
			end
			error("no deltas")
		end
		fun:printTable(deltas.data)
		for k,v in pairs(deltas.data.deltas) do print(k,v) end
		for k,v in pairs(deltas.data.deltas[1]) do print(k,v) end
		fun:generateGetTests{
			urlParts     = {"rp","rpCode","battles","battleId","env"},
			urlData      = {rpCode = "1234567",battleId = 1},
			requiredData = deltas.data.deltas,
			method       = fun.put
		}
		print("next turn")
		fun:generateGetTests{
			urlParts     = {"rp","rpCode","battles","battleId","nextTurn"},
			urlData      = {rpCode = "1234567",battleId=1},
			requiredData = {},
			method       = fun.post,
			checkData    = {
				correct = {
					code        = 201,
					hasCreateId = false
				}
			}
		}
		--[[
		fun:generateGetTests{
			urlParts     = {"rp","rpCode","battles","battleId","env"},
			urlData      = {rpCode = "1234567",battleId = 1},
			requiredData = {{
				nextTurn = "char321",
				mode     = 3,
				code     = "someRandomCode",
				what     = 4
			}},
			method = fun.put
		}
		--]]
	end
}
return acts
