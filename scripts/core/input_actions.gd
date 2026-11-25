extends RefCounted
## Barcha InputMap action nomlari BIR JOYDA. Boshqa joyda matn yozmang, shu konstantalarni ishlating.

const MOVE_FORWARD := &"move_forward"
const MOVE_BACK := &"move_back"
const MOVE_LEFT := &"move_left"
const MOVE_RIGHT := &"move_right"
const JUMP := &"jump"
const SPRINT := &"sprint"
const CROUCH := &"crouch"
const CRAWL := &"crawl"
const INTERACT := &"interact"
const TOGGLE_CAMERA := &"toggle_camera"
const PAUSE := &"pause"

## Faqat KLAVIATURA (kompyuterda sinov uchun). Sensorli tugmalar mobile_controls.gd da.
static func register() -> void:
    var keys := {
        MOVE_FORWARD: KEY_W, MOVE_BACK: KEY_S, MOVE_LEFT: KEY_A, MOVE_RIGHT: KEY_D,
        JUMP: KEY_SPACE, SPRINT: KEY_SHIFT, CROUCH: KEY_C, CRAWL: KEY_Z,
        INTERACT: KEY_E, TOGGLE_CAMERA: KEY_V, PAUSE: KEY_ESCAPE,
    }
    for action in keys:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            var ev := InputEventKey.new()
            ev.physical_keycode = keys[action]
            InputMap.action_add_event(action, ev)
