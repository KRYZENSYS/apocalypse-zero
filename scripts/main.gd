extends Node
## Kirish sahnasi: darhol asosiy menyuga o'tadi.

func _ready() -> void:
    SceneManager.goto_scene.call_deferred(SceneManager.MAIN_MENU)
