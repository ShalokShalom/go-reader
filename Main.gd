extends Control

onready var MenuContext = get_node("MenuContext")
onready var SourceLoader = get_node("Core/SourceLoader")
onready var Streamer = get_node("Core/Streamer")
onready var Debug = get_node("/root/Main/UI/Debug")
onready var UI = get_node("UI")
onready var TexAll = get_node("TexAll")
onready var Camera2D = get_node("Camera2D")
onready var Starter = get_node("UI/Starter")

var cur_dir = "" #Current directory manga is loaded from

#Options
var read_pages = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	settings_load()

func _input(event):
	#Next page
#	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
#		page_next()

	if event.is_action_pressed("ui_cancel"): #Exit
		settings_save_page()
		yield(get_tree().create_timer(.1), "timeout") 
		get_tree().quit()
	if event.is_action_pressed("ui_debug_overlay"):
		Debug.visible = !Debug.visible
	if event.is_action_pressed("ui_jump"):
		UI.Jump_toggle()
	if event.is_action_pressed("ui_fullscreen"):
		var a = OS.is_window_fullscreen()
		a = !a
		OS.set_window_fullscreen(a)

func reset():
	if TexAll.get_child_count() > 0: #If there's anything loaded prior, reset everything
		Camera2D.position.x = 0
		Camera2D.position.y = global.window_height/2
		Camera2D.camera_limit_y1 = -24
		#Save our progress
		settings_save_page()
	
#		Camera2D.set_zoom(Vector2(1,1))
		global.children_delete(TexAll)
		Streamer.reset()

func settings_reset():
	global.settings["General"] = {}
	global.settings["General"]["first_start"] = 0
	global.settings["General"]["autoload"] = 1
	global.settings["General"]["autoload_source"] = ""
	global.settings["General"]["fullscreen"] = 1
	global.settings["General"]["debug_overlay"] = 0
	global.settings["History"] = {}

func settings_load():
	var file_temp = File.new()
	
	if file_temp.file_exists(global.settings_path): #Existing setting
		global.settings = global.json_read(global.settings_path)
		
		if global.settings["General"]["debug_overlay"] == 0:
			Debug.visible = false
		else:
			Debug.visible = true
		
		if global.settings["General"]["fullscreen"] == 0:
			OS.set_window_fullscreen(false)
		else:
			OS.set_window_fullscreen(true)
		
		if global.settings["General"]["autoload"] == 1 and !global.settings["General"]["autoload_source"] == "":
			var page
			Starter.queue_free()
			SourceLoader.source_load(global.settings["General"]["autoload_source"])
		
	else: #new start
		settings_reset()
		
		settings_save()
		print("CE: settings file not found")

func settings_save():
	global.json_write(global.settings_path, global.settings)
	
func settings_save_page():
	if cur_dir != "":
		global.settings["History"][cur_dir] = Streamer.page_cur
		global.settings["General"]["autoload_source"] = cur_dir
		settings_save()
