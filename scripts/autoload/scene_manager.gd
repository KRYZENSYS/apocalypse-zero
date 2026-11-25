extends Node
## Sahna almashtirish. AUTOLOAD: SceneManager

signal scene_changed(path: String)

const MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const TEST_WORLD := "res://scenes/world/test_world.tscn"

func goto_scene(path: String) -> void:
    if not ResourceLoader.exists(path):
        push_error("Sahna topilmadi: %s" % path)
        return
    get_tree().paused = false
    var err := get_tree().change_scene_to_file(path)
    if err != OK:
        push_error("Sahnani almashtirib bo'lmadi (%s): %s" % [path, error_string(err)])
        return
    scene_changed.emit(path)
