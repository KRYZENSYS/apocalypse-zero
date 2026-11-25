extends PanelContainer
## Sozlamalar paneli (asosiy menyu va pauza menyusida ishlatiladi).

signal closed

func _ready() -> void:
    custom_minimum_size = Vector2(620, 0)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 18)
    add_child(box)

    var title := Label.new()
    title.text = "Sozlamalar"
    title.add_theme_font_size_override("font_size", 36)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)

    # Umumiy ovoz
    var vol := HSlider.new()
    vol.min_value = 0.0
    vol.max_value = 1.0
    vol.step = 0.05
    vol.value = float(SettingsManager.get_value("master_volume"))
    vol.custom_minimum_size = Vector2(300, 40)
    vol.value_changed.connect(func(v: float) -> void: SettingsManager.set_value("master_volume", v))
    _add_row(box, "Umumiy ovoz", vol)

    # Grafika sifati
    var quality := OptionButton.new()
    for q in SettingsManager.QUALITY_NAMES:
        quality.add_item(q)
    quality.selected = int(SettingsManager.get_value("quality"))
    quality.custom_minimum_size = Vector2(300, 48)
    quality.item_selected.connect(func(i: int) -> void: SettingsManager.set_value("quality", i))
    _add_row(box, "Grafika sifati", quality)

    # Kamera sezgirligi
    var sens := HSlider.new()
    sens.min_value = 0.3
    sens.max_value = 2.5
    sens.step = 0.1
    sens.value = float(SettingsManager.get_value("look_sensitivity"))
    sens.custom_minimum_size = Vector2(300, 40)
    sens.value_changed.connect(func(v: float) -> void: SettingsManager.set_value("look_sensitivity", v))
    _add_row(box, "Kamera sezgirligi", sens)

    # Sensorli tugmalar o'lchami
    var ui := HSlider.new()
    ui.min_value = 0.7
    ui.max_value = 1.5
    ui.step = 0.1
    ui.value = float(SettingsManager.get_value("touch_ui_scale"))
    ui.custom_minimum_size = Vector2(300, 40)
    ui.value_changed.connect(func(v: float) -> void: SettingsManager.set_value("touch_ui_scale", v))
    _add_row(box, "Tugmalar o‘lchami", ui)

    # FPS
    var fps := CheckButton.new()
    fps.button_pressed = bool(SettingsManager.get_value("show_fps"))
    fps.toggled.connect(func(on: bool) -> void: SettingsManager.set_value("show_fps", on))
    _add_row(box, "FPS ko‘rsatish", fps)

    # Sensorli boshqaruvni majburlash (sinov uchun)
    var touch := CheckButton.new()
    touch.button_pressed = bool(SettingsManager.get_value("force_touch_controls"))
    touch.toggled.connect(func(on: bool) -> void: SettingsManager.set_value("force_touch_controls", on))
    _add_row(box, "Sensorli boshqaruv (majburiy)", touch)

    var back := Button.new()
    back.text = "Orqaga"
    back.custom_minimum_size = Vector2(0, 60)
    back.add_theme_font_size_override("font_size", 26)
    back.pressed.connect(func() -> void: closed.emit())
    box.add_child(back)

func _add_row(parent: Control, label_text: String, control: Control) -> void:
    var row := HBoxContainer.new()
    var l := Label.new()
    l.text = label_text
    l.add_theme_font_size_override("font_size", 24)
    l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(l)
    row.add_child(control)
    parent.add_child(row)
