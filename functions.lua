local cjson = require("cjson")
local funcs = {}
funcs.http      = require('requests')
funcs.config    = require("config")
funcs.cookies   = nil
funcs.loggedIn  = false
funcs.colors    = {
	red     = "\27[31m",
	green   = "\27[32m",
	default = "\27[39m",
	yellow  = "\27[33m",
	cyan    = "\27[36m"
}
local defaultCheckSettings = {
	code        = 200,
	isJson      = true,
	hasCreateId = false,
	ignoreUserId = true
}
local function mergeSettings(newOnes)
	for key,value in pairs(defaultCheckSettings) do
		if newOnes[key] == nil then
			newOnes[key] = value
		end
	end
	return newOnes
end
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
	io.write(table.unpack({...}))
	io.write(self.colors.default)
	io.write("\n")
end

--this function checks if the responce was what was expected
function funcs:check(responce,checkData)
	checkData = mergeSettings(checkData or {})
	local expectedCode     = checkData.code
	local isJson           = checkData.isJson
	local check            = checkData.check
	local hasCreateId = checkData.hasCreateId
	isJson = isJson==nil or isJson
	if responce.status_code ~= expectedCode then
		self:colorPrint("red","It is not the correct code. Expected: " .. expectedCode .. " got " .. responce.status_code)
		print("responce : ",'"'..responce.text..'"')
		error("\a test")
	end
	if isJson then
		local jsonData,err = responce.json()
		if err then
			self:colorPrint("red","The response was not a json format")
			print(responce.text)
			error(err)
			return false, responce,err
		end
		if not checkData.ignoreUserId then
			if jsonData.userId and not self.loggedIn then 
				self:colorPrint("red","User id found when not logged in!")
				error(responce.text)
			elseif (not jsonData.userId) and self.loggedIn then
				self:colorPrint("red","User id not found while logged in!")
				error(responce.text)
			end
		end
		if checkData.hasCreateId then
			if (not jsonData.id) or jsonData.id =="" or jsonData.id == cjson.null then
				self:colorPrint("red","Create id was not valid. It was ",tostring(jsonData.id))
				error(responce.text)
			end
		end
		return false,responce,err
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
function funcs:post(url,data,checkData)
	local responce = self:doRequest("post",url,data)
	checkData = checkData or {}
	checkData["code"] = checkData["code"] or 201
	if checkData["code"]==201 then
		checkData["hasCreateId"] = checkData["hasCreateId"]==nil or checkData["hasCreateId"]
	end
	return self:check(responce,checkData)
end
--this function is used to make a GET request and check if it behaved correctly
function funcs:get(url,checkData,data)
	local responce = self:doRequest("get",url,data)
	
	return self:check(responce,checkData)
end
--this function is used to make a PATCH request and check if it behaved correctly
function funcs:patch(url,data,expectedCode,isJson,check)
	local responce = self:doRequest("patch",url,data)
	return self:check(responce,checkData)
end
return funcs
