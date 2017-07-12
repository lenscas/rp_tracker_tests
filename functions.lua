local funcs = {}
funcs.http      = require('requests')
funcs.config    = require("config")
funcs.cookies   = nil
funcs.colors    = {
	red     = "\27[31m",
	green   = "\27[32m",
	default = "\27[39m"
}
--this creates the whole url that will be used
function funcs:constructURL(url)
	return self.config.proto .. "://" .. self.config.host .. "/api/" .. url
end
function funcs:constructData(data)
	local dataTable = {}
	for key,value in pairs(data) do
		table.insert(dataTable,key .. "=" .. value)
	end
	return table.concat(dataTable,";")
end
--this function makes the request
function funcs:doRequest(method,url,data)
	--print(data)
	local sendData = {
		url     =  self:constructURL(url),--"http://httpbin.org/post",--self:constructURL(url),--,
		data    = data,
		form    = data,
		cookies = self.cookies,
		headers = {["Content-type"] = "application/json"}
	}
	print("making a request for : ",sendData.url)
	local responce = self.http[method](sendData)
	if responce.headers["set-cookie"] then
		self.cookies = responce.headers["set-cookie"]
	end
	return responce
end
function funcs:colorPrint(color,...)
	io.write(self.colors[color])
	io.write(unpack({...}))
	io.write(self.colors.default)
	io.write("\n")
end
--this function checks if the responce was what was expected
function funcs:check(responce,expectedCode,isJson,check)
	isJson = isJson==nil or isJson --if json==nil, json=true. if json==false json=false. else json=true
	if responce.status_code ~= expectedCode then
		self:colorPrint("red","It is not the correct code. Expected: " .. expectedCode .. " got " .. responce.status_code)
		print("responce : ",responce.text)
		error("\a test")
	end
	if isJson then
		local jsonData,err = responce.json()
		if err then
			self:colorPrint("red","The responce was not a json format")
			print(responce.text)
			error(err)
			return false, responce,err
		end
	end
	if check then
		return check(responce,funcs),responce
	end
	self:colorPrint("green","It passed the test")
	return true,responce
end
--this function is used to get the COOKIES that are in use 
function funcs:getCookie()
	return self.cookies
end
--used to remove the cookies
function removeCookie()
	self.cookies=nil
end
--this function is used to make a POST request and check if it behaved correctly
function funcs:post(url,data,expectedCode,isJson,check)
	local responce = self:doRequest("post",url,data)
	return self:check(responce,expectedCode,isJson,check)
end
--this function is used to make a GET request and check if it behaved correctly
function funcs:get(url,data,expectedCode,isJson,check)
	local responce = self:doRequest("get",url,data)
	return self:check(responce,expectedCode,isJson,check)
end
--this function is used to make a PATCH request and check if it behaved correctly
function funcs:patch(url,data,expectedCode,isJson,check)
	local responce = self:doRequest("patch",url,data)
	return self:check(responce,expectedCode,isJson,check)
end
return funcs
