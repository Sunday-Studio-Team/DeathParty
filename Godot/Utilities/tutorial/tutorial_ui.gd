# this script handles the pop-ups at the start of the game which tell the player
# the controls etc.

# it also handles locking movement during the title screen,
# enabling the scene loader for exiting the room once the tutorial is over,
# and some other triggers for tutorial stuff

# NOTE: tutorial_ui is probably a bad name for it because of that other non-ui
#		stuff it does sorry lol

# TODO: maybe change this scripts name to tutorial_manager or something

extends CanvasLayer

signal toggle_corkboard_interactable(value: bool)

@export var rowan_invite_dialogue: JSON
@export var example_json: JSON
@export var on_phone_close_dialogue: JSON
@export var on_journal_dialogue: JSON

@export var exterior_scene_loader: SceneLoader
@export var polaroid_camera: Interactable
@export var corkboard_popup: Node3D

@onready var loading_timer: Timer = %LoadingTimer
@onready var move_controls_popup: PanelContainer = %MoveControlsPopup
@onready var walk_complete_timer: Timer = %WalkCompleteTimer
@onready var phone_controls_popup: PanelContainer = %PhoneControlsPopup
@onready var journal_controls_popup: PanelContainer = %JournalControlsPopup

enum States {
	INTRO, WALK, WALK_COMPLETE, UNLOCK_PHONE, USING_PHONE,
	OPEN_JOURNAL, USING_JOURNAL, PICK_UP_CAMERA, TAKE_PICTURE, TUTORIAL_FINISHED
	}

var state: States:
	set(new_state):
		state = new_state
		match new_state:
			States.INTRO:
				print("TUTORIAL STEP: INTRO")
			States.WALK:
				print("TUTORIAL STEP: WALK")
				Globals.player.movement_disabled = false
				move_controls_popup.show()
			States.WALK_COMPLETE:
				print("TUTORIAL STEP: WALK COMPLETE")
				GuiSystem.set_gui_enabled(true)
				walk_complete_timer.start()
			States.UNLOCK_PHONE:
				print("TUTORIAL STEP: UNLOCK PHONE")
				move_controls_popup.hide()
				phone_controls_popup.show()
				DialogueSystem.to_phone("Rowan", rowan_invite_dialogue)
			States.USING_PHONE:
				print("TUTORIAL STEP: USING PHONE")
				phone_controls_popup.hide()
			States.OPEN_JOURNAL:
				DialogueSystem.begin_dialogue(on_phone_close_dialogue)
				print("TUTORIAL STEP: OPEN JOURNAL")
				journal_controls_popup.show()
			States.USING_JOURNAL:
				print("TUTORIAL STEP: USING JOURNAL")
				DialogueSystem.begin_dialogue(on_journal_dialogue)
				journal_controls_popup.hide()
			States.PICK_UP_CAMERA:
				print("TUTORIAL STEP: PICK UP CAMERA")
				polaroid_camera.enabled = true
				polaroid_camera.interaction_detector.player_interacted.connect(on_camera_interacted)
			States.TAKE_PICTURE:
				print("TUTORIAL STEP: TAKE PICTURE")
				polaroid_camera.queue_free()
				toggle_corkboard_interactable.emit(true)
			States.TUTORIAL_FINISHED:
				print("TUTORIAL STEP: FINISHED")
				toggle_corkboard_interactable.emit(false)
				exterior_scene_loader.enabled = true
				queue_free()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GuiSystem.set_gui_enabled(false)
	state = States.INTRO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	match state:
		States.INTRO:
			# we're setting this in the physics process here because the player
			# could be null if we set it during _ready or in the setter for the
			# INTRO state (lmk if theres a better way lol)
			if Globals.player:
				Globals.player.movement_disabled = true
		States.WALK:
			if Globals.player.player_velocity != Vector3.ZERO:
				increment_state()
		States.UNLOCK_PHONE:
			if GuiSystem.in_phone == true:
				increment_state()
		States.USING_PHONE:
			if GuiSystem.in_phone == false:
				increment_state()
		States.OPEN_JOURNAL:
			if GuiSystem.in_journal == true:
				increment_state()
		States.USING_JOURNAL:
			# theres some dialogue when we first open the journal which puts the dialogue system
			# into its waiting state which blocks the input for toggling the journal (i think)
			# so here we're manually checking for that to allow the player to close the journal
			# with the hotkey the first time its opened - i think this is fine but if we plan
			# to have a few places where theres dialogue in the journal then maybe there
			# should be a global way to handle that 🫡
			if Input.is_action_just_pressed("toggle_journal") and DialogueSystem.waiting:
				GuiSystem.hide_journal()
			if GuiSystem.in_journal == false:
				increment_state()
		States.TAKE_PICTURE:
			if Globals.polaroid_camera_ui.visible:
				corkboard_popup.hide()
				increment_state()


func _on_bedroom_intro_finished() -> void:
	increment_state()


func _on_walk_complete_timer_timeout() -> void:
	increment_state()


func increment_state() -> void:
	state = (state + 1) as States


func on_camera_interacted() -> void:
	if state == States.PICK_UP_CAMERA:
		increment_state()
