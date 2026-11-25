extends MarginContainer
## Xavfsiz zona (notch / yumaloq burchaklar) uchun chekka qoldiradi.

const MIN_MARGIN := 16

## Viewport koordinatalarida xavfsiz zona chekkalarini qaytaradi.
## Faqat mobil qurilmada ishlaydi, kompyuterda nol qaytaradi.
static func compute(viewport_size: Vector2) -> Dictionary:
    var m := {"left": 0.0, "top": 0.0, "right": 0.0, "bottom": 0.0}
    if not OS.has_feature("mobile"):
        return m
    var win := Vector2(DisplayServer.window_get_size())
    var safe: Rect2i = DisplayServer.get_display_safe_area()
    if win.x <= 0.0 or win.y <= 0.0 or safe.size == Vector2i.ZERO:
        return m
    var f := Vector2(viewport_size.x / win.x, viewport_size.y / win.y)
    m["left"] = maxf(float(safe.position.x), 0.0) * f.x
    m["top"] = maxf(float(safe.position.y), 0.0) * f.y
    m["right"] = maxf(win.x - float(safe.end.x), 0.0) * f.x
    m["bottom"] = maxf(win.y - float(safe.end.y), 0.0) * f.y
    return m

func _ready() -> void:
    get_viewport().size_changed.connect(_update_margins)
    _update_margins()

func _update_margins() -> void:
    var m := compute(get_viewport().get_visible_rect().size)
    add_theme_constant_override("margin_left", int(m["left"]) + MIN_MARGIN)
    add_theme_constant_override("margin_top", int(m["top"]) + MIN_MARGIN)
    add_theme_constant_override("margin_right", int(m["right"]) + MIN_MARGIN)
    add_theme_constant_override("margin_bottom", int(m["bottom"]) + MIN_MARGIN)
