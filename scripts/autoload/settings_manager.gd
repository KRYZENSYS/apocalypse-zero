extends Node
## Sozlamalar (user://settings.cfg). AUTOLOAD: SettingsManager

signal settings_changed

const SETTINGS_PATH := "user://settings.cfg"
const QUALITY_NAMES := ["Past", "O‘rta", "Yuqori"]
const DEFAULTS := {
    "master_volume": 0.8,
    "quality": 1,
    "look_sensitivity": 1.0,
    "show_fps": false,
    "force_touch_controls": false,
    "touch_ui_scale": 1.0,
}

var _values: Dictionary = DEFAULTS.duplicate()
var _fps_label: Label

func _ready() -> void:
    load_settings()
    _build_fps_overlay()
    apply_all()

func get_value(key: String) -> Variant:
    return _values.get(key, DEFAULTS.get(key))

func set_value(key: String, value: Variant, save: bool = true) -> void:
    _values[key] = value
    apply_all()
    if save:
        save_settings()
    settings_changed.emit()

func load_settings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SETTINGS_PATH) != OK:
        return
    for key in DEFAULTS:
        var v: Variant = cfg.get_value("settings", key, DEFAULTS[key])
        if typeof(v) == typeof(DEFAULTS[key]):
            _values[key] = v

func save_settings() -> void:
    var cfg := ConfigFile.new()
    for key in _values:
        cfg.set_value("settings", key, _values[key])
    var err := cfg.save(SETTINGS_PATH)
    if err != OK:
        push_error("Sozlamalarni saqlab bo'lmadi: %s" % error_string(err))

func apply_all() -> void:
    var vol := float(_values["master_volume"])
    AudioServer.set_bus_mute(0, vol <= 0.001)
    AudioServer.set_bus_volume_db(0, linear_to_db(maxf(vol, 0.001)))

    var root := get_tree().root
    match int(_values["quality"]):
        0:
            root.scaling_3d_scale = 0.6
            root.msaa_3d = Viewport.MSAA_DISABLED
            Engine.max_fps = 30
        2:
            root.scaling_3d_scale = 1.0
            root.msaa_3d = Viewport.MSAA_2X
            Engine.max_fps = 60
        _:
            root.scaling_3d_scale = 0.8
            root.msaa_3d = Viewport.MSAA_DISABLED
            Engine.max_fps = 60

    if _fps_label:
        _fps_label.visible = bool(_values["show_fps"])
        set_process(_fps_label.visible)

func _build_fps_overlay() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)
    _fps_label = Label.new()
    _fps_label.position = Vector2(24, 24)
    _fps_label.add_theme_font_size_override("font_size", 22)
    layer.add_child(_fps_label)

func _process(_delta: float) -> void:
    if _fps_label:
        _fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
