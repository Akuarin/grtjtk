TOOL.Category = "Constraints"
TOOL.Name = "Advanced Slider"

TOOL.ClientConVar[ "entity1" ] = "example1"
TOOL.ClientConVar[ "entity2" ] = "example2"
TOOL.ClientConVar[ "axis" ] = "0 0 90"
TOOL.ClientConVar[ "friction" ] = "0"
TOOL.ClientConVar[ "spawnflags" ] = "0"

 if ( CLIENT ) then

	language.Add( "Tool.advanced_slider.name", "Advanced Slider" )
	language.Add( "Tool.advanced_slider.desc", "Makes non-shitty sliders" )
	
	language.Add( "Tool.advanced_slider.desc2", "How to use this tool: \n	1. Spawn two props.\n	2. Use the console command 'ent_setname <somename>' on each prop while looking at them.\n	3. Type the entity names you chose in the text boxes labelled 'First Entity' and 'Second Entity'.\n	4. Set any slider options you want to use.\n	5. Shoot the tool at wherever you want the slider origin to be and a second time to complete the slider.\n	\n	If you want to slider to the world, omit one of the entity names in the text box.\n" )
	
	language.Add( "Tool.advanced_slider.0", "Set your entity names in the console before using the tool!" )
	language.Add( "Tool.advanced_slider.1", "Now click some other piece of crap." )

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
		
		local constraint = ents.Create( "phys_slideconstraint" )
			if constraint:IsValid() then
				constraint:SetPos(trace.HitPos)
				
				constraint:SetKeyValue(tostring( "attach1" ), tostring(self:GetClientInfo( "entity1" )))
				constraint:SetKeyValue(tostring( "attach2" ), tostring( self:GetClientInfo( "entity2" )))
				constraint:SetKeyValue(tostring( "slideaxis" ), tostring( constraint:GetNetworkOrigin() + Vector(self:GetClientInfo( "axis" ))))
				--print( constraint:GetNetworkOrigin())
				constraint:SetKeyValue(tostring( "slidefriction" ), tonumber(self:GetClientInfo( "friction" ) * 4))
				constraint:SetKeyValue(tostring( "spawnflags" ), tonumber(self:GetClientInfo( "spawnflags" )))
				
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
	CPanel:AddControl( "Label", { Text = "2. Use the console command 'ent_setname <somename>' on each prop while looking at them." } )
	CPanel:AddControl( "Label", { Text = "3. Type the entity names you chose in the text boxes labelled 'First Entity' and 'Second Entity'.\n	4. Set any slider options you want to use." } )
	CPanel:AddControl( "Label", { Text = "5. Shoot the tool at wherever you want the slider origin to be and a second time to complete the slider.\n\n	If you want to slider to the world, omit one of the entity names in the text box." } )
	
	--CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "slider", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	CPanel:AddControl( "TextBox", { Label = "First Entity", Command = "advanced_slider_entity1", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Second Entity", Command = "advanced_slider_entity2", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Slider Axis", Command = "advanced_slider_axis", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Slider Friction", Command = "advanced_slider_friction", MaxLenth = "20" } )
	CPanel:AddControl( "ComboBox", { Label = "Spawn Flags", Options = list.Get( "SliderSpawnFlags" ) } )

end

list.Set( "SliderSpawnFlags", "Collide", { advanced_slider_spawnflags = "0" } )
list.Set( "SliderSpawnFlags", "No Collide Until Break", { advanced_slider_spawnflags = "1" } )
list.Set( "SliderSpawnFlags", "Limit Endpoints (use in conjunction with slider axis)", { advanced_slider_spawnflags = "2" } )
list.Set( "SliderSpawnFlags", "No Collide Until Break and Limit Endpoints", { advanced_slider_spawnflags = "3" } )