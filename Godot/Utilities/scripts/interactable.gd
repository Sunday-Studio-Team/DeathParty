class_name Interactable extends Area3D

@export var primary_mesh: MeshInstance3D
@export var use_first_mesh: bool = true
@export var outline_thickness: float = .7

@export var talking_object_resource: TalkingObjectResource

#@export var outline_shader : ShaderMaterial = preload("res://Assets/Shaders/OutlineShader.tres")
var outline_shader: ShaderMaterial = preload("res://Assets/Shaders/OutlineShader/TestOutlineShader.tres")
var interaction_detector_file: PackedScene = preload("res://Entities/interaction_detector.tscn")
var interaction_detector: InteractionDetector

@export var enabled: bool = true:
	set(value):
		enabled = value
		# call on_in_range if the player is already standing in the interactable
		# area when the interactable gets enabled (since otherwise it wouldnt
		# get an on_entered signal since the player's already in there)
		if enabled and interaction_detector:
			print("Checking if enabled: ", interaction_detector)
			var overlapping_bodies: Array = interaction_detector.get_overlapping_bodies()
			for body: PhysicsBody3D in overlapping_bodies:
				if body == Globals.player:
					on_in_range(true)

var popup: Node3D
var surface_material: StandardMaterial3D = null


func _ready() -> void:
	#print("New interctable")
	interaction_detector = get_node_or_null("InteractionDetector")
	if interaction_detector == null:
		interaction_detector = interaction_detector_file.instantiate()
		var char_body: CharacterBody3D = get_node_or_null("CharacterBody3D")
		if char_body:
			char_body.add_child(interaction_detector)
		else:
			add_child(interaction_detector)
	interaction_detector.player_interacted.connect(on_interact)
	interaction_detector.player_in_range.connect(on_in_range)
	
	#Get the popup that will be used:
	popup = get_node_or_null("Popup")
	
	#print("Loading ", name, ": ", primary_mesh, " ", use_first_mesh)
	if primary_mesh:
		create_outline()
	elif use_first_mesh:
		primary_mesh = Utils.find_first_child_of_class(self, MeshInstance3D)
		create_outline()
	if popup:
		popup.visible = false

		
func create_outline() -> void:
	#print("Creating outline")
	if primary_mesh == null: return
	surface_material = primary_mesh.get_active_material(0)
	var new_shader: ShaderMaterial = outline_shader.duplicate()
	new_shader.set_shader_parameter("alpha", 0)
	new_shader.set_shader_parameter("thickness", outline_thickness)
	surface_material.next_pass = new_shader
	
func toggle_popup(on: bool) -> void:
	if popup:
		popup.visible = on
	if surface_material:
		var value: float
		if on:
			value = 1.0
		else:
			value = 0.0
		var shader: ShaderMaterial = surface_material.next_pass

		# this is commented out to disable the outline shader temporarily
		# should work like normal if we un-comment
		#shader.set_shader_parameter("alpha", value)
	if talking_object_resource:
		talking_object_resource = SaveSystem.get_talking_object(talking_object_resource.name)


##OVERRIDE THESE METHODS (but call super() at the beginning)
func on_interact() -> void:
	if !enabled :return
	toggle_popup(false)
	if talking_object_resource:
		talking_object_resource.start_chat()


func on_in_range(in_range: bool) -> void:
	if !enabled: return
	toggle_popup(in_range)
