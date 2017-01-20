
function init()
  restorePreservedStorage()

  self.shouldDie = true
  self.forceDie = false
  self.pathing = {}

  self.notifications = {}
  if storage.spawnPosition == nil then
    local position = mcontroller.position()
    local groundPosition = findGroundPosition(position, -20, 3)
    storage.spawnPosition = groundPosition or position
  end
  BData:setPosition("spawn", storage.spawnPosition)

  local questOutbox = Outbox.new("questOutbox", ContactList.new("questContacts"))
  self.quest = QuestParticipant.new("quest", questOutbox)
  self.quest.onOfferedQuestStarted = offeredQuestStarted
  self.quest.onOfferedQuestFinished = offeredQuestFinished

  if config.getParameter("behavior") then
    self.behavior = root.behavior(config.getParameter("behavior"), config.getParameter("behaviorConfig", {}))
    self.behaviorState = self.behavior:init(_ENV)
  end

  npc.setInteractive(true)
  script.setUpdateDelta(1)

  self.behaviorConfig = config.getParameter("behaviorConfig", {})
  if personality().behaviorConfig then
    self.behaviorConfig = parseArgs(personality().behaviorConfig, self.behaviorConfig)
  end
  local deathBehavior = config.getParameter("deathBehavior")
  if deathBehavior then
    self.deathBehavior = root.behavior(deathBehavior, config.getParameter("behaviorConfig", {}))
  end

  self.primary = npc.getItemSlot("primary")
  self.alt = npc.getItemSlot("alt")
  self.sheathedPrimary = npc.getItemSlot("sheathedprimary")
  self.sheathedAlt = npc.getItemSlot("sheathedalt")
  self.delayedSetItemSlot = {}

  self.debug = false

  mcontroller.setAutoClearControls(false)
  self.behaviorTickRate = 10
  self.behaviorTick = math.random(1, self.behaviorTickRate)

  self.stuckCheckTime = config.getParameter("stuckCheckTime", 3.0)
  self.stuckCheckTimer = 0.1

  message.setHandler("notify", function (_, _, notification)
      return notify(notification)
    end)

  message.setHandler("suicide", function ()
      status.setResource("health", 0)
    end)

  self.uniqueId = config.getParameter("uniqueId")
  updateUniqueId()

  npc.setDamageOnTouch(true)
  npc.setAggressive(config.getParameter("aggressive", false))

  if (config.getParameter("facingDirection")) then
    mcontroller.controlFace(config.getParameter("facingDirection"))
  end

  recruitable.init()

  if type(extraInit) == "function" then
    extraInit()
  end
end

function die()
  self.quest:die()
  recruitable.die()
  tenant.backup()
  spawnDrops()
  if self.deathBehavior then
    local deathBehaviorState = self.deathBehavior:init(_ENV)
    self.deathBehavior:run(deathBehaviorState, script.updateDt())
  end
end
