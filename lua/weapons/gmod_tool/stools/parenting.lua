
TOOL.Category		= "Constraints"
TOOL.Name			= "#Parenting"
TOOL.Command		= nil
TOOL.ConfigName		= nil

if CLIENT then
	language.Add( "Tool_Parenting", "Parenting" )
	language.Add( "Tool_Parenting_name", "Parenting stool" )
	language.Add( "Tool_Parenting_desc", "Make parenting between two entity" )
	language.Add( "Tool_Parenting_0", "Primary: Set Parent two entity Secondary: Parent player to entity Reload: Clear parent" )
	language.Add( "Tool_Parenting_1", "Click on the second entity" )
	language.Add( "Undone_Parenting", "Undone Parent" )
end

function TOOL:LeftClick( trace )

	if (trace.Entity:IsValid() && trace.Entity:IsPlayer( )) then return false end

	local iNum = self:NumObjects()
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	if ( CLIENT ) then
	
		if ( iNum > 0 ) then self:ClearObjects() end
		
		return true
		
	end

	if ( iNum > 0 ) then

		// Get information we're about to use
		local Ent1,  Ent2  = self:GetEnt(1),  self:GetEnt(2)

		Ent1:SetParent( Ent2 )
		
		// Clear the objects so we're ready to go again
		self:ClearObjects()

	else
	
		self:SetStage( iNum+1 )
	
	end
	
	return true

end

function TOOL:RightClick( trace )
	if (!trace.Entity:IsValid()) then return false end
	if ( CLIENT ) then return true end
	local function dontdeleteplayer(player)
		player:SetParent()
	end
	trace.Entity:CallOnRemove( "dontdeleteplayer" .. self:GetOwner():Nick(), dontdeleteplayer, self:GetOwner())
	self:GetOwner():SetParent(trace.Entity)
	return true
end

function TOOL:Reload( trace )
	if (!trace.Entity:IsValid()) then return false end
	if ( CLIENT ) then return true end
	
	trace.Entity:SetParent()
	return true
end

