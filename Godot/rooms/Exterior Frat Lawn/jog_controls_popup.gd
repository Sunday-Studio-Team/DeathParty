extends CanvasLayer


@onready var show_timer: Timer = %ShowTimer
@onready var hide_timer: Timer = %HideTimer


func _on_show_timer_timeout() -> void:
	if not Globals.jog_controls_popup_shown:
		show()
		hide_timer.start()
		Globals.jog_controls_popup_shown = true


func _on_hide_timer_timeout() -> void:
	hide()
