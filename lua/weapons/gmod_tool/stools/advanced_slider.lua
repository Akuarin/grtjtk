TOOL.Category = "Constraints"
TOOL.Name = "Advanced Slider"

TOOL.ClientConVar[ "entity1" ] = "example1"
TOOL.ClientConVar[ "entity2" ] = "example2"
TOOL.ClientConVar[ "axis" ] = "0 0 90"

 if ( CLIENT ) then

	language.Add( "Tool_advslider_name", "Advanced Slider" )
	language.Add( "Tool_advslider_desc", "Makes non-shitty sliders" )
	language.Add( "Tool_advslider_0", "Click a prop or something." )
	language.Add( "Tool_advslider_1", "Now click some other piece of crap." )

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
		
		-- Get client's CVars
		local width = self:GetClientNumber( "width", 1.5 )
		local material = self:GetClientInfo( "material" )
		
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
				print( constraint:GetNetworkOrigin())
				constraint:SetKeyValue(tostring( "spawnflags" ), tostring( "1"))
				
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

	if ( self:GetOperation() == 1 ) then return false end

	local iNum = self:NumObjects()

	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	local tr = {}
	tr.start = trace.HitPos
	tr.endpos = tr.start + ( trace.HitNormal * 16384 )
	tr.filter = {}
	tr.filter[ 1 ] = self:GetOwner()
	if ( IsValid( trace.Entity ) ) then
		tr.filter[ 2 ] = trace.Entity
	end
	
	local tr = util.TraceLine( tr )
	if ( !tr.Hit ) then
		self:ClearObjects()
		return
	end
	
	-- Don't try to constrain world to world
	if ( trace.HitWorld && tr.HitWorld ) then
		self:ClearObjects()
		return
	end
	
	if ( IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then
		self:ClearObjects()
		return
	end
	if ( IsValid( tr.Entity ) && tr.Entity:IsPlayer() ) then
		self:ClearObjects()
		return
	end

	local Phys2 = tr.Entity:GetPhysicsObjectNum( tr.PhysicsBone )
	self:SetObject( 2, tr.Entity, tr.HitPos, Phys2, tr.PhysicsBone, trace.HitNormal )
	
	if ( CLIENT ) then
		self:ClearObjects()
		return true
	end
	
	local width = self:GetClientNumber( "width", 1.5 )
	local material = self:GetClientInfo( "material" )
		
	-- Get information we're about to use
	local Ent1, Ent2 = self:GetEnt( 1 ), self:GetEnt( 2 )
	local Bone1, Bone2 = self:GetBone( 1 ), self:GetBone( 2 )
	local LPos1, LPos2 = self:GetLocalPos( 1 ),	self:GetLocalPos( 2 )

	local constraint, rope = constraint.Slider( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, width, material )

	undo.Create( "Slider" )
		undo.AddEntity( constraint )
		if ( IsValid( rope ) ) then undo.AddEntity( rope ) end
		undo.SetPlayer( self:GetOwner() )
	undo.Finish()
	
	self:GetOwner():AddCleanup( "ropeconstraints", constraint )
	self:GetOwner():AddCleanup( "ropeconstraints", rope )

	-- Clear the objects so we're ready to go again
	self:ClearObjects()
	
	return true

end

function TOOL:Reload( trace )

	if ( !IsValid( trace.Entity ) || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end

	return constraint.RemoveConstraints( trace.Entity, "Slider" )
	
end

function TOOL:Holster()

	self:ClearObjects()

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.slider.help" } )
	
	CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "slider", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	CPanel:AddControl( "TextBox", { Label = "First Entity", Command = "advanced_slider_entity1", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Second Entity", Command = "advanced_slider_entity2", MaxLenth = "20" } )
	CPanel:AddControl( "TextBox", { Label = "Slider Axis", Command = "advanced_slider_axis", MaxLenth = "20" } )

end
