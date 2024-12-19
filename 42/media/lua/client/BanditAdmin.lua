BanditAdmin = BanditAdmin or {}

BanditAdmin.AdminMessage = function(text, x, y, z)
	-- print (text)
end

Events.OnAdminMessage.Add(BanditAdmin.AdminMessage)