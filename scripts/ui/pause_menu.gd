extends CanvasLayer
## Pauza menyusi. O'yin sahnasi ichida ishlatiladi.

const SettingsPanel := preload("res://scripts/ui/settings_panel.gd")
const InputActions := preload("res://scripts/core/input_actions.gd")

var _box: VBoxContainer
var _settings: PanelContainer
var _root: Control

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 50
    visible = false

    _root = Control.new()
    _root.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(_root)

    var dim := ColorRect.new()
    dim.color = Color(0, 0, 0, 0.6)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    _root.add_child(dim)

    var center := CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    _root.add_child(center)
    var stack := Control.new()
    center.add_child(stack)

    _box = VBoxContainer.new()
    _box.add_theme_constant_override("separation", 14)
    stack.add_child(_box)

    var title := Label.new()
    title.text = "PAUZA"
    title.add_theme_font_size_override("font_size", 44)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _box.add_child(title)
    _add_button("Davom etish", close)
    _add_button("Sozlamalar", func() -> void: _set_settings(true))
    _add_button("Asosiy menyu", func() -> void: SceneManager.goto_scene(SceneManager.MAIN_MENU))

    _settings = SettingsPanel.new()
    _settings.visible = false
    _settings.closed.connect(func() -> void: _set_settings(false))
    stack.add_child(_settings)

func _add_button(text: String, cb: Callable) -> void:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(420, 64)
    b.add_theme_font_size_override("font_size", 28)
    b.pressed.connect(cb)
    _box.add_child(b)

func _set_settings(show_settings: bool) -> void:
    _box.visible = not show_settings
    _settings.visible = show_settings

func is_open() -> bool:
    return visible

func open() -> void:
    if visible:
        return
    _set_settings(false)
    visible = true
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close() -> void:
    if not visible:
        return
    visible = false
    get_tree().paused = false
    if not GameManager.uses_touch_controls():
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle() -> void:
    if visible:
        close()
    else:
        open()

func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed(InputActions.PAUSE):
        close()
        get_viewport().set_input_as_handled()
