extends "res://scripts/player/player_state.gd"
## Havoda: sakrash va yiqilish. Qo'nganda player.landed signali chiqadi.

var _min_vy := 0.0

func enter(_prev: StringName) -> void:
    _min_vy = minf(0.0, player.velocity.y)

func physics_update(delta: float) -> void:
    if player.in_water:
        machine.change_to(&"Swim")
        return
    player.try_consume_jump()  # coyote-time: ttez qoldirgan bo'lsa ham sakraydi
    _min_vy = minf(_min_vy, player.velocity.y)
    player.apply_gravity(delta)
    player.horizontal_move(player.last_ground_speed, player.air_accel, delta)
    player.move_and_slide()
    if player.is_on_floor():
        player.landed.emit(-_min_vy)
        machine.change_to(player.desired_ground_state())
