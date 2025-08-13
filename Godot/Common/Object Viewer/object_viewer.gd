class_name ObjectViewer extends CanvasLayer

#The item that will be viewed by the object viewer
@export var active_item : Node3D
@export var rotate_off : bool = false

@export var test_path : String
var pressed : bool = false

#Moves the item and camara offscreen by pushing it by a large offset
@export var hide_offset : int = -1000

@onready var sub_viewport: SubViewport = %SubViewport
@onready var model_holder: Node3D = %"Model Holder"
@onready var camera_3d: Camera3D = %Camera3D

# NOTE: the lines in this script that reference 'light' are commented out
# to avoid crashes (since the directional light in the object viewer
# was moved to the main scene)

#@onready var light : DirectionalLight3D = $SubViewportContainer/SubViewport/Light

#Custom background
@onready var color_rect : ColorRect = %ColorRect
@onready var blur : Panel = %Blur
@onready var custom_background_container : Control = %CustomBackground
@onready var item_info : ItemInfoContainer = %ItemInfo

var light_up_shader : ShaderMaterial = preload("res://Assets/Shaders/LightUpShader.tres")

var currently_open : bool = false

signal enabled

#Places the item into the viewport and defines the "item" variable
func set_item(item_path : String) -> void:
	var scene : Node = load(item_path).instantiate()
	if scene == null:
		print("Scene Path not working")
		return
	set_item_properties(scene)

func set_preexisting_item(instance : Node3D) -> void:
	var scene : Node3D = set_item_properties(instance)
	
func apply_shader_to_meshes_recursive(current_node : Node) -> void:
	if current_node is MeshInstance3D:
		var current_material : Material = current_node.material_overlay
		if current_material == null:
			current_material = current_node.surface_get_material(0)
		if current_material == null:
			current_material = current_node.surface_get_material(1)
		if current_material == null:
			current_material = StandardMaterial3D.new()
		self.material_override = light_up_shader
		self.material_override.set_shader_parameter("albedo_texture", current_material.albedo_texture)
	var children : Array[Node] = current_node.get_children()
	if children.size() > 0:
		for child : Node in children:
			apply_shader_to_meshes_recursive(child)
	
func set_item_properties(scene : Node3D) -> Node3D:
	visible = true
	Interact.set_active_subviewport(sub_viewport)
	remove_current_item()
	
	#apply shader that lights up the mesh
	#apply_shader_to_meshes_recursive(self)
	
	scene.transform.origin.y = scene.transform.origin.y + hide_offset
	scene.transform.origin.z = scene.transform.origin.z + hide_offset
	model_holder.add_child(scene)

	active_item = scene
	#light.visible = true
	enabled.emit(true, camera_3d)
	return scene
	
func remove_current_item(queue_free : bool = true) -> void:
	Interact.clear_active_subviewport()
	#light.visible = false
	#Remove ALL items in the model holder
	enabled.emit(false, camera_3d)
	
	var children = model_holder.get_children()
	if children.size() > 0:
		currently_open = true
	else:
		currently_open = false
	for child in children:
		model_holder.remove_child(child)
		if queue_free and !(child is Journal):
			child.queue_free()
		else:
			#REMOVE OFFSET
			child.transform.origin.y = child.transform.origin.y - hide_offset
			child.transform.origin.z = child.transform.origin.z - hide_offset
		
	active_item = null

#TODO
#At origin, the object interferes with the world map. Need to move it away from the world map so that it's visible properly.
#Also need to assign object based on "item" variable not hard coded. 
func _ready() -> void:	
	#set_item(test_path)
	camera_3d.transform.origin.y = camera_3d.transform.origin.y + hide_offset
	camera_3d.transform.origin.z = camera_3d.transform.origin.z + hide_offset
	item_info.visible = false

func zoom(factor : float):
	active_item.scale = active_item.scale*factor

func zoom_absolute(factor : float):
	active_item.scale = Vector3.ONE*factor

#Scroll in and out of item
func _input(event) -> void:
	if active_item == null: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and Interact.grabbed_scroll_container == null:
			zoom(1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and Interact.grabbed_scroll_container == null:
			zoom(0.87)
		#elif event.button_index == MOUSE_BUTTON_LEFT and Interact.grabbed_object == null:
		#	GuiSystem.show_journal()
	
#Resets the position of the item
func reset_item_position() -> void:
	if active_item:
		active_item.rotation.x = 0
		active_item.rotation.y = 0
	
func clear_custom_background():
	for child in custom_background_container.get_children():
		custom_background_container.remove_child(child)
		child.queue_free()
		
func set_background(scene : PackedScene = null) -> void:
	clear_custom_background()
	if scene:
		custom_background_container.add_child(scene.instantiate())
		
func view_item_info(title : String, description : String):
	item_info.set_text(description)
	item_info.visible = true
