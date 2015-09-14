TOOL.Category= "Construction"
TOOL.Name= "#Propeller Tool"
TOOL.Command= nil
TOOL.ConfigName= ""

TOOL.ClientConVar = {
eff= 50,
}

cleanup.Register( "propeller_tool" )

// Add Default Language translation (saves adding it to the txt files)
if CLIENT then
language.Add( "Tool.propeller.name", "Propeller Tool" )
language.Add( "Tool.propeller.desc", "Causes a prop to become a Propeller." )
language.Add( "Tool.propeller.0", "Left click to turn a prop into a Propeller." )
language.Add( "Tool_propeller_eff", "Efficiency of Propeller" )
language.Add( "Undone.propeller", "Undone Propeller" )
language.Add( "Cleanup.propeller", "Propeller" )
language.Add( "Cleaned.propeller", "Cleaned up Propeller" )
language.Add( "sboxlimit.propeller", "You've reached the Propeller limit!" )

end

if SERVER then
CreateConVar('sbox_maxpropeller', 20)
end

function TOOL:LeftClick( trace )
if (!trace.Hit or !trace.Entity:IsValid() or trace.Entity:GetClass() != "prop_physics") then return false end
if (SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone )) then return false end
if CLIENT then return true end

local eff= self:GetClientNumber( "eff" )
  
if trace.Entity.Propeller_Ent then
local Data = {
efficiency = eff
}
table.Merge(trace.Entity.Propeller_Ent:GetTable(), Data)
duplicator.StoreEntityModifier(trace.Entity, "propeller", Data)
return true
end

if !self:GetSWEP():CheckLimit("propeller") then return false end

local Data = {
--pos= trace.Entity:WorldToLocal(trace.HitPos + trace.HitNormal * 4),
ang= trace.Entity:WorldToLocalAngles(trace.HitNormal:Angle()),
efficiency = eff,
}

local propeller = MakePropellerEnt(self:GetOwner(), trace.Entity, Data)

undo.Create("propeller")
undo.AddEntity(propeller)
undo.SetPlayer(self:GetOwner())
undo.Finish()

return true
end
   
function TOOL:RightClick( trace )
if trace.Entity.Propeller_Ent then
local propeller = trace.Entity.Propeller_Ent
local ply = self:GetOwner()
ply:ConCommand("propeller_eff "..propeller.efficiency)
return true
end
end


function TOOL:Reload( trace )
if trace.Entity.Propeller_Ent then
trace.Entity.Propeller_Ent:Remove() 
return true
end
end


if SERVER then
function MakePropellerEnt( Player, Entity, Data )
if !Data then return end
if !Entity:IsValid() then return end
if !Player:CheckLimit("propeller") then return false end

local propeller = ents.Create( "propeller" )
if !propeller:IsValid() then return false end
propeller:SetPos(Entity:GetPos())
propeller:SetAngles(Entity:LocalToWorldAngles(Data.ang))
propeller.ent= Entity
propeller.efficiency= Data.efficiency
propeller:Spawn()
propeller:Activate()

propeller:SetParent(Entity)
Entity:DeleteOnRemove(propeller)
Entity.Propeller_Ent = propeller

duplicator.StoreEntityModifier(Entity, "propeller", Data)
Player:AddCount("propeller", propeller)
Player:AddCleanup("propeller", propeller)

return propeller
end
duplicator.RegisterEntityModifier("propeller", MakePropellerEnt)
end

function TOOL.BuildCPanel(CPanel)

CPanel:NumSlider("#Tool_propeller_eff", "propeller_eff", -100, 100, 0)
   
end
