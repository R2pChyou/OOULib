require "/scripts/vec2.lua"

--wait to resolved:
--1. damage recive
--2. do not disapear when owner leave the map
--
--
function init()
  self.specialLast = false
  self.active = false
  self.fireTimer = 0
  animator.rotateGroup("guns", 0, true)
  self.level = config.getParameter("mechLevel", 6)
  self.groundFrames = 1
  self.worldBottomDeathLevel = 5
  self.maxHealth = config.getParameter("maxHealth") or 1000

  self.stored = false
  --get owner key
  self.ownerKey = config.getParameter("ownerKey")

  --get health
  if not (storage.health) then
    local startHealthFactor = config.getParameter("startHealthFactor")

    if (startHealthFactor == nil) then
        storage.health = self.maxHealth
    else
       storage.health = math.min(startHealthFactor * self.maxHealth, self.maxHealth)
    end
    --animator.setAnimationState("movement", "warpInPart1")
  end

  --handle "store" message
  message.setHandler("store",
      function(_, _, ownerKey)
        if (self.ownerKey and self.ownerKey == ownerKey and self.driver == nil and animator.animationState("movement") == "idle") then
          --animator.setAnimationState("movement", "warpOutPart1")
          --switchHeadLights(1, 1, false)
          animator.playSound("returnvehicle")
          self.stored = true
          return {storable = true, healthFactor = storage.health / self.maxHealth}
        else
          return {storable = false, healthFactor = storage.health / self.maxHealth}
        end
      end)


end

function update()
  if mcontroller.position()[2] < self.worldBottomDeathLevel then
    vehicle.destroy()
    return
  end

  if self.stored then
    vehicle.destroy()
  end

  local mechAimLimit = config.getParameter("mechAimLimit") * math.pi / 180
  local mechHorizontalMovement = config.getParameter("mechHorizontalMovement")
  local mechJumpVelocity = config.getParameter("mechJumpVelocity")
  local mechFireCycle = config.getParameter("mechFireCycle")
  local mechProjectile = config.getParameter("mechProjectile")
  local mechProjectileConfig = config.getParameter("mechProjectileConfig")
  local offGroundFrames = config.getParameter("offGroundFrames")

  local mechCollisionPoly = mcontroller.collisionPoly()
  local position = mcontroller.position()

  if mechProjectileConfig.power then
    mechProjectileConfig.power = root.evalFunction("weaponDamageLevelMultiplier", self.level) * mechProjectileConfig.power
  end

  --update damage team. Will add damage recive
  local entityInSeat = vehicle.entityLoungingIn("seat")
  if entityInSeat then
    vehicle.setDamageTeam(world.entityDamageTeam(entityInSeat))
  else
    vehicle.setDamageTeam({type = "passive"})
  end

  updateDamage()
-----------------------------------------------------------

  --update gun rotate
  local diff = world.distance(vehicle.aimPosition("seat"), mcontroller.position())
  local aimAngle = math.atan(diff[2], diff[1])
  local facingDirection = (aimAngle > math.pi / 2 or aimAngle < -math.pi / 2) and -1 or 1

  if facingDirection < 0 then
    animator.setFlipped(true)

    if aimAngle > 0 then
      aimAngle = math.max(aimAngle, math.pi - mechAimLimit)
    else
      aimAngle = math.min(aimAngle, -math.pi + mechAimLimit)
    end

    animator.rotateGroup("guns", math.pi - aimAngle)
  else
    animator.setFlipped(false)

    if aimAngle > 0 then
      aimAngle = math.min(aimAngle, mechAimLimit)
    else
      aimAngle = math.max(aimAngle, -mechAimLimit)
    end

    animator.rotateGroup("guns", aimAngle)
  end

  --update movement , comment these lines 
  --local onGround = mcontroller.onGround()
  --local movingDirection = 0

  --if vehicle.controlHeld("seat", "left") and onGround then
    --mcontroller.setXVelocity(-mechHorizontalMovement)
    --movingDirection = -1
  --end

  --if vehicle.controlHeld("seat", "right") and onGround then
    --mcontroller.setXVelocity(mechHorizontalMovement)
    --movingDirection = 1
  --end

  --if onGround then
    --self.groundFrames = offGroundFrames
  --else
    --self.groundFrames = self.groundFrames - 1
  --end

  --if vehicle.controlHeld("seat", "jump") and onGround then
    --mcontroller.setXVelocity(mechJumpVelocity[1] * movingDirection)
    --mcontroller.setYVelocity(mechJumpVelocity[2])
    --animator.setAnimationState("movement", "jump")
    --self.groundFrames = 0
  --end

  --if self.groundFrames <= 0 then
    --if mcontroller.velocity()[2] > 0 then
      --animator.setAnimationState("movement", "jump")
    --else
      --animator.setAnimationState("movement", "fall")
    --end
  --elseif movingDirection ~= 0 then
    --if facingDirection ~= movingDirection then
      --animator.setAnimationState("movement", "backWalk")
    --else
      --animator.setAnimationState("movement", "walk")
    --end
  --elseif onGround then
    --animator.setAnimationState("movement", "idle")
  --end
--------------------------------------------------------

  if vehicle.controlHeld("seat", "primaryFire") then
    if self.fireTimer <= 0 then
      world.spawnProjectile(mechProjectile, vec2.add(mcontroller.position(), animator.partPoint("frontGun", "firePoint")), entity.id(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
      self.fireTimer = self.fireTimer + mechFireCycle
      animator.setAnimationState("frontFiring", "fire")
    else
      local oldFireTimer = self.fireTimer
      self.fireTimer = self.fireTimer - script.updateDt()
      if oldFireTimer > mechFireCycle / 2 and self.fireTimer <= mechFireCycle / 2 then
        world.spawnProjectile(mechProjectile, vec2.add(mcontroller.position(), animator.partPoint("backGun", "firePoint")), entity.id(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
        animator.setAnimationState("backFiring", "fire")
      end
    end
  end
end

function updateDamage()
    --accept damage
end
