require "mini_magick"

image = MiniMagick::Image.open("sprites.png")
image.crop "256x64+0+0"
image.write("sprites/idle.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "512x64+0+64"
image.write("sprites/walk.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "512x64+0+128"
image.write("sprites/jump.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "640x64+0+192"
image.write("sprites/spin.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "576x64+0+256"
image.write("sprites/dead.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "448x64+0+320"
image.write("sprites/power_shot.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "384x64+0+384"
image.write("sprites/fast_shot.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "512x64+0+448"
image.write("sprites/flying_kick.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "832x64+0+512"
image.write("sprites/uppercut.png")

image = MiniMagick::Image.open("sprites.png")
image.crop "640x64+0+576"
image.write("sprites/one_two_combo.png")
