extends CharacterBody3D
## O'yinchi: state machine, FPS/TPS kamera, egilish/emaklash, sakrash, interact.

const InputActions := preload("res://scripts/core/input_actions.gd")
const GroundState := preload("res://scripts/player/ground_state.gd")
const AirState := preload("res://scripts/player/air_state.gd")
const SwimState := preload("res://scripts/player/swim_state.gd")

signal landed(fall_speed: float)
signal sprint_changed(active: bool)
signal camera_mode_changed(mode: int)
signal interacted(target: Object)

enum Stance { STAND, CROUCH, CRAWL }
enum CameraMode { FPS, TPS }

const STANCE_HEIGHTS := [1.8, 1.2, 0.8]  # Stance bo'yicha indekslanadi
const RADIUS := 0.4
const EYE_OFFSET := 0.2
const TPS_DISTANCE := 3.2
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.15

@export var walk_speed := 4.0
@export var run_speed := 7.0
@export var crouch_speed := 2.0
@export var crawl_speed := 1.0
@export var swim_speed := 3.0
@export var jump_velocity := 4.6
@export var air_accel := 4.0
@export var mouse_sensitivity := 0.0025
@export var touch_sensitivity := 0.006

var stance: int = Stance.STAND
var camera_mode: int = CameraMode.FPS
var in_water := false
var sprint_latched := false
var current_height: float = STANCE_HEIGHTS[0]
var last_ground_speed := 4.0
var jump_buffer := 0.0
var coyote := 0.0
var move_vector := Vector2.ZERO

var _touch_move := Vector2.ZERO
var _pitch := 0.0
var _visual_height: float = STANCE_HEIGHTS[0]
var _shape: CapsuleShape3D
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _body: MeshInstance3D = $Body
@onready var _head: Node3D = $Head
@onready var _arm: SpringArm3D = $Head/Arm
@onready var _ray: RayCast3D = $Head/InteractRay
@onready var machine: Node = $StateMachine

func _ready() -> void:
    add_to_group("player")
    _shape = CapsuleShape3D.new()
    _shape.radius = RADIUS
    _shape.height = current_height
    _collision.shape = _shape
    _collision.position.y = current_height * 0.5

    var bm := CapsuleMesh.new()
    bm.radius = RADIUS
    bm.height = current_height
    _body.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.85, 0.4, 0.25)
    _body.material_override = mat

    _ray.add_exception(self)
    _arm.add_excluded_object(get_rid())
    _head.position.y = current_height - EYE_OFFSET
    _arm.spring_length = 0.0

    machine.player = self
    machine.add_state(_make_ground(&"Walk", walk_speed))
    machine.add_state(_make_ground(&"Run", run_speed))
    machine.add_state(_make_ground(&"Crouch", crouch_speed))
    machine.add_state(_make_ground(&"Crawl", crawl_speed))
    var air := AirState.new()
    air.name = &"Air"
    machine.add_state(air)
    var swim := SwimState.new()
    swim.name = &"Swim"
    machine.add_state(swim)
    machine.change_to(&"Walk")

func _make_ground(state_name: StringName, speed: float) -> Node:
    var s := GroundState.new()
    s.name = state_name
    s.speed = speed
    return s

# ---------------- Tashqi boshqaruv (sensorli tugmalar va klaviatura) ----------------
func set_move_input(v: Vector2) -> void:
    _touch_move = v

func apply_look(relative: Vector2, sensitivity: float) -> void:
    rotate_y(-relative.x * sensitivity)
    _pitch = clampf(_pitch - relative.y * sensitivity, -1.45, 1.45)
    _head.rotation.x = _pitch

func request_jump() -> void:
    jump_buffer = JUMP_BUFFER_TIME

func request_sprint_toggle() -> void:
    if in_water:
        return
    if stance != Stance.STAND and not set_stance(Stance.STAND):
        return
    _set_sprint_latched(not sprint_latched)

func request_crouch_toggle() -> void:
    if in_water:
        return
    if stance == Stance.CROUCH:
        _try_stances([Stance.STAND])
    else:
        _try_stances([Stance.CROUCH])

func request_crawl_toggle() -> void:
    if in_water:
        return
    if stance == Stance.CRAWL:
        _try_stances([Stance.STAND, Stance.CROUCH])
    else:
        _try_stances([Stance.CRAWL])

func request_toggle_camera() -> void:
    camera_mode = CameraMode.TPS if camera_mode == CameraMode.FPS else CameraMode.FPS
    camera_mode_changed.emit(camera_mode)

func request_interact() -> void:
    _ray.force_raycast_update()
    var target: Object = _ray.get_collider() if _ray.is_colliding() else null
    if target != null and target.has_method("interact"):
        target.call("interact", self)
    interacted.emit(target)

func set_in_water(value: bool) -> void:
    in_water = value

# ---------------- Holat mashinasi yordamchilari ----------------
func set_stance(new_stance: int) -> bool:
    if new_stance == stance:
        return true
    var h: float = STANCE_HEIGHTS[new_stance]
    var dy := h - current_height
    if dy > 0.0 and test_move(global_transform, Vector3.UP * (dy + 0.02)):
        return false  # tepada to'siq bor, turib bo'lmaydi
    stance = new_stance
    current_height = h
    _shape.height = h
    _collision.position.y = h * 0.5
    if new_stance != Stance.STAND:
        _set_sprint_latched(false)
    return true

func _try_stances(options: Array) -> void:
    for s in options:
        if set_stance(s):
            return

func _set_sprint_latched(on: bool) -> void:
    if sprint_latched == on:
        return
    sprint_latched = on
    sprint_changed.emit(on)

func desired_ground_state() -> StringName:
    if stance == Stance.CRAWL:
        return &"Crawl"
    if stance == Stance.CROUCH:
        return &"Crouch"
    var wants_sprint := Input.is_action_pressed(InputActions.SPRINT) or sprint_latched
    if wants_sprint and move_vector.y < -0.1:
        return &"Run"
    return &"Walk"

func try_consume_jump() -> bool:
    if jump_buffer <= 0.0 or coyote <= 0.0 or stance == Stance.CRAWL:
        return false
    if stance == Stance.CROUCH and not set_stance(Stance.STAND):
        return false
    velocity.y = jump_velocity
    jump_buffer = 0.0
    coyote = 0.0
    return true

func apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= _gravity * delta

func horizontal_move(speed: float, accel: float, delta: float) -> void:
    var dir := transform.basis * Vector3(move_vector.x, 0.0, move_vector.y)
    velocity.x = move_toward(velocity.x, dir.x * speed, accel * delta)
    velocity.z = move_toward(velocity.z, dir.z * speed, accel * delta)

# ---------------- Kadr yangilanishlari ----------------
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        apply_look(event.relative, mouse_sensitivity * float(SettingsManager.get_value("look_sensitivity")))
    elif event.is_action_pressed(InputActions.JUMP):
        request_jump()
    elif event.is_action_pressed(InputActions.CROUCH):
        request_crouch_toggle()
    elif event.is_action_pressed(InputActions.CRAWL):
        request_crawl_toggle()
    elif event.is_action_pressed(InputActions.INTERACT):
        request_interact()
    elif event.is_action_pressed(InputActions.TOGGLE_CAMERA):
        request_toggle_camera()

func _physics_process(delta: float) -> void:
    jump_buffer = maxf(jump_buffer - delta, 0.0)
    if is_on_floor():
        coyote = COYOTE_TIME
    else:
        coyote = maxf(coyote - delta, 0.0)
    var kb := Input.get_vector(InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT,
        InputActions.MOVE_FORWARD, InputActions.MOVE_BACK)
    move_vector = (kb + _touch_move).limit_length(1.0)
    if sprint_latched and move_vector.length() < 0.1:
        _set_sprint_latched(false)
    machine.physics_update(delta)

func _process(delta: float) -> void:
    var t := 1.0 - exp(-12.0 * delta)
    _visual_height = lerpf(_visual_height, current_height, t)
    _head.position.y = lerpf(_head.position.y, current_height - EYE_OFFSET, t)
    var bm := _body.mesh as CapsuleMesh
    bm.height = maxf(_visual_height, RADIUS * 2.0)
    _body.position.y = _visual_height * 0.5
    var target_len := TPS_DISTANCE if camera_mode == CameraMode.TPS else 0.0
    _arm.spring_length = lerpf(_arm.spring_length, target_len, t)
    _body.visible = _arm.spring_length > 0.9
