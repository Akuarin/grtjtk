
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First func called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetModel( "models/jaanus/wiretool/wiretool_siren.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Friction" } )
	
	
end

function ENT:SetAxis( axis, body )
	self.Axis = axis
	self.Body = body
	local tab = self.Axis:GetTable()
	self.FBall = constraint.AdvBallsocket( tab.Ent1, tab.Ent2, tab.Bone1, tab.Bone2, Vector(0,0,0), Vector(0,0,0),0, 0, -180, -180, -180, 180, 180, 180, 0, 0, 0, 1, 0 )
	self.Entity:DeleteOnRemove(axis)
end

function ENT:TriggerInput(iname, value)
	if (iname == "Friction") then
		local tab = self.Axis:GetTable()
		if self.FBall:IsValid() then
			local ball = constraint.AdvBallsocket( tab.Ent1, tab.Ent2, tab.Bone1, tab.Bone2, Vector(0,0,0), Vector(0,0,0),0, 0, -180, -180, -180, 180, 180, 180, value/10, value/10, value/10, 1, 0 )
			self.FBall:Remove()
			self.FBall = ball
		end
		
	end
end

function ENT:OnTakeDamage( dmginfo )

	self.Entity:TakePhysicsDamage( dmginfo )

end
