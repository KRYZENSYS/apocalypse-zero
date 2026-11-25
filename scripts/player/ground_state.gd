extends "res://scripts/player/player_state.gd"
## Yerdagi holatlar: Walk, Run, Crouch, Crawl (faqat tezlik farq qiladi).

var speed := 4.0
var accel := 14.0

func enter(_prev: StringName) -> void:
    player.last_ground_speed = speed

func physics_update(delta: float) -> void:
    if player.in_water:
        machine.change_to(&"Swim")
        return
    if player.try_consume_jump():
        machine.change_to(&"Air")
        return
    player.apply_gravity(delta)
    player.horizontal_move(speed, accel, delta)
    player.move_and_slide()
    if not player.is_on_floor():
        machine.change_to(&"Air")
        return
    var target: StringName = player.desired_ground_state()
    if target != machine.current_name:
        machine.change_to(target)
