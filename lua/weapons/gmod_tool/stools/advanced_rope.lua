TOOL.Category = "Constraints"
TOOL.Name = "Advanced Rope"

TOOL.ClientConVar[ "entity1" ] = "examplerope1"
TOOL.ClientConVar[ "entity2" ] = "examplerope2"
TOOL.ClientConVar[ "attachpoint" ] = "0 0 0"
TOOL.ClientConVar[ "spawnflags" ] = "0"

 if ( CLIENT ) then

	language.Add( "Tool.advanced_rope.name", "Advanced Rope" )
	language.Add( "Tool.advanced_rope.desc", "Makes non-shitty ropes." )
	language.Add( "Tool.advanced_rope.0", "Click on the first entity." )
	language.Add( "Tool.advanced_rope.1", "Now click something else." )

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
		
		local constraint = ents.Create( "phys_lengthconstraint" )
			if constraint:IsValid() then
				constraint:SetPos(trace.HitPos)
				
				constraint:SetKeyValue(tostring( "attach1" ), tostring(self:GetClientInfo( "entity1" )))
				constraint:SetKeyValue(tostring( "attach2" ), tostring( self:GetClientInfo( "entity2" )))
				constraint:SetKeyValue(tostring( "attachpoint" ), tostring(trace.HitPos))
				print( Ent2:GetNetworkOrigin())
				constraint:SetKeyValue(tostring( "constraintsystem" ), tostring(systemtest))
				
			end
			
			constraint:Spawn()
			constraint:Activate()

		undo.Create( "Advanced Rope" )
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

	return constraint.RemoveConstraints( trace.Entity, "Advanced rope" )
	
end

function TOOL:Holster()

	self:ClearObjects()

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "TextBox", { Label = "First Entity", Command = "advanced_rope_entity1", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Second Entity", Command = "advanced_rope_entity2", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Rope Attach Point", Command = "advanced_rope_attachpoint", MaxLenth = "20" } )
	CPanel:AddControl( "ComboBox", { Label = "Spawn Flags", Options = list.Get( "RopeSpawnFlags" ) } )
	
end

list.Set( "RopeSpawnFlags", "Collide", { advanced_rope_spawnflags = "0" } )
list.Set( "RopeSpawnFlags", "No Collide Until Break", { advanced_rope_spawnflags = "1" } )
list.Set( "RopeSpawnFlags", "Keep Rigid", { advanced_rope_spawnflags = "2" } )
list.Set( "RopeSpawnFlags", "No Collide Until Break and Keep Rigid", { advanced_rope_spawnflags = "3" } )