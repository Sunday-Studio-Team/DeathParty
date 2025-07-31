extends Room3D

@export var things_to_hide : Node3D

func _ready() -> void:
	super()
	GlobalPlayerScript.player_moved.connect(_change_visibility)
	body_entered.connect(handle_player_entrance)


func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	
	keep_camera_on_player(body)
	bind_camera_LR(body)
	bind_camera_y(body)
	bind_camera_depth(body)
	FmodServer.set_global_parameter_by_name_with_label("room", "front room")

func _change_visibility(pos: Vector3) -> void:
	if(background_plane.distance_to(pos) < 0):
		things_to_hide.visible = false
	else:
		things_to_hide.visible = true
