extends TileMap

var root
var camera
var viewport_adj_x
var viewport_adj_y

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var viewport_size = get_viewport_rect().size
	viewport_adj_x = viewport_size.x / 2
	viewport_adj_y = viewport_size.y / 2
	root = get_tree().get_root().get_node("root")
	camera = root.get_node("Map/Camera")
	print(camera.is_current())
#	set_process_input(true)
	set_process(true)
	
func _process(delta):
	if (Input.is_action_pressed("ui_action")):
		var cpos = camera.get_global_pos()
		var coff = camera.get_offset()
#		var posx = ((get_global_mouse_pos().x + cpos.x) - viewport_adj_x)
#		var posy = ((get_global_mouse_pos().y + cpos.y) - viewport_adj_y)
		var posx = get_global_mouse_pos().x
		var posy = get_global_mouse_pos().y
		var cellx = int(get_global_mouse_pos().x  / get_cell_size().x)
		var celly = int(get_global_mouse_pos().y / get_cell_size().y)
		if( sign(posx) == -1):
			cellx -= 1
		if( sign(posy) == -1):
			celly -= 1
		var cell = get_cell(cellx, celly)
		if(cell == 0):
			set_cell(cellx,celly, 1)
		print(cell)
	
