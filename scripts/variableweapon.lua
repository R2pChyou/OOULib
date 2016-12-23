require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

--melee gun bow staff--


function init()
    animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
    animator.setGlobalTag("directives", "")
    animator.setGlobalTag("bladeDirectives", "")

  
    self.weapon = Weapon:new()

  
--transformatGroup:
--      melee: weapon swoosh
--      bow:  weapon
--      gun:  weapon  muzzle
--      staff: weapon

    self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
    self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)
    self.weapon:addTransformationGroup("muzzle",self.weapon.muzzleOffset,0)
  

--load all ability and dont put all ability to self.weapon
    self.pAbilities = {}
    local pAbilitiesConfig = config.getParameter("primaryAbilities")

--create all primary abilities 
    for _, aConfig in pairs(pAbilitiesConfig) do
        sb.logInfo("init new primary ability "..aConfig.class)
        local ability = getAbility("primary",aConfig)
        --ability.weapon = self.weapon
        --ability:init()
        table.insert(self.pAbilities,ability)
    end

    self.weapon:init()
--add first primary ability to self.weapon
    
    self.pAbilities[1].weapon = self.weapon
    self.pAbilities[1]:init()
    self.weapon:addAbility(self.pAbilities[1])
    sb.logInfo("primary ability created")

--add alt ability to self.weapon
    self.altAbility = getAltAbility()
    if not self.altAbility  then
        sb.logInfo("cant create ability")
    else
        self.altAbility.weapon = self.weapon
        self.altAbility:init()
        self.weapon:addAbility(self.altAbility)
    end
--set current form to 0
    self.curForm = 1

--set animation key prefix
    self.pAbilities[1].animKeyPrefix = "pa1"


--variable weapon's contend--

--variable forms--

end

function update(dt, fireMode, shiftHeld)
--if form state changed, change the primary ability
    updateForm()    
    self.weapon:update(dt, fireMode, shiftHeld)

end

function updateForm()
    if self.altAbility.form ~= self.curForm then
        local oldi = 0
        for key, ability in pairs (self.weapon.abilities) do
          if ability.abilitySlot == "primary" then
              ability:uninit()
              oldi = key
              break
          end
        end
        --delete the old primary at weapon object
        sb.logInfo("old primary ability to delete is "..oldi)
        
        table.remove( self.weapon.abilities,oldi)

        --show transform animation
        --animator.setAnimationState("transform","pa"..oldi)

        --put the new form ability to weapon object and update the curForm
        self.pAbilities[self.altAbility.form].weapon = self.weapon
        self.pAbilities[self.altAbility.form]:init()
        self.pAbilities[self.altAbility.form].animKeyPrefix = "pa"..self.altAbility.form
        self.weapon:addAbility(self.pAbilities[self.altAbility.form])
        self.curForm = self.altAbility.form
        

        sb.logInfo("leaving updateForm")
        --show form change animation
    end
end

function uninit()
    self.weapon:uninit()
end
