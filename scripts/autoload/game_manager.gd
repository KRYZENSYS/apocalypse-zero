extends Node
## Umumiy o'yin holati. AUTOLOAD: GameManager
## ESLATMA: saqlash tizimi hozircha PLACEHOLDER (to'liq tizim 19-bosqichda).

signal back_requested

const GAME_VERSION := "0.2.0-stage2"
const SAVE_PATH := "user://savegame.json"
const InputActions := preload("res://scripts/core/input_actions.gd")

func _ready() -> void:
    InputActions.register()

func _notification(what: int) -> void:
    # Android "orqaga" tugmasi
    if what == NOTIFICATION_WM_GO_BACK_REQUEST:
        back_requested.emit()

func uses_touch_controls() -> bool:
    return DisplayServer.is_touchscreen_available() or bool(SettingsManager.get_value("force_touch_controls"))

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func start_new_game() -> void:
    # PLACEHOLDER: faqat minimal fayl yozadi.
    var data := {"version": GAME_VERSION, "created_unix": Time.get_unix_time_from_system()}
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        push_error("Saqlash faylini yozib bo'lmadi: %s" % error_string(FileAccess.get_open_error()))
    else:
        f.store_string(JSON.stringify(data))
        f.close()
    SceneManager.goto_scene(SceneManager.TEST_WORLD)

func load_game() -> bool:
    if not has_save():
        return false
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return false
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    f.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Saqlash fayli buzilgan.")
        return false
    SceneManager.goto_scene(SceneManager.TEST_WORLD)
    return true

func quit_game() -> void:
    get_tree().quit()
