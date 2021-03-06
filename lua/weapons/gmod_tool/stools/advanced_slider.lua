TOOL.Category = "Constraints"
TOOL.Name = "Advanced Slider"

TOOL.ClientConVar[ "entity1" ] = "example1"
TOOL.ClientConVar[ "entity2" ] = "example2"
TOOL.ClientConVar[ "axis" ] = "0 0 90"
TOOL.ClientConVar[ "friction" ] = "0"
TOOL.ClientConVar[ "spawnflags" ] = "0"
TOOL.ClientConVar[ "forcelimit" ] = "0"
TOOL.ClientConVar[ "torquelimit" ] = "0"
TOOL.ClientConVar[ "breaksound" ] = "Plastic_Box.Break"
TOOL.ClientConVar[ "teleportfollowdistance" ] = "0"

 if ( CLIENT ) then

	language.Add( "Tool.advanced_slider.name", "Advanced Slider" )
	language.Add( "Tool.advanced_slider.desc", "Makes non-shitty sliders." )
	language.Add( "Tool.advanced_slider.0", "Click on the first entity." )
	language.Add( "Tool.advanced_slider.1", "Now click something else." )

end

function TOOL:LeftClick( trace )

	if ( IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return end
	
	-- If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local iNum = self:NumObjects()

	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	self:SetOperation( 1 )
	
	if ( iNum > 0 ) then

		if ( CLIENT ) then
			self:ClearObjects()
			return true
		end
		
		-- Get information we're about to use
		local Ent1, Ent2 = self:GetEnt( 1 ), self:GetEnt( 2 )
		local Bone1, Bone2 = self:GetBone( 1 ), self:GetBone( 2 )
		local LPos1, LPos2 = self:GetLocalPos( 1 ), self:GetLocalPos( 2 )
		
		Ent1:SetKeyValue(tostring( "targetname" ), tostring(self:GetClientInfo( "entity1" )))
		Ent2:SetKeyValue(tostring( "targetname" ), tostring(self:GetClientInfo( "entity2" )))
		
		local constraint = ents.Create( "phys_slideconstraint" )
			if constraint:IsValid() then
				constraint:SetPos(trace.HitPos)
				
				constraint:SetKeyValue(tostring( "attach1" ), tostring(self:GetClientInfo( "entity1" )))
				constraint:SetKeyValue(tostring( "attach2" ), tostring( self:GetClientInfo( "entity2" )))
				constraint:SetKeyValue(tostring( "slideaxis" ), tostring( constraint:GetNetworkOrigin() + Vector(self:GetClientInfo( "axis" ))))
				--print( constraint:GetNetworkOrigin())
				constraint:SetKeyValue(tostring( "slidefriction" ), tonumber(self:GetClientInfo( "friction" ) * 4))
				constraint:SetKeyValue(tostring( "spawnflags" ), tonumber(self:GetClientInfo( "spawnflags" )))
				constraint:SetKeyValue(tostring( "forcelimit" ), tonumber(self:GetClientInfo( "forcelimit" )))
				constraint:SetKeyValue(tostring( "torquelimit" ), tonumber(self:GetClientInfo( "torquelimit" )))
				constraint:SetKeyValue(tostring( "breaksound" ), tostring( self:GetClientInfo( "breaksound" )))
				constraint:SetKeyValue(tostring( "teleportfollowdistance" ), tonumber( self:GetClientInfo( "teleportfollowdistance" )))
				
			end
			
			constraint:Spawn()
			constraint:Activate()

		undo.Create( "Advanced Slider" )
			undo.AddEntity( constraint )
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
		self:GetOwner():AddCleanup( "ropeconstraints", constraint )

		-- Clear the objects so we're ready to go again
		self:ClearObjects()
		
	else
	
		self:SetStage( iNum + 1 )
		
	end
	
	return true

end

function TOOL:RightClick( trace )

	return

end

function TOOL:Reload( trace )

	if ( !IsValid( trace.Entity ) || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end

	return constraint.RemoveConstraints( trace.Entity, "Advanced Slider" )
	
end

function TOOL:Holster()

	self:ClearObjects()

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Label", { Text = "How to use this tool: \n	1. Spawn two props." } )
	CPanel:AddControl( "Label", { Text = "2. Change the names in 'First Entity' and 'Second Entity' to avoid conflicts." } )
	CPanel:AddControl( "Label", { Text = "3. Set any slider options you want to use." } )
	CPanel:AddControl( "Label", { Text = "4. Shoot the tool at whichever two entities you want slidered. The slider origin will be on the first prop.\n\n	If you want to slider to the world, omit one of the entity names in the text box." } )
	
	--CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "slider", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	CPanel:AddControl( "TextBox", { Label = "First Entity", Command = "advanced_slider_entity1", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Second Entity", Command = "advanced_slider_entity2", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Slider Axis", Command = "advanced_slider_axis", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Slider Friction", Command = "advanced_slider_friction", MaxLenth = "20" } )
	CPanel:AddControl( "ComboBox", { Label = "Spawn Flags", Options = list.Get( "SliderSpawnFlags" ) } )
	CPanel:AddControl( "TextBox", { Label = "Slider Force Limit", Command = "advanced_slider_forcelimit", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Slider Torque Limit", Command = "advanced_slider_torquelimit", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Break Sound", Command = "advanced_slider_breaksound", MaxLenth = "80" } )
	CPanel:AddControl( "TextBox", { Label = "Teleport Follow Dist", Command = "advanced_slider_teleportfollowdistance", MaxLenth = "20" } )
	
end

list.Set( "SliderSpawnFlags", "Collide", { advanced_slider_spawnflags = "0" } )
list.Set( "SliderSpawnFlags", "No Collide Until Break", { advanced_slider_spawnflags = "1" } )
list.Set( "SliderSpawnFlags", "Limit Endpoints (use in conjunction with slider axis)", { advanced_slider_spawnflags = "2" } )
list.Set( "SliderSpawnFlags", "No Collide Until Break and Limit Endpoints", { advanced_slider_spawnflags = "3" } )