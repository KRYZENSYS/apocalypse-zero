extends Control
## Asosiy menyu (UI kod orqali quriladi).

const SafeAreaContainer := preload("res://scripts/ui/safe_area_container.gd")
const SettingsPanel := preload("res://scripts/ui/settings_panel.gd")

var _menu_box: VBoxContainer
var _settings: PanelContainer
var _about: PanelContainer
var _toast: Label
var _continue_btn: Button

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _build_ui()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.05, 0.07, 0.10)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var safe := MarginContainer.new()
    safe.set_script(SafeAreaContainer)
    safe.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(safe)

    var center := CenterContainer.new()
    safe.add_child(center)

    var stack := Control.new()  # menyu / sozlamalar / haqida bir joyda almashadi
    center.add_child(stack)

    # --- Asosiy menyu ---
    _menu_box = VBoxContainer.new()
    _menu_box.add_theme_constant_override("separation", 14)
    stack.add_child(_menu_box)

    var title := Label.new()
    title.text = "PROJECT APOCALYPSE ZERO"
    title.add_theme_font_size_override("font_size", 46)
    title.add_theme_color_override("font_color", Color(0.9, 0.33, 0.24))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _menu_box.add_child(title)

    _continue_btn = _make_button("Davom etish", _on_continue)
    _continue_btn.disabled = not GameManager.has_save()
    _make_button("Yangi o‘yin", _on_new_game)
    _make_button("Yuklash", _on_load)
    _make_button("Sozlamalar", func() -> void: _show_panel(_settings))
    _make_button("O‘yin haqida", func() -> void: _show_panel(_about))
    _make_button("Chiqish", func() -> void: GameManager.quit_game())

    # --- Sozlamalar ---
    _settings = SettingsPanel.new()
    _settings.visible = false
    _settings.closed.connect(func() -> void: _show_panel(null))
    stack.add_child(_settings)

    # --- O'yin haqida ---
    _about = PanelContainer.new()
    _about.visible = false
    _about.custom_minimum_size = Vector2(620, 0)
    var ab := VBoxContainer.new()
    ab.add_theme_constant_override("separation", 16)
    _about.add_child(ab)
    var at := Label.new()
    at.text = "PROJECT APOCALYPSE ZERO\nVersiya: %s\nGodot 4 • Android • To‘liq offline\n\nBu 1-bosqich: loyiha poydevori.\nAsosiy o‘yin tizimlari keyingi bosqichlarda qo‘shiladi." % GameManager.GAME_VERSION
    at.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    at.add_theme_font_size_override("font_size", 24)
    ab.add_child(at)
    var ab_back := Button.new()
    ab_back.text = "Orqaga"
    ab_back.custom_minimum_size = Vector2(0, 60)
    ab_back.add_theme_font_size_override("font_size", 26)
    ab_back.pressed.connect(func() -> void: _show_panel(null))
    ab.add_child(ab_back)
    stack.add_child(_about)

    # --- Xabar (toast) ---
    _toast = Label.new()
    _toast.add_theme_font_size_override("font_size", 24)
    _toast.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    _toast.position.y -= 60
    _toast.visible = false
    add_child(_toast)

func _make_button(text: String, callback: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(420, 64)
    b.add_theme_font_size_override("font_size", 28)
    b.pressed.connect(callback)
    _menu_box.add_child(b)
    return b

func _show_panel(panel: Control) -> void:
    _menu_box.visible = panel == null
    _settings.visible = panel == _settings
    _about.visible = panel == _about

func _show_toast(msg: String) -> void:
    _toast.text = msg
    _toast.visible = true
    await get_tree().create_timer(2.5).timeout
    if is_instance_valid(_toast):
        _toast.visible = false

func _on_new_game() -> void:
    GameManager.start_new_game()

func _on_continue() -> void:
    if not GameManager.load_game():
        _show_toast("Saqlangan o‘yin topilmadi.")

func _on_load() -> void:
    if not GameManager.load_game():
        _show_toast("Saqlangan o‘yin topilmadi.")
