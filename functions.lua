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
		print(checkData["hasCreateId"])
		checkData["hasCreateId"] = checkData["hasCreateId"]==nil or checkData["hasCreateId"]
		print(checkData["hasCreateId"])
	end
	return self:check(responce,checkData)
end
--this function is used to make a GET request and check if it behaved correctly
function funcs:get(url,checkData,data)
	print(checkData)
	local responce = self:doRequest("get",url,data)
	
	return self:check(responce,checkData)
end
--this function is used to make a PATCH request and check if it behaved correctly
function funcs:patch(url,data,expectedCode,isJson,check)
	local responce = self:doRequest("patch",url,data)
	return self:check(responce,checkData)
end
function funcs:put(url,data,checkData)
	local response = self:doRequest("put",url,data)
	return self:check(response,checkData)
end
function funcs:delete(url,checkData,data)
	local response = self:doRequest("delete",url,data)
	return self:check(response,checkData)
end
function funcs:switch(func)
	return function(funcs,url,data,checkData)
		return func(funcs,url,checkData,data)
	end
end
function funcs:generateGetTests(data)
	data.checkData = data.checkData or {}
	data.checkData.missing  = data.checkData.missing  or {code=422}
	data.checkData.notFound = data.checkData.notFound or {code = 404}
	data.checkData.correct  = data.checkData.correct  or {code = 200} 
	
	data.urlData = data.urlData or {}
	data.requiredData = data.requiredData or {}
	local possibleUrls = {
		{
			url = {},
			isCorrect = true
		}
	}
	print("after safe set?")
	for k,v in pairs(data.requiredData) do print(k,v) end
	for ukey,urlPart in ipairs(data.urlParts) do
		if not data.urlData[urlPart] then
			for newKey,newUrl in pairs(possibleUrls) do
				table.insert(newUrl.url,urlPart)
			end
		else
			local oldSize = #possibleUrls
			for i=1,oldSize do
				local urlCopy = {}
				for key,value in ipairs(possibleUrls[i].url) do
					table.insert(urlCopy,value)
				end
				table.insert(possibleUrls,oldSize,{url = urlCopy,isCorrect = possibleUrls[i].isCorrect})
			end
			local doBS = true
			for newKey,newUrl in ipairs(possibleUrls) do
				if doBS then
					table.insert(newUrl.url,"DOESNOTEXISTS")
					newUrl.isCorrect = false
				else
					table.insert(newUrl.url,data.urlData[urlPart])
				end
				doBS = not doBS
			end
		end
	end
	local correctOne = nil
	for key,value in pairs(possibleUrls) do 
		local url = table.concat(value.url,"/")
		if value.isCorrect then
			if correctOne then
				self:colorPrint("red","Already have a correct one!")
				print(correctOne)
				print(url)
				error()
			end
			correctOne = url
		else
			print("Make a BS call")
			data.method(self,url,data.requiredData,data.checkData.notFound)
		end
	end
	if not correctOne then
		self:colorPrint("red","no correct url found?")
		error()
	end
	local lastK,lastV = nil
	for key,value in pairs(data.requiredData) do
		if lastK then
			data.requiredData[lastK] = lastV
		end
		lastK,lastV = key,value
		data.requiredData[key]= nil
		print("make a request while missing",key)
		data.method(self,correctOne,data.requiredData,data.checkData.missing)
	end
	if lastK ~= nil then
		data.requiredData[lastK] = lastV
	end
	print("Make a real call")
	for k,v in pairs(data.requiredData) do print(k,v) end
	local suc,res = data.method(self,correctOne,data.requiredData,data.checkData.correct)
	if not suc then
		self:colorPrint("red","something wend wrong")
		error(res)
	end
	local data,err = res.json()
	if not err then
		return data.id,data,res
	end
	return res
end
return funcs
