 TOOL.Category		= "Wire - Physics"
 TOOL.Name			= "#Clutch" 
 TOOL.Command		= nil 
 TOOL.ConfigName		= "" 
   
   
 TOOL.ClientConVar[ "forcelimit" ]  = "0" 
 TOOL.ClientConVar[ "torquelimit" ] = "0"  
 TOOL.ClientConVar[ "nocollide" ]   = "0" 
 
 if ( CLIENT ) then

	language.Add( "Tool.clutch.name", "Wired clutch" )
	language.Add( "Tool.clutch.desc", "Allows variable control over hinge friction" )
	language.Add( "Tool.clutch.0", "Click a prop or something." )
	language.Add( "Tool.clutch.1", "Now click some other piece of crap." )
	language.Add( "Tool.clutch.2", "Place a control." )
	
	language.Add( "Tool.clutch.forcelimit", "Force limit:" )
	language.Add( "Tool.clutch.torquelimit", "Torque limit:" )
	language.Add( "Tool.clutch.nocollide", "No collide:" )


end
   
 function TOOL:LeftClick( trace ) 
   
 	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end 
 	 
 	// todo: Don't attempt to constrain the first object if it's already constrained to a static object 
 	 
 	local iNum = self:NumObjects() 
 	 
 	// Don't allow us to choose the world as the first object 
 	if (iNum == 0 && !trace.Entity:IsValid()) then return false end 
 	 
 	// Don't do jeeps (crash protection until we get it fixed) 
 	if (iNum == 0 && trace.Entity:GetClass() == "prop_vehicle_jeep") then return false end 
 	 
 	// If there's no physics object then we can't constraint it! 
 	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end 
 	 
 	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone ) 
 	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal ) 
 	
	if CLIENT then return true end
	
 	if ( iNum > 0 ) then 
		if iNum == 1 then
			// Clientside can bail out now 
			if ( CLIENT ) then 
			
				self:ClearObjects() 
				self:ReleaseGhostEntity() 
				
				return true 
			
			end 
		
			// Get client's CVars 
			local forcelimit	= self:GetClientNumber( "forcelimit", 0 ) 
			local torquelimit 	= self:GetClientNumber( "torquelimit", 0 ) 
			local friction		= 0 
			local nocollide		= self:GetClientNumber( "nocollide", 0 ) 
			
			local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2) 
			local Bone1, Bone2 = self:GetBone(1),	 self:GetBone(2) 
			local WPos1, WPos2 = self:GetPos(1),	 self:GetPos(2) 
			local LPos1, LPos2 = self:GetLocalPos(1),self:GetLocalPos(2) 
			local Norm1, Norm2 = self:GetNormal(1),	 self:GetNormal(2) 
			local Phys1, Phys2 = self:GetPhys(1), self:GetPhys(2) 
			
			// Note: To keep stuff ragdoll friendly try to treat things as physics objects rather than entities 
			local Ang1, Ang2 = Norm1:Angle(), (Norm2 * -1):Angle() 
			local TargetAngle = Phys1:AlignAngles( Ang1, Ang2 ) 
			
			Phys1:SetAngle( TargetAngle ) 
			
			// Move the object so that the hitpos on our object is at the second hitpos 
			local TargetPos = WPos2 + (Phys1:GetPos() - self:GetPos(1)) 
			local TargetPos = WPos2 + (Phys1:GetPos() - self:GetPos(1)) + (Norm2) 
	
			// Offset slightly so it can rotate 
			TargetPos = TargetPos + Norm2 
			
			// Set the position 
			Phys1:SetPos( TargetPos ) 
			
			// Wake up the physics object so that the entity updates 
			Phys1:Wake() 
					
			// Set the hinge Axis perpendicular to the trace hit surface 
			LPos1 = Phys1:WorldToLocal( WPos2 + Norm2 ) 
	
			// Create a constraint axis 
			local constraint = constraint.Axis( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, forcelimit, torquelimit, friction, nocollide ) 
			self.constraint = constraint
			
			
			
			self:ReleaseGhostEntity() 
			self:SetStage( 2 )
		else
		
			local Ang = trace.HitNormal:Angle()
			Ang.pitch = Ang.pitch + 90
			local controller = MakeWireClutch(trace.HitPos, Ang, self.constraint, Phys1 )
			
			undo.Create("Axis") 
			undo.AddEntity( self.constraint ) 
			undo.AddEntity( controller ) 
			undo.SetPlayer( self:GetOwner() ) 
			undo.Finish() 
			self:GetOwner():AddCleanup( "constraints", controller ) 
		
			// Clear the objects so we're ready to go again 
			self:ClearObjects()
		
		end
 		 
 	else 
		
 	 
 		self:StartGhostEntity( trace.Entity ) 
 		self:SetStage( iNum + 1 )
 	 
 	end 
	 
 	return true 
   
 end 
   
 function TOOL:RightClick( trace ) 
   
 end
 
 if SERVER then
	function MakeWireClutch(pos, ang, axis, phys )
		local con = ents.Create( "gmod_wire_clutch" )
		con:SetPos( pos )
		con:SetAngles( ang )
		con:Spawn()
		con:Activate()
		
		con:SetAxis( axis, phys ) 
		con:DeleteOnRemove( axis )
		return con
	end
	duplicator.RegisterEntityClass("gmod_wire_clutch", MakeWireClutch, "Pos", "Ang")
 end
 
   
 function TOOL:Reload( trace ) 
   
 	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end 
 	if ( CLIENT ) then return true end 
 	 
 	local  bool = constraint.RemoveConstraints( trace.Entity, "Axis" ) 
 	return bool 
 	 
 end 
   
 function TOOL:Think() 
   
 	if (self:NumObjects() != 1) then return end 
 	 
 	self:UpdateGhostEntity() 
   
 end  
 
 function TOOL.BuildCPanel(panel)
	panel:AddControl("CheckBox", {
		Label = "#Tool.clutch.nocollide",
		Command = "clutch.nocollide"
	})

	panel:AddControl("Slider", {
		Label = "#Tool.clutch.forcelimit",
		Type = "Float",
		Min = "0",
		Max = "100000",
		Command = "clutch.forcelimit"
	})	
	panel:AddControl("Slider", {
		Label = "#Tool.clutch.torquelimit",
		Type = "Float",
		Min = "0",
		Max = "10000",
		Command = "clutch.torquelimit"
	})	
	
end