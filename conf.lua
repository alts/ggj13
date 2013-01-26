function love.conf(t)
  t.title = 'RGBuried'
  t.author = 'Stephen Altamirano'
  t.identity = 'rgburied'
  t.version = 0
  t.console = false
  t.screen.width = 256
  t.screen.height = 384
  t.screen.fullscreen = false
  t.screen.vsync = true
  t.screen.fsaa = 4
  t.modules.joystick = false
  t.modules.audio = true
  t.modules.keyboard = false
  t.modules.event = true
  t.modules.image = true
  t.modules.graphics = true
  t.modules.timer = true
  t.modules.mouse = false
  t.modules.sound = true
  t.modules.physics = false
end