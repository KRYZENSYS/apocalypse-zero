extends "res://scripts/player/player_state.gd"
## Suzish. ESLATMA: hozircha suv hajmi yo'q (player.set_in_water() keyingi bosqichlarda
## Area3D orqali chaqiriladi). Bu holat HALI SINALMAGAN.

const SINK_SPEED := -0.8

func enter(_prev: StringName) -> void:
    player.set_stance(0)

func physics_update(delta: float) -> void:
    if not player.in_water:
        machine.change_to(&"Air")
        return
    if player.jump_buffer > 0.0 or Input.is_action_pressed(&"jump"):
        player.velocity.y = 2.5
        player.jump_buffer = 0.0
    else:
        player.velocity.y = move_toward(player.velocity.y, SINK_SPEED, 6.0 * delta)
    player.horizontal_move(player.swim_speed, 6.0, delta)
    player.move_and_slide()
