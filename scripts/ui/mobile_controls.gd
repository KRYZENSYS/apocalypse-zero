extends Control
## Sensorli boshqaruv. Chap: suzuvchi joystik. O'ng bo'sh zona: kamera.
## Tugmalar: Sakrash, Egilish (bosish=egilish, uzoq bosish=emaklash), Yugurish (yoqish/o'chirish),
## Amal (interact), Kamera (FPS/TPS), Pauza. O'lcham ekran DPI va sozlamaga qarab hisoblanadi.
## Faqat InputEventScreenTouch/ScreenDrag ishlatiladi (sichqoncha hodisalari e'tiborsiz) — ikki marta kirish yo'q.

signal move_changed(vector: Vector2)
signal look_delta(delta: Vector2)
signal jump_pressed
signal sprint_pressed
signal crouch_pressed
signal crawl_pressed
signal interact_pressed
signal camera_pressed
signal pause_pressed

const SafeAreaContainer := preload("res://scripts/ui/safe_area_container.gd")
const LONG_PRESS := 0.6

var sprint_active := false

var _move_touch := -1
var _look_touch := -1
var _btn_touches := {}  # touch index -> button id
var _stick_origin := Vector2.ZERO
var _stick_pos := Vector2.ZERO
var _crouch_time := 0.0
var _crouch_consumed := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    get_viewport().size_changed.connect(queue_redraw)
    SettingsManager.settings_changed.connect(_refresh)
    _refresh()

func _refresh() -> void:
    visible = GameManager.uses_touch_controls()
    set_process_input(visible)
    set_process(visible)
    queue_redraw()

func set_sprint_active(on: bool) -> void:
    sprint_active = on
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_PAUSED or what == NOTIFICATION_UNPAUSED:
        _reset_touches()

func _reset_touches() -> void:
    if _move_touch != -1:
        move_changed.emit(Vector2.ZERO)
    _move_touch = -1
    _look_touch = -1
    _btn_touches.clear()
    _crouch_time = 0.0
    _crouch_consumed = true
    queue_redraw()

# ---------------- Joylashuv (DPI va safe area bilan) ----------------
func _vp_size() -> Vector2:
    return get_viewport().get_visible_rect().size

## Virtual piksellarda "1 dyuym" uzunligi.
func _ppi() -> float:
    var ppi := 120.0
    if OS.has_feature("mobile"):
        var dpi := float(DisplayServer.screen_get_dpi())
        var win := DisplayServer.window_get_size()
        if dpi > 0.0 and win.y > 0:
            ppi = dpi * _vp_size().y / float(win.y)
    return clampf(ppi, 80.0, 400.0) * float(SettingsManager.get_value("touch_ui_scale"))

func _stick_radius() -> float:
    return clampf(0.5 * _ppi(), 60.0, 170.0)

func _buttons() -> Array:
    var s := _vp_size()
    var m := SafeAreaContainer.compute(s)
    var ppi := _ppi()
    var r := clampf(0.30 * ppi, 38.0, 100.0)
    var sr := r * 0.8
    var edge := maxf(24.0, 0.2 * ppi)
    var jc := Vector2(s.x - float(m["right"]) - edge - r, s.y - float(m["bottom"]) - edge - r)
    var pr := r * 0.6
    var pc := Vector2(s.x - float(m["right"]) - edge - pr, float(m["top"]) + edge + pr)
    var list := [
        {"id": &"jump", "pos": jc, "r": r, "text": "Sakrash"},
        {"id": &"crouch", "pos": jc + Vector2(-2.1 * r, 0.0), "r": sr, "text": "Egilish"},
        {"id": &"sprint", "pos": jc + Vector2(-1.5 * r, -1.9 * r), "r": sr, "text": "Yugur"},
        {"id": &"interact", "pos": jc + Vector2(0.0, -2.5 * r), "r": sr, "text": "Amal"},
        {"id": &"pause", "pos": pc, "r": pr, "text": "II"},
        {"id": &"camera", "pos": pc + Vector2(-2.4 * pr, 0.0), "r": pr, "text": "Kamera"},
    ]
    # Ekrandan chiqib ketmasligi uchun qisish
    for b in list:
        var p: Vector2 = b["pos"]
        var rr: float = b["r"]
        p.x = clampf(p.x, float(m["left"]) + rr + 8.0, s.x - float(m["right"]) - rr - 8.0)
        p.y = clampf(p.y, float(m["top"]) + rr + 8.0, s.y - float(m["bottom"]) - rr - 8.0)
        b["pos"] = p
    return list

func _hit_button(pos: Vector2) -> StringName:
    for b in _buttons():
        if pos.distance_to(b["pos"]) <= float(b["r"]) * 1.2:
            return b["id"]
    return &""

func _idle_stick_center() -> Vector2:
    var s := _vp_size()
    var m := SafeAreaContainer.compute(s)
    var r := _stick_radius()
    return Vector2(float(m["left"]) + r + 40.0, s.y - float(m["bottom"]) - r - 40.0)

# ---------------- Kirish ----------------
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and not event.canceled:
            _on_press(event.index, event.position)
        else:
            _on_release(event.index, event.canceled)
        queue_redraw()
    elif event is InputEventScreenDrag:
        if event.index == _move_touch:
            var radius := _stick_radius()
            var offset: Vector2 = (event.position - _stick_origin).limit_length(radius)
            _stick_pos = _stick_origin + offset
            move_changed.emit(offset / radius)
            queue_redraw()
        elif event.index == _look_touch:
            look_delta.emit(event.relative)

func _on_press(index: int, pos: Vector2) -> void:
    var hit := _hit_button(pos)
    if hit != &"":
        _btn_touches[index] = hit
        match hit:
            &"jump": jump_pressed.emit()
            &"sprint": sprint_pressed.emit()
            &"interact": interact_pressed.emit()
            &"camera": camera_pressed.emit()
            &"pause": pause_pressed.emit()
            &"crouch":
                _crouch_time = 0.0
                _crouch_consumed = false
        return
    if _move_touch == -1 and pos.x < _vp_size().x * 0.4:
        _move_touch = index
        _stick_origin = pos
        _stick_pos = pos
    elif _look_touch == -1 and pos.x >= _vp_size().x * 0.4:
        _look_touch = index

func _on_release(index: int, canceled: bool) -> void:
    if index == _move_touch:
        _move_touch = -1
        move_changed.emit(Vector2.ZERO)
    elif index == _look_touch:
        _look_touch = -1
    elif _btn_touches.has(index):
        if _btn_touches[index] == &"crouch" and not _crouch_consumed and not canceled:
            crouch_pressed.emit()
        _btn_touches.erase(index)

func _process(delta: float) -> void:
    if _btn_touches.values().has(&"crouch") and not _crouch_consumed:
        _crouch_time += delta
        if _crouch_time >= LONG_PRESS:
            _crouch_consumed = true
            crawl_pressed.emit()

# ---------------- Chizish ----------------
func _draw() -> void:
    var radius := _stick_radius()
    if _move_touch != -1:
        draw_circle(_stick_origin, radius, Color(1, 1, 1, 0.12))
        draw_circle(_stick_pos, radius * 0.42, Color(1, 1, 1, 0.38))
    else:
        draw_circle(_idle_stick_center(), radius, Color(1, 1, 1, 0.06))
    var pressed_ids := _btn_touches.values()
    for b in _buttons():
        var id: StringName = b["id"]
        var on := pressed_ids.has(id) or (id == &"sprint" and sprint_active)
        var r: float = b["r"]
        var pos: Vector2 = b["pos"]
        draw_circle(pos, r, Color(1, 1, 1, 0.34 if on else 0.14))
        draw_arc(pos, r, 0.0, TAU, 32, Color(1, 1, 1, 0.4), 2.0)
        var fs := int(clampf(r * 0.34, 14.0, 26.0))
        draw_string(ThemeDB.fallback_font, pos + Vector2(-r, fs * 0.35), b["text"],
            HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, Color(1, 1, 1, 0.85))
