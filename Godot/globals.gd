extends Node

enum SCENES {
	Everywhere = 0,
	Nowhere = 1,
	Entrance = 2,
	PartyRoom = 3,
	Library = 4,
	Bathroom = 5,
	Basement = 6,
	Bedroom = 7,
	StorageRoom = 8,
	Exterior = 9,
	Kitchen = 10,
	HourhandHallway = 11,
	ControlRoom = 12,
	GhostHallway = 13,
}

const SCENES_STR: Dictionary[String, SCENES] = {
	"Everywhere" = SCENES.Everywhere,
	"Nowhere" = SCENES.Nowhere,
	"Entrance" = SCENES.Entrance,
	"PartyRoom" = SCENES.PartyRoom,
	"Library" = SCENES.Library,
	"Bathroom" = SCENES.Bathroom,
	"Basement" = SCENES.Basement,
	"Bedroom" = SCENES.Bedroom,
	"Storageroom" = SCENES.StorageRoom,
	"Exterior" = SCENES.Exterior,
	"Kitchen" = SCENES.Kitchen,
	"Hourhand hallway" = SCENES.HourhandHallway,
	"Control room" = SCENES.ControlRoom,
	"Ghost hallway" = SCENES.GhostHallway,
}
##

func get_scene_name(scene_enum: Globals.SCENES) -> String:
	for sc_name: String in Globals.SCENES_STR:
		if Globals.SCENES_STR[sc_name] == scene_enum:
			return sc_name
	return ""

enum SPAWN_OPTIONS {
	ONE,
	TWO,
	THREE,
	FOUR,
}

var player: Player

var polaroid_camera_ui: CanvasLayer

var jog_controls_popup_shown := false
