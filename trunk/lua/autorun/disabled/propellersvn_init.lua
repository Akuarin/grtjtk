
if SERVER then 

	AddCSLuaFile( "propellersvn/spawnlist/12500-propellersvn.lua" )
	AddCSLuaFile( "propellersvn/spawnlist/12501-propellers.lua" )
	AddCSLuaFile( "propellersvn/spawnlist/12502-engine.lua" )
	AddCSLuaFile( "propellersvn/spawnlist/12503-wings.lua" )
	AddCSLuaFile( "propellersvn/spawnlist/12504-misc.lua" )
	AddCSLuaFile( "propellersvn/spawnlist/12505-legacy.lua" )
	AddCSLuaFile( "propellersvn/spawnlist/12506-crap.lua" )
	AddCSLuaFile( "propellersvn/spawnlist/12507-gears.lua" )

else

	 local varAutoList = CreateClientConVar( "propellersvn_autolist", "1", true, false )

	local function PropSVNPopulate()
	if not varAutoList:GetBool() then return end

	local ListTable = file.Find( "propellersvn/spawnlist/*.lua", "LUA" )
	for _, TempList in pairs( ListTable ) do
		local ListData = util.KeyValuesToTable( CompileFile( "propellersvn/spawnlist/" .. TempList )() )

		spawnmenu.AddPropCategory( "settings/spawnlist/" .. TempList, ListData.name, ListData.contents, ListData.icon, ListData.id, ListData.parentid )
	end
end

	hook.Add( "PopulatePropMenu", "PropSVNPopulate", PropSVNPopulate )

end
