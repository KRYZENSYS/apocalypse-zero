extends Node
## Oddiy holat mashinasi. Yangi holat qo'shish: add_state(node) + change_to(nom).

var player
var states: Dictionary = {}
var current: Node = null
var current_name: StringName = &""

func add_state(state: Node) -> void:
    state.player = player
    state.machine = self
    states[state.name] = state
    add_child(state)

func change_to(state_name: StringName) -> void:
    if not states.has(state_name):
        push_error("Holat topilmadi: %s" % state_name)
        return
    var prev := current_name
    if current:
        current.exit()
    current = states[state_name]
    current_name = state_name
    current.enter(prev)

func physics_update(delta: float) -> void:
    if current:
        current.physics_update(delta)
