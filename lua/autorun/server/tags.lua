local servertags = GetConVarString("sv_tags")

if servertags == nil then
	RunConsoleCommand("sv_tags", "propellersvn_r33")
elseif not string.find(servertags, "propellersvn_r33") then
	RunConsoleCommand("sv_tags", servertags .. ",propellersvn_r33")
end