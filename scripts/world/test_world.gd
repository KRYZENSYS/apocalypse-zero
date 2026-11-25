extends Node3D
## 3D test maydoni: o'yinchi, boshqaruv va pauza menyusini bog'laydi.

const InputActions := preload("res://scripts/core/input_actions.gd")
const STANCE_NAMES := ["Tik", "Egilgan", "Emaklash"]
const CAMERA_NAMES := ["FPS", "TPS"]

@onready var player: CharacterBody3D = $Player
@onready var spawn: Marker3D = $PlayerSpawn
@onready var controls: Control = $HUD/MobileControls
@onready var hud: CanvasLayer = $HUD
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var sun: DirectionalLight3D = $Sun

var _debug: Label
var _last_landing := 0.0

func _ready() -> void:
    sun.rotation_degrees = Vector3(-50, -30, 0)
    player.global_position = spawn.global_position
    _build_decor()
    _build_debug_label()

    controls.move_changed.connect(player.set_move_input)
    controls.look_delta.connect(_on_touch_look)
    controls.jump_pressed.connect(player.request_jump)
    controls.sprint_pressed.connect(player.request_sprint_toggle)
    controls.crouch_pressed.connect(player.request_crouch_toggle)
    controls.crawl_pressed.connect(player.request_crawl_toggle)
    controls.interact_pressed.connect(player.request_interact)
    controls.camera_pressed.connect(player.request_toggle_camera)
    controls.pause_pressed.connect(pause_menu.open)
    player.sprint_changed.connect(controls.set_sprint_active)
    player.landed.connect(func(v: float) -> void: _last_landing = v)
    GameManager.back_requested.connect(pause_menu.toggle)

    if not GameManager.uses_touch_controls():
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree() -> void:
    if GameManager.back_requested.is_connected(pause_menu.toggle):
        GameManager.back_requested.disconnect(pause_menu.toggle)

func _on_touch_look(delta: Vector2) -> void:
    player.apply_look(delta, player.touch_sensitivity * float(SettingsManager.get_value("look_sensitivity")))

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(InputActions.PAUSE):
        pause_menu.open()

func _build_debug_label() -> void:
    _debug = Label.new()
    _debug.position = Vector2(24, 64)
    _debug.add_theme_font_size_override("font_size", 20)
    hud.add_child(_debug)

func _process(_delta: float) -> void:
    _debug.visible = bool(SettingsManager.get_value("show_fps"))
    if _debug.visible:
        _debug.text = "Holat: %s | Duruş: %s | Kamera: %s | Qo‘nish: %.1f m/s" % [
            player.machine.current_name, STANCE_NAMES[player.stance],
            CAMERA_NAMES[player.camera_mode], _last_landing]

func _build_decor() -> void:
    # Boshlang'ich dekor va sinov to'siqlari (vaqtinchalik quti-bloklar)
    _add_box("Box1", Vector3(6, 0.75, -6), Vector3(2, 1.5, 2), Color(0.55, 0.32, 0.2))
    _add_box("Box2", Vector3(-7, 1.0, -9), Vector3(3, 2.0, 3), Color(0.35, 0.4, 0.45))
    _add_box("Box3", Vector3(0, 0.25, -12), Vector3(8, 0.5, 2), Color(0.3, 0.45, 0.3))
    _add_box("Wall1", Vector3(12, 1.5, 0), Vector3(1, 3, 10), Color(0.4, 0.4, 0.42))
    # Zinapoya: har pog'ona oldingisidan 0.8 m baland (sakrab chiqiladi), tepadan yiqilish sinovi
    _add_box("Stair1", Vector3(-12, 0.4, -2), Vector3(3, 0.8, 3), Color(0.6, 0.55, 0.3))
    _add_box("Stair2", Vector3(-12, 0.8, -5), Vector3(3, 1.6, 3), Color(0.6, 0.5, 0.3))
    _add_box("Stair3", Vector3(-12, 1.2, -8), Vector3(3, 2.4, 3), Color(0.6, 0.45, 0.3))
    _add_box("Stair4", Vector3(-12, 1.6, -11), Vector3(3, 3.2, 3), Color(0.6, 0.4, 0.3))
    # Past shift: tik turib o'tib bo'lmaydi (pastki chet 1.4 m), egilib o'tiladi (egilgan bo'y 1.2 m)
    _add_box("CrouchBeam", Vector3(10, 1.6, 12), Vector3(5, 0.4, 3), Color(0.5, 0.3, 0.3))
    _add_box("CrouchPillarA", Vector3(7.3, 0.9, 12), Vector3(0.4, 1.8, 3), Color(0.4, 0.4, 0.4))
    _add_box("CrouchPillarB", Vector3(12.7, 0.9, 12), Vector3(0.4, 1.8, 3), Color(0.4, 0.4, 0.4))
    # Juda past shift: faqat emaklab o'tiladi (pastki chet 0.9 m, emaklash bo'yi 0.8 m)
    _add_box("CrawlBeam", Vector3(18, 1.1, 12), Vector3(5, 0.4, 3), Color(0.3, 0.3, 0.5))
    _add_box("CrawlPillarA", Vector3(15.3, 0.45, 12), Vector3(0.4, 0.9, 3), Color(0.4, 0.4, 0.4))
    _add_box("CrawlPillarB", Vector3(20.7, 0.45, 12), Vector3(0.4, 0.9, 3), Color(0.4, 0.4, 0.4))

func _add_box(box_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = box_name
    body.position = pos
    var mesh := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = size
    mesh.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    body.add_child(mesh)
    var col := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    col.shape = shape
    body.add_child(col)
    add_child(body)
