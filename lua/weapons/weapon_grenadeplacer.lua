if SERVER then
    AddCSLuaFile( "weapon_grenadeplacer.lua" )
end

if CLIENT then
    SWEP.PrintName = "Tripwire Grenade"
    SWEP.Slot = 2
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 70
    SWEP.Spawnable = true
end

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.FiresUnderwater = false
SWEP.UseHands = true
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.HoldType = "grenade"
SWEP.Ammo = "slam"

function SWEP:Deploy()
    self:SendWeaponAnim( ACT_VM_DRAW )

    return true
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:PrimaryAttack()
    self:Grenade( self:GetOwner() )
    self:SetNextPrimaryFire( CurTime() )
end

function SWEP:Grenade( ply )
    if SERVER then
        if not IsValid( self.Owner ) then return end

        local owner = self:GetOwner()

        if not IsValid( self.c_Model2 ) then
            local trace = {}
            trace.start = owner:GetShootPos()
            trace.endpos = trace.start + owner:GetAimVector() * 60

            trace.filter = { owner, self }

            trace.mask = MASK_SOLID
            local tr = util.TraceLine( trace )

            if tr.HitWorld then
                if not IsValid( self.c_Model ) then
                    self.c_Model = ents.Create( "prop_physics" )
                    local tr_ent = util.TraceEntity( trace, self.c_Model )

                    if tr_ent.HitWorld then
                        self.grenadeang = tr_ent.HitNormal:Angle()
                        grenadeang.p = grenadeang.p + 90
                        self.grenadepos = tr_ent.HitPos + tr_ent.HitNormal * -0.2
                        self.c_Model = ents.Create( "prop_physics" )
                        self.c_Model:SetPos( grenadepos )
                        self.c_Model:SetAngles( self.grenadeang )
                        self.c_Model:SetModel( "models/weapons/w_eq_fraggrenade.mdl" )
                        self.c_Model:PhysicsInit( SOLID_NONE )
                        self.c_Model:SetMoveType( MOVETYPE_NONE )
                        self.c_Model:SetCollisionGroup( COLLISION_GROUP_WEAPON )
                        self.c_Model:Spawn()
                        self.c_Model:GetPhysicsObject():EnableMotion( false )
                        self.c_Model:SetRenderMode( RENDERMODE_TRANSALPHA )
                        self.c_Model:SetColor( Color( 255, 255, 255, 100 ) )
                        self.cmodeltimer = CurTime() + 5
                        self.Owner:ChatPrint( "Grenade placed." )
                    end
                elseif IsValid( self.c_Model ) and not IsValid( self.c_Model2 ) then
                    self.c_Model2 = ents.Create( "prop_physics" )
                    local tr_ent = util.TraceEntity( trace, self.c_Model2 )

                    if tr_ent.HitWorld then
                        if self.grenadepos:Distance( tr.HitPos ) < 190 then
                            stickang = tr_ent.HitNormal:Angle()
                            stickang.r = stickang.r + 90
                            stickang.p = stickang.p + 90
                            stickpos = tr_ent.HitPos + tr_ent.HitNormal * 3
                            self.c_Model2:SetPos( stickpos )
                            self.c_Model2:SetAngles( stickang )
                            self.c_Model2:SetModel( "models/props_c17/TrapPropeller_Lever.mdl" )
                            self.c_Model2:PhysicsInit( SOLID_NONE )
                            self.c_Model2:SetMoveType( MOVETYPE_NONE )
                            self.c_Model2:SetCollisionGroup( COLLISION_GROUP_WEAPON )
                            self.c_Model2:Spawn()
                            self.c_Model2:GetPhysicsObject():EnableMotion( false )
                            self.c_Model2:SetRenderMode( RENDERMODE_TRANSALPHA )
                            self.c_Model2:SetColor( Color( 255, 255, 255, 100 ) )
                            owner:ChatPrint( "Tripwire Placed." )
                        else
                            self.c_Model2:Remove()
                            owner:ChatPrint( "Too far from grenade!" )
                        end
                    end
                end
            end
        else
            local grenade = ents.Create( "tripwiregrenade" )
            grenade:SetPos( self.grenadepos )
            grenade:SetVar( "Placed", 1 )
            grenade.stickpos = stickpos
            grenade.stickang = stickang
            grenade:SetAngles( self.grenadeang )
            grenade:Spawn()
            constraint.Weld( grenade, game.GetWorld(), 0, 0, 0, 0, 0 )
            self:EmitSound( "buttons/lever8.wav" )

            if IsValid( self.c_Model ) then
                self.c_Model:Remove()
            end

            if IsValid( self.c_Model2 ) then
                self.c_Model2:Remove()
            end

            self:SendWeaponAnim( ACT_VM_THROW )
            SafeRemoveEntityDelayed( self, 0.5 )
        end
    end
end

function SWEP:Think()
    if IsValid( self.c_Model ) and ( self.c_Model:GetPos():Distance( self:GetOwner():GetPos() ) > 220 or self.cmodeltimer < CurTime() ) then
        if IsValid( self.c_Model ) then
            self.c_Model:Remove()
        end

        if IsValid( self.c_Model2 ) then
            self.c_Model2:Remove()
        end
    end
end

function SWEP:Reload()
    if IsValid( self.c_Model ) then
        self.c_Model:Remove()
    end

    if IsValid( self.c_Model2 ) then
        self.c_Model2:Remove()
    end
end

function SWEP:OnRemove()
    if IsValid( self.c_Model ) then
        self.c_Model:Remove()
    end

    if IsValid( self.c_Model2 ) then
        self.c_Model2:Remove()
    end
end

function SWEP:Holster()
    if IsValid( self.c_Model ) then
        self.c_Model:Remove()
    end

    if IsValid( self.c_Model2 ) then
        self.c_Model2:Remove()
    end

    return true
end
