class_name NPC extends Interactable

var outline: Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var character_resource: CharacterResource
@export var dialogue_box: DialogueBoxResource = preload("res://Assets/Resources/DialogueBoxResources/main_dialogue_box_properties.tres")


func _ready() -> void:
	super()
	if character_resource:
		#Get the current character resource from the save file
		character_resource = SaveSystem.get_character(character_resource.name)
		#Connect signals
		character_resource.unread.connect(on_unread)

		if popup:
			popup.find_child("NameLabel").text = character_resource.name


func on_unread(_unread: bool) -> void:
	#$SpeechBubble.visible = true
	pass

##INHERITED
func on_in_range(in_range: bool) -> void:
	##only show the outline if NPC has something to say
	var show_outline: bool = false
	if character_resource:
		if character_resource.has_chats():
			show_outline = true
	if show_outline:
		super(in_range)

func on_interact() -> void:
	super()
	if character_resource:
		character_resource.start_chat()
		
func play_animation(anim_name: String) -> void:
	animation_player.play(anim_name)
