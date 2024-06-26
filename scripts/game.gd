extends Node2D

@onready var bullets =  $Bullets
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var player_spawn_pos = $PlayerSpawnPos

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives = 3:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	score = 0
	lives = 3
	player.connect("bullet_shot", _on_player_bullet_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_bullet_shot(b):
	bullets.add_child(b)

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_asteroid_exploded(pos, size, points):
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
	print(score)

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)

func _on_player_died():
	lives -= 1
	print(lives)
	if lives <= 0:
		get_tree().reload_current_scene()
	else:
		await get_tree().create_timer(1).timeout
		player.respawn(player_spawn_pos.global_position)
