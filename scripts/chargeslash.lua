--Charge melee slash ability

ChargeSlash = WeaponAbility:new()

function ChargeSlash:init()
    self.chargeSteps = config.getParameter("chargeSteps")
end

function ChargeSlash:update(dt,fireMode,shiftHeld)
    WeaponAbility.update(self,dt,fireMode,shiftHeld)

end

function ChargeSlash:uninit()

end
