#call send_message.emit(str) in drone.gd to send messages from the drone
extends Control

@onready var container = $VBoxContainer

@export var max_msg_num: int = 5

var messages: Array = []

func _ready() -> void:
	update_display()

func update_display():
	while !messages.is_empty():
		var m = messages.pop_front()
		container.add_child(m)
		msg_fade_in(m)
		
		if container.get_child_count() > max_msg_num:
			var first = container.get_child(0)
			await msg_fade_out(first)
			container.remove_child(first)
			first.queue_free()
			
func msg_fade_out(msg: Label):
	var tween = get_tree().create_tween()
	tween.tween_property(msg, "modulate:a", 0, 0.5)
	await tween.finished
	
func msg_fade_in(msg: Label):
	var tween = get_tree().create_tween()
	tween.tween_property(msg, "modulate:a", 1, 0.5).from(0)
	await tween.finished

func to_label(msg: String) -> Label:
	var msg_label = Label.new()
	msg_label.text = msg
	return msg_label

func _on_receive_message(msg: String):
	messages.append(to_label(msg))
	update_display()
