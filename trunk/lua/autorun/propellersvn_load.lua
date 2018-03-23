
if SERVER then

    AddCSLuaFile()

    AddCSLuaFile( "csl2/custom_spawnlist.lua" )
    AddCSLuaFile( "csl2/vgui/custom_tilelayout.lua" )
    AddCSLuaFile( "csl2/vgui/custom_contentcontainer.lua" )

end

if CLIENT then

	include( "csl2/vgui/custom_tilelayout.lua" )
	include( "csl2/vgui/custom_contentcontainer.lua" )

	include( "csl2/custom_spawnlist.lua" )

	-- custom propellersvn spawnlists
	spawnmenu.AddCustomSpawnlistNode( "Propeller Model Pack", "materials/settings/spawnlist/propellersvn/", "icon16/asterisk_orange.png", {
	    OnNodeSelected = function( self )
	        local parent = self:GetParentNode()

	        parent.LastActiveNode = self
	    end
	} )

end