local _M = {}
function _M.getHostname()
	local f = io.popen("/bin/hostname")
	if f then
		local hostname = f:read("*a") or ""
		f:close()
		hostname = string.gsub(hostname, "\n$", "")
		return hostname
	end
end
return _M
