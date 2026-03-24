extends Node

@onready var button_audio = $ButtonAudio

func _ready() -> void:
	connect_sounds()
		
func connect_sounds():
	var buttons: Array = get_tree().get_nodes_in_group("buttons")
	for b in buttons:
		b.connect("pressed", _on_button_pressed)
		
func _on_button_pressed():
	button_audio.play()
