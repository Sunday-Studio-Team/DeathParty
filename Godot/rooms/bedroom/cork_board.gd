extends Interactable


@export var title:CanvasLayer


func on_interact() -> void:
	# NOTE: this kind of confused me because i couldn't get this interactable
	#		to respect whether it was enabled or not, and i think it was
	#		because the `if !enabled: return` in the interactable class wasn't
	#		stopping this object specific stuff below from executing even if it
	#		was disabled - it only seems to behave correctly if i add this
	#		enabled check here too 💭
	#				- jack
	if !enabled: return
	super()
	title.visible=false
	Globals.polaroid_camera_ui.visible=true
	print("camera scene should be on")


func _on_tutorial_ui_toggle_corkboard_interactable(value: bool) -> void:
	if value == true:
		enabled = true
	else:
		enabled = false
