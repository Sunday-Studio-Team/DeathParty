class_name ChatResource extends DefaultResource

@export var image : CompressedTexture2D

#Display participants on name hover
var participants : Array[CharacterResource] = [] #Characters in group chat

#Chats
var upcoming_chats : Array[JSON] = []
var past_chats : Array[InkLineInfo]
var display_timestamp : float = 0.0
var display_message : String = ""
var chat_in_progress : bool = false

#Pausing/Resuming
var paused_ink_tree : InkTree
var paused_ink_address : InkAddress

signal unread

##INHERITED
func initialize() -> void:
	parse_participants()
	DialogueSystem.loaded_new_contact.emit(self)
##

func update_chat_info() -> void:
	var json_file : JSON = upcoming_chats.front()
	if(json_file):
		print("Getting chat info for ", json_file.resource_path)
		display_timestamp = SaveSystem.get_key("time")
		display_message = DialogueSystem.get_first_message(json_file).text

func load_chat(json : JSON) -> void:
	upcoming_chats.push_back(json)
	update_chat_info()

	#Phone notification
	var notif_instance : PhoneNotification = DialogueSystem.phone_notification_prefab.instantiate()
	notif_instance.set_notif_name(self)
	notif_instance.set_picture(self)
	DialogueSystem.notification_box.add_child(notif_instance)
	#end notification

	unread.emit(true)
	
func start_chat() -> void:
	if (paused_ink_address):
		print("Starting chat: ", name, " | ", paused_ink_address.container.path, ".", paused_ink_address.index)
	else:
		print("No hierarchy starting chat: ", name)
	DialogueSystem.load_past_messages(past_chats) #load it even if there are no new messages so player can see old ones
	var new_json : JSON = upcoming_chats.front()
	if new_json == null:
		chat_in_progress = false
		return
	if paused_ink_address:
		print("Chat is in progress: ", name)
		DialogueSystem.resume_dialogue(paused_ink_address, self)
	else:
		DialogueSystem.begin_dialogue(new_json, true)
	chat_in_progress = true
	
func pause_chat(current_conversation : Array[InkLineInfo]) -> void:
	if chat_in_progress: #ONLY if in progress or it will save the wrong messages
		#save added lines
		past_chats = current_conversation
		print(name, " is saving past chats as ", past_chats)
		#save current InkTree address
		paused_ink_address = DialogueSystem.current_address #saves current variables
		update_chat_info()

func end_chat(current_conversation : Array[InkLineInfo]) -> void:
	past_chats = current_conversation
	upcoming_chats.pop_front() #get it off the list
	chat_in_progress = false
	if upcoming_chats.size() == 0:
		unread.emit(false)

func parse_participants() -> void:
	var name_split : Array = Array(name.split(", "))
	for person_name : String in name_split:
		var person : CharacterResource = SaveSystem.get_character(person_name)
		participants.push_back(person)
