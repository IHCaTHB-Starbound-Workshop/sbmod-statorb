require "/scripts/vec2.lua"

function die(smash)
  if storage.state then
    output(not storage.state)
  end
  if config.getParameter("explodeOnSmash") and smash then
    world.spawnProjectile(config.getParameter("explosionProjectile"), vec2.add(object.position(), config.getParameter("explosionOffset", {0,0})), entity.id(), {0,0})
  end
end
