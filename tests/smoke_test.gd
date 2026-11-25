extends SceneTree
## Yengil tekshiruv (TEKSHIRILMAGAN): barcha sahnalar yuklanishini sinaydi.
## Ishga tushirish: godot --headless --path . --script res://tests/smoke_test.gd

func _init() -> void:
    var paths := [
        "res://scenes/main.tscn",
        "res://scenes/ui/main_menu.tscn",
        "res://scenes/ui/pause_menu.tscn",
        "res://scenes/ui/mobile_controls.tscn",
        "res://scenes/player/player.tscn",
        "res://scenes/world/test_world.tscn",
    ]
    var fails := 0
    for p in paths:
        var res := load(p)
        if res == null:
            print("FAIL  ", p)
            fails += 1
        else:
            print("OK    ", p)
    print("Natija: %d xato" % fails)
    quit(fails)
