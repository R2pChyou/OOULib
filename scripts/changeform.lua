--Variable weapon primary ability

ChangeForm  = WeaponAbility:new()

function ChangeForm:init()
    
    --self.weapon:setStance(self.stances.defaultidle)
    self.cooldownTimer = self.cooldownTime
    self.form = 1
end

function ChangeForm:update(dt,fireMode,shiftHeld)
    WeaponAbility.update(self,dt,fireMode,shiftHeld)
    self.cooldownTimer = math.max(0,self.cooldownTimer - self.dt)

    if fireMode == "alt" and 
            not self.weapon.currentAbility  and
            self.cooldownTimer == 0 then
        sb.logInfo("now change primary ability")
        self.cooldownTimer = self.cooldownTime
        self.form = ( self.form+1 ) %  self.maxForms   
        if self.form == 0 then
            self.form = self.maxForms
        end
        sb.logInfo("curform is "..self.form)
    end
end

function ChangeForm:uninit()

end
