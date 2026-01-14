extends Node2D

var over_any_branch: bool = false
var currently_being_selected: bool = false

var selected_input_point : bool = false

var branches_pool: Dictionary = {}
var grid_separator_distance: float = 50
# turning grid on and off
var grid_state: bool = true
var path_to_xslx: String = r"C:\Users\bkuca\Desktop\Nowy folder\91. Bestellung 45663552 - Auftrag 50000549\wetransfer_60268707_2025-09-30_1349\Produktionsstückliste_SIEB-KQ-18-60-2,5_SL6050407.xlsm"
var path_to_xlsx: String = r"C:\Users\bkuca\Desktop\Nowy folder\91. Bestellung 45663552 - Auftrag 50000549\wetransfer_60268707_2025-09-30_1349\Produktionsstückliste_SIEB-KQ-18-60-2,5_SL6050407.xlsm"

var width_of_branch: float = 50.0
var height_of_branch: float = 25.0
var connection_point_radius: float = 8.0

var active_branches: Dictionary = {}
var selected_branches: Array = []
var dragging_branch: Node2D = null
var drag_offset: Vector2 = Vector2.ZERO

# that one might connect with auto save function, as there shall be limit of amounts inside of action log
var actions_log: Dictionary = {}

# selector variants
var selector_starting_point
var selector_ending_point
var array_of_points_for_selector_shape
var selector_current_direction: int = 0
var body_polygon_selector
var polygon_existence: bool = false


var middle_mouse_button_state: bool = false
var camera_movement_drag_start: Vector2
var camera_movement_drag_stop: Vector2
var camera_start_pos: Vector2
var camera_pos_to_change_into: Vector2

var line_distance_from_object: float = 22.00

var lines_to_rewrite : Dictionary = {}

# tree branch, it will need some icon/picture space
# it will need connection point, times two
# it will need connection points, that can connect to any amounts of.. branches, from any branch
# it shall change colors, red, yellow, green
# scale of it shall be changeable
# maybe connection points will be.. always certain sizes
# preferably, stored in json file, to load as dictionary easily, to build, rebuild 
# it will need label space
# types of branches, maybe some outline around, to separate bending, laser cutting, assembly, paiting

# i guess i wanted to just make one tree branch, but got now logic for whole tree

# what else needed
# keyboard state
# mouse state
# mouse mode
# viewport layers, [ bottom layer, interface layer, top layer windows popup]

# mouse focused zone of entire screen, if window appears over layer with tree branch
# it shall not send data inside o tree branch

var camera_node: Node

var currently_selected_offsets : Dictionary = {}

var currently_created_line : Dictionary = {}


# as tree is, it shall become as scriptura talks, might be possible to make nice counters of amounts, for certain reasons
var main_line_node 
var main_branch_node
var layout_calculator: TreeLayoutCalculator = null
# https://www.asciiart.eu/text-to-ascii-art
# Calcin S
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_master_tree_dictionary()
	setup_main_nodes()
#	create_a_tree_branch("branch_1", "cutting", Vector2(0,0))
#	create_a_tree_branch("branch_2", "bending", Vector2(0,200))
#	create_a_tree_branch("branch_3", "assembly", Vector2(300,100))
	#print(" branches_pool : ",branches_pool)
	#print(" active_branches : ", active_branches)
	camera_node = $Camera2D
	#read_some_excell()
	#read_some_excell_with_colors()
# 1. Open and Parse TIFF structure
	#var img = tiff_loader_logic(tif_file)
	
	# button V
	#visualize_positioned_tree()
	# button C
	#create_connections_from_tree()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# simple counter to check each x frame what i inside of it
	# making chunks, chunks to have nodes in them to check just chunks, that we are currently near
	#

# USAGE: Add this to your _ready() function or call via keyboard shortcut
# Example in _ready():
#func _ready() -> void:
	#create_master_tree_dictionary()
	#setup_main_nodes()
	#camera_node = $Camera2D
	
	# Instead of manually creating branches, visualize from tree_dict
	# visualize_positioned_tree()
	# create_connections_from_tree()


# Add this function to your tree_branch.gd script
# Call it after the tree_dict has been positioned

func visualize_positioned_tree():
	"""Create visual branch nodes from the positioned tree_dict"""
	var tree_dict = GlobalState.load_tree_dict()
	
	if tree_dict.is_empty() or not tree_dict.has("branches"):
		print("ERROR: Tree dictionary empty or invalid")
		return
	
	#print("\n=== Starting Tree Visualization ===")
	
	# Recursive function to create all branches
	var create_branch_recursive = func(branch_dict: Dictionary, self_ref):
		# Create visual branch for this node if it has required data
		if branch_dict.has("name") and branch_dict.has("position"):
			var branch_name = branch_dict["name"]
			var position = branch_dict["position"]
			
			# Skip if name is empty
			if branch_name == null or str(branch_name) == "":
				print("WARNING: Skipping branch with empty name")
				return
			
			# Determine branch type (you can customize this logic)
			var branch_type = "assembly"  # default
			
			# Create the visual branch
			create_a_tree_branch(str(branch_name), branch_type, position)
			#print("Created branch: ", branch_name, " at ", position)
		
		# Recursively create children
		for key in branch_dict:
			# Skip metadata keys
			if key in ["entry_key", "position", "name", "key_1", "key_2", "key_3", "key_4", "key_5", "key_6", "key_7"]:
				continue
			
			# Check if it's a dictionary with branch data
			var child = branch_dict[key]
			if typeof(child) == TYPE_DICTIONARY and child.has("name"):
				self_ref.call(child, self_ref)
	
	# Start creating from root branches
	for root_key in tree_dict["branches"]:
		var root_branch = tree_dict["branches"][root_key]
		create_branch_recursive.call(root_branch, create_branch_recursive)
	
	#print("=== Tree Visualization Complete ===")
	#print("Total branches created: ", main_branch_node.get_child_count())


func create_connections_from_tree():
	"""Create connection lines between parent-child branches"""
	var tree_dict = GlobalState.load_tree_dict()
	
	if tree_dict.is_empty():
		return
	
	#print("\n=== Creating Connections ===")
	
	# Recursive function to create connections
	var connect_recursive = func(branch_dict: Dictionary, parent_name: String, self_ref):
		var current_name = branch_dict.get("name", "")
		
		# Skip if name is empty
		if current_name == null or str(current_name) == "":
			return
		
		# If this branch has a parent, create connection
		if str(parent_name) != "" and	 str(current_name) != "":
			# Set up connection data
			currently_created_line["starting_branch"] = {
				"node": parent_name,
				"side": "right"
			}
			currently_created_line["ending_branch"] = {
				"node": current_name,
				"side": "left"
			}
			
			# Create the line
			create_a_line()
			currently_created_line.clear()
			
			#print("Connected: ", parent_name, " -> ", current_name)
		
		# Process children
		for key in branch_dict:
			if key in ["entry_key", "position", "name", "key_1", "key_2", "key_3", "key_4", "key_5", "key_6", "key_7"]:
				continue
			
			var child = branch_dict[key]
			if typeof(child) == TYPE_DICTIONARY and child.has("name"):
				self_ref.call(child, str(current_name), self_ref)
	
	# Start from root branches
	for root_key in tree_dict["branches"]:
		var root_branch = tree_dict["branches"][root_key]
		connect_recursive.call(root_branch, "", connect_recursive)
	
	#print("=== Connections Complete ===")









#
#
#
	## 2. Display it
	##if img:
	##	make_texture_rect_with_image(img)
	## Initialize layout calculator
	#layout_calculator = TreeLayoutCalculator.new()
	#layout_calculator.vertical_spacing = 30.0  # Adjust to your needs
	#layout_calculator.horizontal_spacing = 200.0  # Adjust to your needs
	#layout_calculator.branch_height = GlobalState.get_branch_height()
	#
	## ... rest of your existing _ready() code
#
## Call this after you've built your tree_dict from the spreadsheet
#func layout_and_create_tree_from_dict():
	#print("\n=== Starting Tree Layout and Creation ===")
	#
	## Get the tree dictionary from GlobalState
	#var tree_dict = GlobalState.load_tree_dict()
	#
	#if tree_dict.is_empty() or not tree_dict.has("branches"):
		#print("ERROR: Tree dictionary is empty or invalid")
		#return
	#
	## Calculate layout using two-pass algorithm
	#var layout_result = layout_calculator.calculate_layout(tree_dict)
	#
	## Create visual branches at calculated positions
	#_create_branches_from_layout(tree_dict, layout_result)
	#
	## Create connections between branches
	#_create_connections_from_layout(tree_dict, layout_result)
	#
	#print("=== Tree Creation Complete ===")
#
## Create branch nodes at calculated positions
#func _create_branches_from_layout(tree_dict: Dictionary, layout_result: TreeLayoutCalculator.LayoutResult):
	#var branches = tree_dict.get("branches", {})
	#
	#for branch_key in branches:
		#if not layout_result.positions.has(branch_key):
			#print("WARNING: No position calculated for ", branch_key)
			#continue
		#
		#var branch_data = branches[branch_key]
		#var position = layout_result.positions[branch_key]
		#
		## Determine branch type from your data
		#var branch_type = _determine_branch_type(branch_data)
		#
		## Use your existing create_a_tree_branch function
		#var branch_node = create_a_tree_branch(branch_key, branch_type, position)
		#
		#print("Created branch: ", branch_key, " at ", position)
#
## Determine branch type from your Excel data
#func _determine_branch_type(branch_data: Dictionary) -> String:
	## You can customize this based on your data structure
	## For now, just return a default
	#return "assembly"
#
## Create visual connections between related branches
#func _create_connections_from_layout(tree_dict: Dictionary, layout_result: TreeLayoutCalculator.LayoutResult):
	#var branches = tree_dict.get("branches", {})
	#
	## Build parent-child relationships to draw connections
	#var connections_to_draw = []
	#
	#for branch_key in branches:
		#var branch_data = branches[branch_key]
		#
		## Check if this branch has a parent (has key_1, key_2, etc.)
		#var parent_key = _find_parent_key(branch_data)
		#
		#if parent_key and branches.has(parent_key):
			#connections_to_draw.append({
				#"from": parent_key,
				#"to": branch_key
			#})
	#
	## Draw each connection
	#for connection in connections_to_draw:
		#_create_connection_line(connection.from, connection.to)
#
## Find the parent key for a branch based on key hierarchy
#func _find_parent_key(branch_data: Dictionary) -> String:
	## Check keys in reverse order (key_6, key_5, ..., key_1)
	#for i in range(6, 0, -1):
		#var key_name = "key_%d" % i
		#if branch_data.has(key_name) and i > 1:
			#var prev_key_name = "key_%d" % (i - 1)
			#if branch_data.has(prev_key_name):
				#return branch_data[prev_key_name]
	#
	#return ""
#
## Create a connection line between two branches
#func _create_connection_line(from_key: String, to_key: String):
	#var from_branch = get_child_branch(from_key)
	#var to_branch = get_child_branch(to_key)
	#
	#if not from_branch or not to_branch:
		#print("WARNING: Cannot create connection - branch not found")
		#return
	#
	## Set up connection data for your existing line creation system
	#currently_created_line["starting_branch"] = {
		#"node": from_key,
		#"side": "right"  # Connections go left to right
	#}
	#
	#currently_created_line["ending_branch"] = {
		#"node": to_key,
		#"side": "left"
	#}
	#
	## Use your existing line creation function
	#create_a_line()

# NOTES FOR CONTINUATION:
# 
# DATA STRUCTURE NOTES:
# - tree_dict["branches"][branch_key] contains:
#   - "entry_key": row number in spreadsheet
#   - "position": Vector2 (will be updated by layout)
#   - "name": material name/description
#   - "key_1", "key_2", etc.: parent keys for hierarchy
#
# - tree_dict["info"]["amounts"] contains:
#   - "col_1", "col_2", etc.: count of nodes per depth
#   - "max": maximum depth found
#   - "max_col": which column has most nodes
#
# LAYOUT ALGORITHM SUMMARY:
# 1. Build tree structure with parent-child relationships
# 2. PASS 1 (bottom-up): Calculate space each node needs
#    - Leaf nodes: just their height
#    - Parent nodes: sum of all children + spacing
# 3. PASS 2 (top-down): Position nodes
#    - Start from roots at y=0
#    - Distribute allocated vertical space to children
#    - Each depth level gets fixed x position
#
# TO INTEGRATE:
# 1. Call layout_and_create_tree_from_dict() after sorting spreadsheet
# 2. Adjust vertical_spacing and horizontal_spacing for visual preferences
# 3. Modify _determine_branch_type() to use your actual type logic
# 4. The system preserves your existing branch/line creation functions

# COMPACT VERSION FOR STORAGE:
# Store this in notes: Two-pass tree layout implemented
# Pass1: calculate space bottom-up, Pass2: position top-down
# No overlap guaranteed, preserves hierarchy relationships
# Integrated with existing branch/line creation system

















var tif_file : String = r"C:\Users\bkuca\Desktop\Nowy folder\91. Bestellung 45663552 - Auftrag 50000549\wetransfer_60268707_2025-09-30_1349\220_SBT-SIEB-SL6050288_SL6050710_Stüli+TIF\00312745_1.tif"
func tiff_loader_logic(path: String) -> Image:
	var f = FileAccess.open(path, FileAccess.READ)
	if not f: return null
	var raw_bytes = f.get_buffer(f.get_length())
	f.close()

	# Basic Header Check (Little Endian "II")
	if raw_bytes[0] != 0x49: 
		push_error("Not a Little Endian TIFF")
		return null

	# Get the IFD Offset (Bytes 4-7)
	var ifd_offset = raw_bytes.decode_u32(4)
	var entry_count = raw_bytes.decode_u16(ifd_offset)
	
	var tags = {}
	var cursor = ifd_offset + 2
	
	# Read the tags we need
	for i in range(entry_count):
		var tag_id = raw_bytes.decode_u16(cursor)
		var type = raw_bytes.decode_u16(cursor + 2)
		var val = raw_bytes.decode_u32(cursor + 8)
		
		# If type is SHORT, handle it
		if type == 3: val = raw_bytes.decode_u16(cursor + 8)
		
		tags[tag_id] = val
		cursor += 12

	var w = tags.get(256, 0)
	var h = tags.get(257, 0)
	var offset = tags.get(273, 0)
	var comp = tags.get(259, 1)

	#print("Found TIF: ", w, "x", h, " Compression: ", comp)

	if comp == 4:
		# --- HERE IS THE MAGIC ---
		# We create an instance of your insanity class
		var decoder = CCITTG4Decoder.new()
		
		# We tell it to start reading from the data offset
		decoder.bit_pos = offset * 8 
		return decoder.decode_g4(raw_bytes, w, h)
	else:
		push_error("Not a Group 4 TIF")
		return null

func make_texture_rect_with_image(image_to_use: Image) -> void:
	var tex := ImageTexture.create_from_image(image_to_use)
	var rect := TextureRect.new()
	rect.texture = tex
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.custom_minimum_size = Vector2(800, 800)
	add_child(rect)

#
#
#
#
#func analyze_excel_colors():
	#var excel = ExcelReaderColor.ExcelFile.open(path_to_xlsx)
	#if not excel:
		#push_error("无法打开文件！| Cannot open file!")
		#return
	#
	#var workbook = excel.get_workbook(true)  # 启用样式 | Enable styles
	#var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
	#
	#if sheet_data.is_empty():
		#push_error("工作表不存在！| Sheet not found!")
		#return
	#
	#print("\n========== 🎨 COLOR ANALYSIS 颜色分析 ==========\n")
	#
	#var color_stats = {}  # 统计颜色使用 | Color usage stats
	#var colored_cells = []  # 有颜色的单元格 | Colored cells
	#
	## 遍历所有单元格 | Iterate all cells
	#for row_num in sheet_data["data"]:
		#for col_num in sheet_data["data"][row_num]:
			#var cell = sheet_data["data"][row_num][col_num]
			#
			## 跳过空单元格 | Skip empty cells
			#if cell.value == "":
				#continue
			#
			## 检查是否有非白色背景 | Check for non-white background
			#var bg = cell.style.bg_color
			#var is_white = bg.is_equal_approx(Color.WHITE)
			#
			#if not is_white:
				#colored_cells.append({
					#"row": row_num,
					#"col": col_num,
					#"value": cell.value,
					#"bg_color": bg,
					#"is_bold": cell.style.is_bold,
					#"font_size": cell.style.font_size
				#})
				#
				## 统计颜色 | Count colors
				#var color_key = "RGB(%.2f, %.2f, %.2f)" % [bg.r, bg.g, bg.b]
				#if not color_stats.has(color_key):
					#color_stats[color_key] = {"color": bg, "count": 0}
				#color_stats[color_key]["count"] += 1
	#
	## 打印统计 | Print statistics
	#print("📊 发现的颜色 | Colors Found:")
	#for color_key in color_stats:
		#var stat = color_stats[color_key]
		#print("  %s: %d cells" % [color_key, stat["count"]])
	#
	#print("\n🎨 有颜色的单元格 | Colored Cells (%d total):" % colored_cells.size())
	#for i in range(min(20, colored_cells.size())):  # 只显示前20个 | Show first 20
		#var cell_info = colored_cells[i]
		#print("  [%d,%d] = '%s'" % [cell_info["row"], cell_info["col"], cell_info["value"]])
		#print("    Color: RGB(%.2f, %.2f, %.2f)" % [
			#cell_info["bg_color"].r, 
			#cell_info["bg_color"].g, 
			#cell_info["bg_color"].b
		#])
		#if cell_info["is_bold"]:
			#print("    Bold: YES")
	#
	## 分析层级标记 | Analyze hierarchy markers
	#print("\n🌳 层级结构分析 | Hierarchy Analysis:")
	#analyze_hierarchy(sheet_data["data"])
#
#func analyze_hierarchy(data: Dictionary):
	#var hierarchy_markers = {}
	#
	#for row_num in data:
		#for col_num in data[row_num]:
			#var cell = data[row_num][col_num]
			#var value = str(cell.value).strip_edges()
			#
			## 检测层级标记 .1, ..2, ...3 等 | Detect hierarchy markers
			#if value.begins_with("."):
				#var dots = 0
				#for c in value:
					#if c == ".":
						#dots += 1
					#else:
						#break
				#
				#if dots > 0:
					#var level = dots
					#if not hierarchy_markers.has(level):
						#hierarchy_markers[level] = []
					#
					#hierarchy_markers[level].append({
						#"row": row_num,
						#"marker": value,
						#"has_color": cell.style.has_bg,
						#"is_bold": cell.style.is_bold
					#})
	#
	## 打印层级信息 | Print hierarchy info
	#var levels = hierarchy_markers.keys()
	#levels.sort()
	#
	#for level in levels:
		#var markers = hierarchy_markers[level]
		#print("  Level %d (%d dots): %d items" % [level, level, markers.size()])
		#
		## 显示前5个 | Show first 5
		#for i in range(min(5, markers.size())):
			#var m = markers[i]
			#var style_info = ""
			#if m["is_bold"]:
				#style_info += " [BOLD]"
			#if m["has_color"]:
				#style_info += " [COLORED]"
			#print("    Row %d: %s%s" % [m["row"], m["marker"], style_info])
#
## ========== 快速测试函数 | Quick Test Function ==========
## 在控制台调用 | Call from console:
## get_node("/root/YourScene").quick_color_test()
#
#func quick_color_test():
	#var excel = ExcelReaderColor.ExcelFile.open(path_to_xlsx)
	#var workbook = excel.get_workbook(true)
	#var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
	#
	## 检查第一行（标题行）| Check first row (header)
	#print("\n=== 第一行分析 | First Row Analysis ===")
	#if sheet_data["data"].has(1):
		#for col_num in sheet_data["data"][1]:
			#var cell = sheet_data["data"][1][col_num]
			#if cell.value != "":
				#var bg = cell.style.bg_color
				#print("Col %d: '%s' | BG: RGB(%.2f,%.2f,%.2f) | Bold: %s" % [
					#col_num, cell.value, bg.r, bg.g, bg.b, cell.style.is_bold
				#])
#
#







func add_a_branch_additional():
	var number_to_add = main_branch_node.get_child_count()
	var new_branch_name = "branch_" + str(number_to_add + 1)
	var node_type_string = "added by button"
	# Vector2(200,200)
	var position_to_send : Vector2 = Vector2(200,200)
	create_a_tree_branch(new_branch_name, node_type_string, position_to_send)


func setup_main_nodes():
	#var main_line_node : Node2D
	#var main_branch_node : Node2D
	# names as in tree dictionary
			#branches_pool["tree"] = {
			#"branches": {},
			#"connections": [],
			#"descriptors": {},
			#"lines": {}
		#}
	main_branch_node = Node2D.new()
	var branch_name = "branches"
	main_branch_node.name = branch_name
	add_child(main_branch_node)
	
	main_line_node = Node2D.new()
	var line_node_name = "lines"
	main_line_node.name = line_node_name
	add_child(main_line_node)
	


# just add child to a main branch
# main_branch_node
func add_child_branch(node):
	main_branch_node.add_child(node)
	add_branch_to_chunk(node)

func get_child_branch(node_name):
	var node_to_return = main_branch_node.get_node(node_name)
	return node_to_return


# lines ones
# main_line_node
func add_child_line(node):
	main_line_node.add_child(node)

func add_child_line_construct(middle_line_name, line_part):
	var middle_line = main_line_node.get_node(middle_line_name)
	middle_line.add_child(line_part)


# line singular, main one, splitter, middle one later
func get_child_line(line_name):
	var node_to_return = main_line_node.get_node(line_name)
	return node_to_return

func get_child_line_construct(line_name, line_part_name):
	var middle_line_node = get_node(line_name)
	var node_to_return = middle_line_node.get_node(line_part_name)
	return node_to_return











#
func read_some_excell():
	# need a path to a file
	var excel = ExcelReader.ExcelFile.open(path_to_xslx)
	var workbook = excel.get_workbook()
	print("Sheet: ", workbook.get_sheet_names())
	# then also need name for a page of the spreadsheet
	var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
	print(JSON.stringify(sheet_data["name"], "\t"))
	print(JSON.stringify(sheet_data["data"], "\t"))
	var sheet_data2 = workbook.get_sheet_by_name("Sheet2")
	
	print(JSON.stringify(sheet_data2["name"], "\t"))
	print(JSON.stringify(sheet_data2["data"], "\t"))
	pass # Replace with function body.


func read_some_excell_colors():
	# Change this line ↓↓↓
	var excel = ExcelReaderColor.ExcelFile.open(path_to_xslx)  # Was: ExcelReader
	var workbook = excel.get_workbook()
	print("Sheet: ", workbook.get_sheet_names())
	
	var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
	
	# NOW DATA IS DIFFERENT! Each cell is CellData object
	for row_num in sheet_data["data"]:
		for col_num in sheet_data["data"][row_num]:
			var cell = sheet_data["data"][row_num][col_num]  # CellData object
			
			# Access value
			print("Value: ", cell.value)
			
			# Access style
			if cell.style.is_bold:
				print("  → Bold!")
			if cell.style.has_bg:
				print("  → BG Color: ", cell.style.bg_color)
			print("  → Font size: ", cell.style.font_size)





func read_some_excell_with_colors():
	var excel = ExcelReaderColor.ExcelFile.open(path_to_xslx)
	var workbook = excel.get_workbook()  # No parameters!
	print("Sheet: ", workbook.get_sheet_names())
	
	var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
	print(JSON.stringify(sheet_data["name"], "\t"))
	print(JSON.stringify(sheet_data["data"], "\t"))
	
	# 打印前几行看看结构 | Print first few rows to see structure
	#for row_num in range(1, min(5, sheet_data["data"].size() + 1)):
		#print("\n=== Row %d ===" % row_num)
		#for col_num in range(1, min(10, sheet_data["data"][row_num].size() + 1)):
			#var cell = sheet_data["data"][row_num][col_num]
			#
			## cell 现在是字典 | cell is now a dictionary
			#print("  Col %d: '%s'" % [col_num, cell["value"]])
			#
			## 样式信息 | Style info
			#var style = cell["style"]
			#if style["bold"]:
				#print("    → BOLD")
			#if style["has_bg"]:
				#print("    → BG: %s" % style["bg_color"])
			#print("    → Font: size=%d, color=%s" % [style["size"], style["font_color"]])



















#
# input
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888      ┬┌┐┌┌─┐┬ ┬┌┬┐
#       888  `"Y8888o.   888ooooo888      ││││├─┘│ │ │ 
#       888      `"Y88b  888     888      ┴┘└┘┴  └─┘ ┴ 
#       888 oo     .d8P  888     888 
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# input
#


#var mouse_left_state : int = 0
#var last_mouse_delta

# Or add keyboard shortcut to test
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed:
		#match event.keycode:
			#KEY_M:
				#print_tree_pretty()
			#KEY_N:
				#counting_nodes()
			#KEY_A:
				#add_a_branch_additional()
			#KEY_V:  # V for Visualize
				#visualize_positioned_tree()
			#KEY_C:  # C for Connections
				#create_connections_from_tree()


func _input(event: InputEvent) -> void:
	
	if event is InputEventKey  and event.pressed:
		match event.keycode: 
			KEY_M:
				print_tree_pretty()
			KEY_N:
				counting_nodes()
			KEY_A:
				add_a_branch_additional()
			KEY_V:  # V for Visualize
				visualize_positioned_tree()
			KEY_C:  # C for Connections
				create_connections_from_tree()
	#print(" mouse_left_state : " , mouse_left_state)
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			#mouse_left_state = 1
		#else:
			#mouse_left_state = 0
		
	# Handle dragging
	if event is InputEventMouseMotion and dragging_branch != null:
		#print("123 event mouse , selected_branches ", selected_branches)
		
		
		# if selector branches empty/ just one selected
		if selected_branches.is_empty():
			dragging_branch.position = get_global_mouse_position() - drag_offset
			check_if_lines_shall_be_redrawn(String(dragging_branch.name),currently_selected_offsets)
			# a branch was moved, will need a check if it changed chunk position too
			print(" dragging branch : ", dragging_branch)
			move_node_in_chunks(dragging_branch)
			update_chunk_label(dragging_branch)
			
			
		else:
			
			
			
			#var current_mouse_delta = get_global_mouse_position()
			for branch_to_move in selected_branches:
				if currently_selected_offsets.has(String(branch_to_move.name)):
					branch_to_move.global_position = get_global_mouse_position() - currently_selected_offsets[String(branch_to_move.name)]
					check_if_lines_shall_be_redrawn(String(dragging_branch.name),currently_selected_offsets)
					# as it is already a for loop, here we will probably need to get a node from selected branches
					# if i remember correctly it was array of node_name, or not as few lines over we do .name, to access an object, so both have nodes
					move_node_in_chunks(branch_to_move)
					update_chunk_label(branch_to_move)
				
				
	# that one is wrong, i want selector to have a starting point, when mouse button left is clicked, not on any branch, but it seems that dragging branch is not it
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and over_any_branch == false and currently_being_selected == false:
		# that is starter for the selector
		#print("possible selector mouse position = ", get_global_mouse_position())
		selected_branches.clear()
		var selector_starting_position = get_global_mouse_position()
		create_selection_area(selector_starting_position)
		
	
	
	# released mouse left button, while being selected, shall mean stop of selection
	if event is InputEventMouseButton and not event.pressed and currently_being_selected == true:
		# last update of finished selection
		currently_being_selected = false
		var end_point_coordinates_last = get_global_mouse_position()
		update_selector_zone(end_point_coordinates_last)
		# check what nodes were selected
		# probably right now it would be... nodes next to root
		# later in dictionary, check all "branches" keys
		# dictionary needs current position
		# refreshing, updating all positions of changed keys
		# create array for storing currently selected branches for further updates
		#
		# selector_polygon
		# remove_child
		#var selector_to_remove
		#get_node("selector_polygon")
		# if selector is global variant, that is a node, it can be unloaded from here
		#print(body_polygon_selector)
		body_polygon_selector.queue_free()
		polygon_existence = false
	
	# will need another function for selector, if motion, if selector started
	# currently_being_selected
	if event is InputEventMouseMotion and currently_being_selected == true:
		#print(" selection shall still be happening mouse position = ", get_global_mouse_position())
		var end_point_coordinates = get_global_mouse_position()
		update_selector_zone(end_point_coordinates)
		detect_branches_in_selector()
	
	
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and dragging_branch != null:
			# Stop dragging
			#print(" finished dragging the branch, what was it? ", dragging_branch)
			update_branch_position(String(dragging_branch.name), dragging_branch.global_position)
			check_if_lines_need_redrawing(String(dragging_branch.name))
			check_if_lines_shall_be_redrawn(String(dragging_branch.name),currently_selected_offsets)
			dragging_branch = null
			#print(" dilema here is end i think")
			currently_selected_offsets.clear()
			
			
			#print(branches_pool)
			
		if not event.pressed and selected_input_point == false:
			#print(" input point is false ")
			currently_created_line.clear()
		elif not event.pressed and selected_input_point == true and currently_created_line.has("ending_branch"):
			#print(" connection creation can continue further ", currently_created_line)
			create_a_line()
			currently_created_line.clear()
			
			# 
	# camera movement
	# middle mouse button event
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if middle_mouse_button_state == false:
			#print(" middle mouse button for movement ")
			camera_start_pos = camera_node.position
			camera_movement_drag_start = get_viewport().get_mouse_position()
			middle_mouse_button_state = true
			#move_camera_around()
		else:
			#print(" middle mouse button released ")
			middle_mouse_button_state = false
			#camera_movement_drag_start = Vector2.ZERO
			#camera_movement_drag_stop = Vector2.ZERO
			#camera_start_pos = Vector2.ZERO
			#camera_pos_to_change_into = Vector2.ZERO
	
	
	if event is InputEventMouseMotion and middle_mouse_button_state == true:
		#print("move camera around")

		move_camera_around()
		queue_redraw()
		update_visible_chunks()
	
	
	
	# mouse wheel
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		#print("mouse wheel down")
		camera_zoom_control("down")
		queue_redraw()
		#var some_data = get_camera_view_area()
		#print(" zoom info? 1 : ", some_data)
		update_visible_chunks()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		#print("mouse wheel up")
		camera_zoom_control("up")
		queue_redraw()
		#var some_data = get_camera_view_area()
		#print(" zoom info? 1 : ", some_data)
		update_visible_chunks()


func counting_nodes():
	print(" lines amount : ", main_line_node.get_child_count())
	
#	print(" branches count : ", main_branch_node.get_child_count())


func _on_branch_input_event(viewport, event, shape_idx, branch_node):
	"""Handle clicks on branch body"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Start dragging
			dragging_branch = branch_node
			print("am i here before i try to move?")
			drag_offset = get_global_mouse_position() - branch_node.global_position
			print("Started dragging: ", branch_node.get_meta("branch_name"))
			
			
			# check if currently moved branch, is inside the selection
			check_if_selection_is_in_batch(branch_node)
			
			
			if not selected_branches.is_empty():
				print(" dilema here is start i think")
				calculate_selection_offsets()
			# here is a start, so we shall also generate offsets, for each selected if, any are selected
			
			
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Select/deselect
			toggle_branch_selection(branch_node)









func _on_branch_mouse_entered(body_polygon: Polygon2D, branch_type: String):
	"""Highlight on hover"""
	var base_color = get_color_for_type(branch_type)
	body_polygon.color = base_color.lightened(0.2)
	over_any_branch = true

func _on_branch_mouse_exited(body_polygon: Polygon2D, branch_type: String):
	"""Remove highlight"""
	body_polygon.color = get_color_for_type(branch_type)
	over_any_branch = false



func _on_connection_point_input(viewport, event, shape_idx, point_node):
	"""Handle connection point clicks"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Connection point clicked: ", point_node.name)
			var branch_node_tg = point_node.get_parent()
			print(" connection point pn ", branch_node_tg)
			# connection can start after either selecting left or right
			# if after selecting left one, we click another left one
			# they shall connect too, with posibility to connect to starting ones, of the right one
			# as clicking of connections, shall always make it possible to connect to anything
			# after selecting connection and clicking somewhere that is not an, connection point, shall cancel combo of line creation/edit
			# each branch, would need to make 2d zone, area, that makes it impossible to draw a line, over them/ under them
			# kinda how 2d map would be created and pathfinder would look for closest path
			# 
			# first it should check how many if any lines are already there, so we will know, number of the line
			# or maybe if there would be some line already, logic would differ?
			# if there is line aready, we could add more to the line, another point to the whole
			# or delete conection of this branch, to line structure
			# as we click on point it shall store things, 
			# name of branch
			# which side it is per branch, array could work but would be dumdum
			# dictionary is the way i guess
			
			var node_name_now = String(branch_node_tg.name)
			var connection_name_now = String(point_node.name)
			
			
			# here shall be probably check if that line already has some connection
			# or maybe after connection from here, to somewhere happens
			# we check if the line has these connections
			# if not we add to the line
			
			if currently_created_line.is_empty():
				currently_created_line["starting_branch"] = {
				"node" : node_name_now,
				"side": connection_name_now
				}
			else:
				if currently_created_line["starting_branch"]["node"] != String(branch_node_tg.name):
					currently_created_line["ending_branch"] = {
					"node" : node_name_now,
					"side": connection_name_now
					}
				else:
					currently_created_line.clear()
					# here an function to create an line could happen
					# lets first also add clearing that array, if it is selected, not empty, and empty space is clicked
					
			print(" currently_created_line ", currently_created_line)
			# hmm, as it is every time any connection point being clicked
			# it wont work this way
			# 
			

func _on_connection_point_hover(point_polygon: Polygon2D, is_hovering: bool):
	"""Highlight connection point on hover"""
	if is_hovering:
		point_polygon.color = Color(0.5, 1.0, 0.6, 0.9)
		selected_input_point = true
	else:
		point_polygon.color = Color(0.3, 0.8, 0.4, 0.6)
		selected_input_point = false

func toggle_branch_selection(branch_node: Node2D):
	"""Toggle branch selection state"""
	if branch_node in selected_branches:
		selected_branches.erase(branch_node)
		print("Deselected: ", branch_node.get_meta("branch_name"))
	else:
		selected_branches.append(branch_node)
		print("Selected: ", branch_node.get_meta("branch_name"))

# === PLACEHOLDER FUNCTIONS FROM ORIGINAL ===

#func read_some_excell():
	#var excel = ExcelReader.ExcelFile.open(path_to_xslx)
	#var workbook = excel.get_workbook()
	#var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
	#print(JSON.stringify(sheet_data["data"], "\t"))










#
# batch selection
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888      ┌┐ ┌─┐┌┬┐┌─┐┬ ┬  ┌─┐┌─┐┬  ┌─┐┌─┐┌┬┐┬┌─┐┌┐┌
#       888  `"Y8888o.   888ooooo888      ├┴┐├─┤ │ │  ├─┤  └─┐├┤ │  ├┤ │   │ ││ ││││
#       888      `"Y88b  888     888      └─┘┴ ┴ ┴ └─┘┴ ┴  └─┘└─┘┴─┘└─┘└─┘ ┴ ┴└─┘┘└┘
#       888 oo     .d8P  888     888 
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# batch selection
#


func calculate_selection_offsets():
	var mouse_cur_pos_for_dictionary = get_global_mouse_position()
	for branch_to_move in selected_branches:
		currently_selected_offsets[String(branch_to_move.name)] = mouse_cur_pos_for_dictionary - branch_to_move.global_position



func check_if_selection_is_in_batch(node_to_check):
	#var name_of_node = string(branch_node.name)
	var not_found: int = 0
	for branch_to_move in selected_branches:
		if branch_to_move == node_to_check:
			print("dilema we found the same")
			not_found = 1
	if not_found == 0:
		print(" dilema, it shall clear the slected_branches now")
		selected_branches.clear()
	

func calculate_and_apply_movement(dragging_node: Node2D):
	
	print(" move me ", dragging_node)





func create_selection_area(starting_position):
	selector_starting_point = starting_position
	currently_being_selected = true
	# several informations needed
	# first starting point
	# then ending point
	# each time mouse changes location it will need to recreate the selection area
	pass



func update_selector_zone(end_point_selector):
	selector_ending_point = end_point_selector
	
	
	print(" start = ", selector_starting_point, " end = ", selector_ending_point)
	var x_state: int = 0
	var y_state: int = 0
	#var distance_x: float = selector_starting_point.x - selector_ending_point.x
	#var distance_y: float = selector_starting_point.y - selector_ending_point.y
	#print(" x = ",distance_x," y = ", distance_y)

	#var matrice_for_check: Vector2
	#matrice_for_check = Vector2(distance_x, distance_y)
	# now lets check in which direction, the area is being selected
	# each direction check
	if selector_starting_point.x < selector_ending_point.x:
		print(" some x is higher ")
		x_state = 1
	else:
		print(" some x is lower ")
		x_state = -1
	
	if selector_starting_point.y > selector_ending_point.y:
		print(" some z is higher ")
		y_state = 1
	else:
		print(" some z is lower ")
		y_state = -1
	pass
	
	# both direction check for whole selector creation
	if x_state == 1 and y_state == 1:
		selector_current_direction = 1
	elif x_state == 1 and y_state == -1:
		selector_current_direction = 2
	elif x_state == -1 and y_state == -1:
		selector_current_direction = 3
	elif x_state == -1 and y_state == 1:
		selector_current_direction = 4
	
	# E-------A--------E         |y+
	# |  4    |   1    |   x-    |    x+
	# D-------S--------B   ------|------
	# |   3   |   2    |         |
	# E-------C--------E         |y-
	# now we need to generate 2 more points, based on directon
	
	
	# vertical ones
	var selector_point_a = Vector2(selector_starting_point.x, selector_ending_point.y)
	var selector_point_c = Vector2(selector_starting_point.x, selector_ending_point.y)
	# horizontal ones
	var selector_point_b = Vector2(selector_ending_point.x, selector_starting_point.y)
	var selector_point_d = Vector2(selector_ending_point.x, selector_starting_point.y)
	if selector_current_direction == 1:
		# point 1 = A - selector_point_a
		# point 2 = E - selector_ending_point
		# point 3 = B - selector_point_b
		# point 4 = S - selector_starting_point
		array_of_points_for_selector_shape = PackedVector2Array([
			selector_point_a,  # Top-left
			selector_ending_point,   # Top-right
			selector_point_b,    # Bottom-right
			selector_starting_point    # Bottom-left
		])
		pass
	elif selector_current_direction == 2:
		# point 1 = S
		# point 2 = B
		# point 3 = E
		# point 4 = C
		array_of_points_for_selector_shape = PackedVector2Array([
			selector_starting_point,  # Top-left
			selector_point_b,   # Top-right
			selector_ending_point,    # Bottom-right
			selector_point_c    # Bottom-left
		])
		pass
	elif selector_current_direction == 3:
		# point 1 = D
		# point 2 = S
		# point 3 = C
		# point 4 = E
		array_of_points_for_selector_shape = PackedVector2Array([
			selector_point_d,  # Top-left
			selector_starting_point,   # Top-right
			selector_point_c,    # Bottom-right
			selector_ending_point    # Bottom-left
		])
		pass
	elif selector_current_direction == 4:
		# point 1 = E
		# point 2 = A
		# point 3 = S
		# point 4 = D
		array_of_points_for_selector_shape = PackedVector2Array([
			selector_ending_point,  # Top-left
			selector_point_a,   # Top-right
			selector_starting_point,    # Bottom-right
			selector_point_d    # Bottom-left
		])
		pass
	
	
	
	# shish its not enough, it is creating that polygon somehow each time, wait i didnt true it
	if polygon_existence == false:
		body_polygon_selector = Polygon2D.new()
		body_polygon_selector.name = "selector_polygon"
		var points = array_of_points_for_selector_shape
		body_polygon_selector.polygon = points
		body_polygon_selector.color = Color(0.5, 0.8, 0.9, 0.22)
		add_child(body_polygon_selector)
		polygon_existence = true
	else:
		#polygon_existence = false
		body_polygon_selector.polygon = array_of_points_for_selector_shape




# Detect branches inside selector polygon
func detect_branches_in_selector():
	"""Check which branches are inside the selector area"""
	print("new function")
	if array_of_points_for_selector_shape == null or array_of_points_for_selector_shape.size() < 3:
		print("some return in detect	")
		return
	
	# Clear previous selection
	selected_branches.clear()
	
	# Get selector bounds
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for point in array_of_points_for_selector_shape:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	# Check each branch
	for branch_name in active_branches.keys():
		var branch = active_branches[branch_name]
		
		# Get branch's 4 corner points in global space
		var corners = get_branch_corners_global(branch)
		
		# Check if ANY corner is inside selector (partial selection)
		# Or if you want full selection only, check if ALL corners inside
		var selected = false
		
		# OPTION A: Select if ANY corner inside (easier to select, feels more responsive)
		for corner in corners:
			if is_point_in_rect(corner, min_x, max_x, min_y, max_y):
				selected = true
				break
		
		# OPTION B: Select only if ALL corners inside (stricter, full overlap only)
		# Uncomment this and comment Option A if you prefer strict selection
		#var all_inside = true
		#for corner in corners:
		#	if not is_point_in_rect(corner, min_x, max_x, min_y, max_y):
		#		all_inside = false
		#		break
		#selected = all_inside
		
		if selected:
			selected_branches.append(branch)
			print("Selected: ", branch_name)
			highlight_selected_branch(branch, true)

func get_branch_corners_global(branch_node: Node2D) -> Array:
	"""Get all 4 corner points of a branch in global coordinates"""
	var corners = []
	
	# Branch center in global space
	var center = branch_node.global_position
	
	# Branch corners relative to center (from polygon points)
	# Your polygon is: (-width, -height), (width, -height), (width, height), (-width, height)
	var local_corners = [
		Vector2(-width_of_branch, -height_of_branch),  # Top-left
		Vector2(width_of_branch, -height_of_branch),   # Top-right
		Vector2(width_of_branch, height_of_branch),    # Bottom-right
		Vector2(-width_of_branch, height_of_branch)    # Bottom-left
	]
	
	# Convert to global space
	for local_corner in local_corners:
		corners.append(center + local_corner)
	
	return corners

func is_point_in_rect(point: Vector2, min_x: float, max_x: float, min_y: float, max_y: float) -> bool:
	"""Check if a point is inside a rectangle defined by min/max bounds"""
	return point.x >= min_x and point.x <= max_x and point.y >= min_y and point.y <= max_y


# Visual feedback for selected branches
func highlight_selected_branch(branch_node: Node2D, is_selected: bool):
	"""Add visual indicator to selected branches"""
	var body_polygon = branch_node.get_node("BodyPolygon")
	if body_polygon:
		if is_selected:
			# Add outline or change modulation
			body_polygon.modulate = Color(1.2, 1.2, 1.2)  # Brighter
		else:
			body_polygon.modulate = Color.WHITE  # Normal

func batch_branches_selection():
	# select several branches at once, with some... selector i guess, like windows thingy, that is square/rectangle, with a little bit of color
	# it shall select, branches, connection points, line descriptors
	# it will need two coordinates information, starting point of mouse selection
	# ending point is current mouse orientation, and directions will be needed too
	# x----------------x         |y+
	# |  4    |   1    |   x-    |    x+
	# --------x---------   ------|------
	# |   3   |   2    |         |
	# x----------------x         |y-
	# if start point is x -/+ and y is +/- in direction of end point
	# as these will create, and change polygon parameters, and its area
	pass






#
# batch selection
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888      ┌─┐┬─┐┬┌┬┐
#       888  `"Y8888o.   888ooooo888      │ ┬├┬┘│ ││
#       888      `"Y88b  888     888      └─┘┴└─┴─┴┘
#       888 oo     .d8P  888     888 
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# batch selection
#	

# creation of the grid
# singular points with x amount of distances between them on x and y
# lines on these points,
# grid shall be created infinitely
# it shall be based on current camera viewport size, orientation, zoom







# grid_separator_distance
func generate_grid():
	print("starting grid generation")


# Grid drawing - uses _draw() which is coordinate-based but we calculate visible area
# The grid extends infinitely based on camera viewport
var grid_lines_color: Color = Color(0.3, 0.3, 0.3, 0.3)
var grid_lines_major_color: Color = Color(0.4, 0.4, 0.4, 0.5)
var grid_major_interval: int = 5  # Every 5th line is darker
var max_grid_lines: int = 200  # Safety limit per axis
var min_grid_spacing_pixels: float = 10.0  # Minimum spacing in screen pixels before scaling
var debug_camera_corners: bool = true  # Show camera corner points for debugging

func _draw():
	if not grid_state:
		return
	
	# Get camera viewport bounds in world space
	var camera_pos = camera_node.position
	var viewport_size = get_viewport().size
	var zoom = camera_node.zoom
	
	# Calculate visible world area (accounting for zoom)
	var half_width = (viewport_size.x / zoom.x) / 2
	var half_height = (viewport_size.y / zoom.y) / 2
	
	# CAMERA 4 CORNER POINTS IN WORLD SPACE
	var corner_top_left = camera_pos + Vector2(-half_width, -half_height)
	var corner_top_right = camera_pos + Vector2(half_width, -half_height)
	var corner_bottom_left = camera_pos + Vector2(-half_width, half_height)
	var corner_bottom_right = camera_pos + Vector2(half_width, half_height)
	
	# DEBUG: Draw camera corners as visible circles
	if debug_camera_corners:
		var corner_radius = 20.0 / zoom.x  # Scale with zoom so they stay visible
		draw_circle(corner_top_left, corner_radius, Color.RED)
		draw_circle(corner_top_right, corner_radius, Color.GREEN)
		draw_circle(corner_bottom_left, corner_radius, Color.BLUE)
		draw_circle(corner_bottom_right, corner_radius, Color.YELLOW)
		
		# Draw rectangle connecting the corners
		draw_line(corner_top_left, corner_top_right, Color.CYAN, 2.0 / zoom.x)
		draw_line(corner_top_right, corner_bottom_right, Color.CYAN, 2.0 / zoom.x)
		draw_line(corner_bottom_right, corner_bottom_left, Color.CYAN, 2.0 / zoom.x)
		draw_line(corner_bottom_left, corner_top_left, Color.CYAN, 2.0 / zoom.x)
		
		# Draw center point
		draw_circle(camera_pos, corner_radius * 0.5, Color.MAGENTA)
		
		print("=== CAMERA DEBUG ===")
		print("Camera position: ", camera_pos)
		print("Viewport size: ", viewport_size)
		print("Zoom: ", zoom)
		print("Half width/height: ", half_width, " / ", half_height)
		print("Top-Left (RED): ", corner_top_left)
		print("Top-Right (GREEN): ", corner_top_right)
		print("Bottom-Left (BLUE): ", corner_bottom_left)
		print("Bottom-Right (YELLOW): ", corner_bottom_right)
		print("===================")
	
	var visible_min = corner_top_left
	var visible_max = corner_bottom_right
	
	# Calculate how far apart grid lines appear on screen (in pixels)
	var grid_spacing_on_screen = grid_separator_distance * zoom.x
	
	# If grid is too dense, scale it up dynamically
	var effective_grid_distance = grid_separator_distance
	var scale_factor = 1
	
	# When zoomed out far, make grid coarser
	while grid_spacing_on_screen < min_grid_spacing_pixels:
		scale_factor *= grid_major_interval  # Jump by major intervals
		effective_grid_distance = grid_separator_distance * scale_factor
		grid_spacing_on_screen = effective_grid_distance * zoom.x
	
	# Snap to grid intervals
	var start_x = floor(visible_min.x / effective_grid_distance) * effective_grid_distance
	var end_x = ceil(visible_max.x / effective_grid_distance) * effective_grid_distance
	var start_y = floor(visible_min.y / effective_grid_distance) * effective_grid_distance
	var end_y = ceil(visible_max.y / effective_grid_distance) * effective_grid_distance
	
	# Count potential lines to prevent performance issues
	var x_line_count = int((end_x - start_x) / effective_grid_distance) + 1
	var y_line_count = int((end_y - start_y) / effective_grid_distance) + 1
	
	# Safety check - if too many lines, bail out
	if x_line_count > max_grid_lines or y_line_count > max_grid_lines:
		print("Grid too dense - skipping draw. Zoom: ", zoom, " Lines: ", x_line_count, "x", y_line_count)
		return
	
	# Draw vertical lines
	var x = start_x
	var line_counter = 0
	while x <= end_x:
		var grid_index = int(x / grid_separator_distance)
		var color = grid_lines_major_color if grid_index % grid_major_interval == 0 else grid_lines_color
		
		# Make lines thicker when they represent scaled grid
		var line_width = 1.0 if scale_factor == 1 else 2.0
		
		draw_line(Vector2(x, visible_min.y), Vector2(x, visible_max.y), color, line_width)
		x += effective_grid_distance
		line_counter += 1
	
	# Draw horizontal lines
	var y = start_y
	line_counter = 0
	while y <= end_y:
		var grid_index = int(y / grid_separator_distance)
		var color = grid_lines_major_color if grid_index % grid_major_interval == 0 else grid_lines_color
		
		var line_width = 1.0 if scale_factor == 1 else 2.0
		
		draw_line(Vector2(visible_min.x, y), Vector2(visible_max.x, y), color, line_width)
		y += effective_grid_distance
		line_counter += 1
	
	# Debug info
	if scale_factor > 1:
		print("Grid scaled by ", scale_factor, "x - Drawing every ", effective_grid_distance, " units")





#
# JSH Camera Movemet
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888      ╔═╗┌─┐┌┬┐┌─┐┬─┐┌─┐  ┌┬┐┌─┐┬  ┬┌─┐┌┬┐┌─┐┌┐┌┌┬┐
#       888  `"Y8888o.   888ooooo888      ║  ├─┤│││├┤ ├┬┘├─┤  ││││ │└┐┌┘├┤ │││├┤ │││ │ 
#       888      `"Y88b  888     888      ╚═╝┴ ┴┴ ┴└─┘┴└─┴ ┴  ┴ ┴└─┘ └┘ └─┘┴ ┴└─┘┘└┘ ┴  
#       888 oo     .d8P  888     888 
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Camera Movement
#


# var camera_movement_drag_start: Vector2
# var camera_movement_drag_stop: Vector2
# var camera_start_pos: Vector2
# var camera_pos_to_change_into: Vector2

# camera functions, movement, zooming
func move_camera_around():
	
	# button pressed first time
	# camera_start_pos, camera_movement_drag_start
	# mouse movement detected, comes straight to that function, which should only check new mouse position
	# than based on that calculate how much it shall, change position of the camera
	
	camera_movement_drag_stop = get_viewport().get_mouse_position()
	# conductor we got a problem, possible mouse position is not its position on scene but on viewport
	var amount_to_add = camera_movement_drag_stop - camera_movement_drag_start
	#camera_pos_to_change_into = camera_start_pos + amount_to_add
	camera_node.position = camera_start_pos - (amount_to_add / camera_node.zoom)
	
	print(" current mouse position: ", camera_movement_drag_stop)
	print(" amount to add to camera position: ", amount_to_add)
	print(" start of camera movement ")
	print(" starting camera position: ", camera_start_pos)
	print(" starting mouse position: ", camera_movement_drag_start)
	#camera_movement_drag_start = camera_movement_drag_stop
	#print(" changed camera start into current : ", camera_movement_drag_start)
	#camera_movement_drag_start# = camera_movement_drag_stop
	# update starting position, based on current one, for the next frame
	# camera_start_pos = camera_node.position
	# camera_movement_drag_start = get_global_mouse_position()
	
	




func camera_zoom_control(info):
	
	# movement of the camera
	# how do set it up
	# viewport?
	# top left corner is 0,0
	# camera position is anywhere on the whole screen
	# direction of the camera?
	# direction of the mouse, where to zoom too, shall be based on viewport, central point, and distance of viewport_size.x / 2 
	# or longer distance/2
	var mouse_current_position = get_viewport().get_mouse_position()
	var viewport_resolution = get_viewport().size
	print(" mouse pos : ", mouse_current_position, " viewport resolution : ", viewport_resolution)
	var max_distance: float = 0.0
	#mouse pos : (847.0, 404.0) viewport resolution : (1211, 691)
	if viewport_resolution.x > viewport_resolution.y:
		print(" we are choosing x ")
		max_distance = viewport_resolution.x / 2
	else:
		print(" we are chosing y")
		max_distance = viewport_resolution.y / 2
	var center_point_of_screen = Vector2(viewport_resolution.x / 2, viewport_resolution.y / 2)
	var centered_viewport = mouse_current_position - center_point_of_screen
	print(" centered_viewport : ", centered_viewport)
	
	
	var factor = 0.5
	if info == "up":
		camera_node.zoom *= 1.1
		camera_node.position = camera_node.position + (centered_viewport / camera_node.zoom) / 9
	elif info == "down":
		camera_node.zoom *= 0.9
		camera_node.position = camera_node.position - (centered_viewport / camera_node.zoom) / 9
	print("changing camera zoom")
	
















#
# tree dictionary
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888      ┌┬┐┬┌─┐┌┬┐┬┌─┐┌┐┌┌─┐┬─┐┬ ┬  ┌┬┐┬─┐┌─┐┌─┐
#       888  `"Y8888o.   888ooooo888       ││││   │ ││ ││││├─┤├┬┘└┬┘   │ ├┬┘├┤ ├┤ 
#       888      `"Y88b  888     888      ─┴┘┴└─┘ ┴ ┴└─┘┘└┘┴ ┴┴└─ ┴    ┴ ┴└─└─┘└─┘
#       888 oo     .d8P  888     888 
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# dictionary tree
#




#func create_master_tree_dictionary_bp():
	## main starter point for whole tree
	## main xlsx file path
	## branches etc
	#if branches_pool.is_empty():
		## main path for order
		#branches_pool["order_path"]
		## path for main folders, as some orders have different structures
		#branches_pool["main_folders"]
		## could have more than one product list
		#branches_pool["xlsx_paths"]
		## folders for dwg and tif files
		#branches_pool["dwg_files_folders"]
		#branches_pool["tif_files_folders"]
		## whole tree, which has few different kind of possible branches in it
		#branches_pool["tree"]
		## brances connections, descriptors
		#branches_pool["tree"]["branches"]
		#branches_pool["tree"]["connections"]
		#branches_pool["tree"]["descriptors"]
	#pass







func create_master_tree_dictionary():
	if branches_pool.is_empty():
		branches_pool["order_path"] = ""
		branches_pool["main_folders"] = []
		branches_pool["xlsx_paths"] = []
		branches_pool["dwg_files_folders"] = []
		branches_pool["tif_files_folders"] = []
		branches_pool["tree"] = {
			"branches": {},
			"connections": [],
			"descriptors": {},
			"lines": {}
		}
		var empty_int : int = 0
		branches_pool["tree"]["lines"]["current_number"] = empty_int#.duplicate(true)
# add branch to branches of master tree dictionary
func add_tree_branch_to_dictionary(branch_name):
	
	branches_pool["tree"]["branches"][branch_name] = {
		"part_name" : "",
		"part_type": "",
		"dwg_file_link": "",
		"position": Vector2(0.0, 0.0),
		"left_connection": "",
		"right_connection": ""
	}
	pass




func add_line_to_dictionary(line_name):
	branches_pool["tree"]["lines"][line_name] = {
		"left_connections": [],
		"right_connections": [],
		"points_of_connections": {},
		"construct_info": {}
	}


# as an dictionary, it can hold name of point, position, direction
# branches_pool["tree"]["lines"][line_name]["points_of_connections"][name_of_branch] whateva i wanna


func update_branch_position(branch_name, new_pos):
	branches_pool["tree"]["branches"][branch_name]["position"] = new_pos 

func add_line_to_branch_connection(branch_name, connection_side, line_name):
	branches_pool["tree"]["branches"][branch_name][connection_side] = line_name

func check_if_lines_need_redrawing(branch_name):
	# first the branch, if have any line, shall have it inside left/right key
	# if it does, we would have the name of specific line
	# with that we can redraw entire line, with just its name
	
	
	pass


func add_connection_to_line():
	pass

func create_new_line():
	pass
	
func remove_connection_from_line():
	pass







func create_dictionary_for_a_branch():
	# branch dictionary key
	# name, path, type, 
	# position, connections_a, connections_b
	# state, dates, like created, edited, maybe even log
	pass




func move_batch():
	# move whole batch around, as it is selected, it can be moved, maybe even edited in batch, change its states maybe
	# reparent all branches onto one new parent node, either moving node will always be there, or added/deleted each time
	# as needed
	pass

# adding new branch
func add_new_branch():
	# adding one new branch at a time, already there, in different function with input of part name and part type
	pass

# emptying key of dictionary, clearing scene
func remove_branch():
	# remove an branch
	# remove it visually from scene tree
	# remove it from inside scene tree dictionary
	pass

# as it is mostly json/dictionary at play
# the edit shall display its all keys? inside it
# and just be able to edit it in certain ways
# plain text, sliders, toogles etc
func edit_branch():
	pass

# that shall an window, which will describe something, that could be like a step, inside a tree
# it shall connect into connection point, centers

#   text
#    |
# a --- b
#
func center_line_descriptor():
	# a way to add information, onto the scene tree, either on line, or onto some branch
	pass

func reformat_sort_entire_tree():
	# as new elements can be added onto the tree
	# for example
	# element 1, element 2
	# middle part where just something was added, like an descriptor
	# element 3, element 4
	# the elements 3 and 4, might need to be moved down
	# and so all elements next to them, under them, to make space for new element
	pass

# keyboard keys
# ctrl + a, select all
# hold shift, while some nodes are already selected,add additional nodes to selection
# hold ctrl, while some nodes are already selected, deselect these nodes from batch
# both for shift and ctrl, the clicking and holding to select more
# ctrl + c , copy branch / selection of branches, it would need to make all of the nodes, it selected, all names to change, 
# probably first check if name+"_0" exists, if so, we look for all name+"_", then separate "_", check all numbers there were for that one branch
# add all these nodes into waiting zone, as we shall await for user to use
# ctrl + v, paste whatever was copied
# ctrl + z, reverse last action
# action log of entire tree will be needed
# ctrl + r, redo, previously undone action
# esc, closing windows, if there was one on top somewhere, like edit window
# popup with confirmation, if you want to close that window
# closing selection of branches
# del fo deleting whatever is selected
# right mouse button, for.. menu per selection, either group, then it can be limited to copy, move
# ctrl + m - move it around, whatever is selected
# ctrl + q - create zone

# background zones
# selecting specific space in etire tree, shall make posibility to create an zone
# which shall have some color in the background, and label on top of it
# while stuff in tree, could change position, more can be added and deleted
# background zone shall also be more fluid, and after something changes, it shall check if 
# that specific changed branch, line, description






#
# elements creation
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888      ╔═╗┬  ┌─┐┌┬┐┌─┐┌┐┌┌┬┐┌─┐  ┌─┐┬─┐┌─┐┌─┐┌┬┐┬┌─┐┌┐┌
#       888  `"Y8888o.   888ooooo888      ║╣ │  ├┤ │││├┤ │││ │ └─┐  │  ├┬┘├┤ ├─┤ │ ││ ││││
#       888      `"Y88b  888     888      ╚═╝┴─┘└─┘┴ ┴└─┘┘└┘ ┴ └─┘  └─┘┴└─└─┘┴ ┴ ┴ ┴└─┘┘└┘
#       888 oo     .d8P  888     888 
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# elements creation
#


func create_a_tree_branch(name_of_branch: String, type_of_branch: String, position_for_branch: Vector2):
	# create body of branch
	# grey rectangle
	
	
	var branch_root = Node2D.new()
	branch_root.name = name_of_branch
	branch_root.position = position_for_branch
	add_child_branch(branch_root)
	

	# === MAIN BODY POLYGON ===
	var body_polygon = Polygon2D.new()
	body_polygon.name = "BodyPolygon"
	var points = PackedVector2Array([
		Vector2(-width_of_branch, -height_of_branch),  # Top-left
		Vector2(width_of_branch, -height_of_branch),   # Top-right
		Vector2(width_of_branch, height_of_branch),    # Bottom-right
		Vector2(-width_of_branch, height_of_branch)    # Bottom-left
	])
	body_polygon.polygon = points
	body_polygon.color = get_color_for_type(type_of_branch)
	branch_root.add_child(body_polygon)
	
	#var collision_shape = CollisionShape2D.new()
	#collision_shape.set_shape(body_polygon)
	
	
	# === AREA2D FOR INTERACTION ===
	var body_area = Area2D.new()
	body_area.name = "BodyArea"
	branch_root.add_child(body_area)
	
	# Collision shape matching the body polygon
	var body_collision = CollisionPolygon2D.new()
	body_collision.polygon = points
	body_area.add_child(body_collision)
	
	# Connect signals for interaction
	body_area.input_event.connect(_on_branch_input_event.bind(branch_root))
	body_area.mouse_entered.connect(_on_branch_mouse_entered.bind(body_polygon, type_of_branch))
	body_area.mouse_exited.connect(_on_branch_mouse_exited.bind(body_polygon, type_of_branch))
	
	# === LEFT CONNECTION POINT ===
	var left_connection = create_connection_point("left", 
		Vector2(-width_of_branch, 0))
	branch_root.add_child(left_connection)
	
	# === RIGHT CONNECTION POINT ===
	var right_connection = create_connection_point("right", 
		Vector2(width_of_branch, 0))
	branch_root.add_child(right_connection)
	
	
	# === LABELS ===
	
	
	
	var position_chunk = branch_root.get_meta("current_chunk")
	
	var state_debug_label = Label.new()
	state_debug_label.text = str(position_chunk)
	# state_debug_label.position # it is at 0 x 0 for now
	state_debug_label.add_theme_font_size_override("font_size", 12)
	state_debug_label.name = "state"
	branch_root.add_child(state_debug_label)
	
	
	
	
	
	var name_label = Label.new()
	name_label.text = name_of_branch
	name_label.position = Vector2(-width_of_branch, -height_of_branch - 20)
	name_label.add_theme_font_size_override("font_size", 12)
	branch_root.add_child(name_label)
	
	var type_label = Label.new()
	type_label.text = type_of_branch
	type_label.position = Vector2(-width_of_branch, height_of_branch + 5)
	type_label.add_theme_font_size_override("font_size", 10)
	type_label.modulate = Color(0.7, 0.7, 0.7)
	branch_root.add_child(type_label)
	
	# Store in active branches
	active_branches[name_of_branch] = branch_root
	
	# Store metadata
	branch_root.set_meta("branch_name", name_of_branch)
	branch_root.set_meta("branch_type", type_of_branch)
	branch_root.set_meta("connections_left", [])
	branch_root.set_meta("connections_right", [])
	
	
	add_tree_branch_to_dictionary(name_of_branch)
	
	return branch_root


# ALTERNATIVE: Store corners in branch metadata for faster access
#func create_a_tree_branch_with_corners(name_of_branch: String, type_of_branch: String):
	## ... your existing code ...
	#var branch_root
	## Store corner offsets in metadata for later use
	#branch_root.set_meta("corner_offsets", [
		#Vector2(-width_of_branch, -height_of_branch),
		#Vector2(width_of_branch, -height_of_branch),
		#Vector2(width_of_branch, height_of_branch),
		#Vector2(-width_of_branch, height_of_branch)
	#])
	#
	#return branch_root
#
## Then detection becomes:
#func detect_branches_in_selector_v2():
	#"""Using stored corner metadata"""
	#if array_of_points_for_selector_shape == null or array_of_points_for_selector_shape.size() < 3:
		#return
	#
	## Clear previous highlights
	#for branch in selected_branches:
		#highlight_selected_branch(branch, false)
	#selected_branches.clear()
	#
	## Selector bounds
	#var min_x = INF
	#var max_x = -INF
	#var min_y = INF
	#var max_y = -INF
	#
	#for point in array_of_points_for_selector_shape:
		#min_x = min(min_x, point.x)
		#max_x = max(max_x, point.x)
		#min_y = min(min_y, point.y)
		#max_y = max(max_y, point.y)
	#
	## Check branches
	#for branch_name in active_branches.keys():
		#var branch = active_branches[branch_name]
		#var center = branch.global_position
		#var corner_offsets = branch.get_meta("corner_offsets")
		#
		#var selected = false
		#for offset in corner_offsets:
			#var global_corner = center + offset
			#if is_point_in_rect(global_corner, min_x, max_x, min_y, max_y):
				#selected = true
				#break
		#
		#if selected:
			#selected_branches.append(branch)
			#print("Selected: ", branch_name)
			#highlight_selected_branch(branch, true)


# Node2D/Polygon2D/Area2D/CollisionShape

func create_connection_point(point_name: String, local_pos: Vector2) -> Node2D:
	"""Creates a connection point with polygon visual and Area2D"""
	var point_root = Node2D.new()
	point_root.name = point_name
	point_root.position = local_pos
	
	# Visual indicator polygon (circle)
	var point_polygon = Polygon2D.new()
	point_polygon.name = "Visual"
	point_polygon.polygon = create_circle_points(connection_point_radius, 8)
	point_polygon.color = Color(0.3, 0.8, 0.4, 0.6)
	point_root.add_child(point_polygon)
	
	# Area2D for connection detection
	var point_area = Area2D.new()
	point_area.name = "ConnectionArea"
	point_polygon.add_child(point_area)
	
	var point_collision = CollisionPolygon2D.new()
	point_collision.polygon = point_polygon.polygon
	point_area.add_child(point_collision)
	
	# Signals for connection snapping
	point_area.input_event.connect(_on_connection_point_input.bind(point_root))
	point_area.mouse_entered.connect(_on_connection_point_hover.bind(point_polygon, true))
	point_area.mouse_exited.connect(_on_connection_point_hover.bind(point_polygon, false))
	
	return point_root

func create_circle_points(radius: float, segments: int) -> PackedVector2Array:
	"""Generate circle polygon points"""
	var points = PackedVector2Array()
	for i in range(segments):
		var angle = (i * TAU) / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

func get_color_for_type(branch_type: String) -> Color:
	"""Return color based on branch type"""
	match branch_type:
		"bending": return Color(0.8, 0.6, 0.3)  # Orange-ish
		"laser_cutting": return Color(0.3, 0.5, 0.9)  # Blue
		"assembly": return Color(0.5, 0.8, 0.4)  # Green
		"painting": return Color(0.9, 0.4, 0.5)  # Pink-red
		_: return Color.SKY_BLUE

# === INTERACTION CALLBACKS ===





# movement of branches
# it can move around, but if they do, and if they do have connections
# the connections shall update too
# branch has two points of connection, if branch moves, connection points for lines changes too
# the drawing of branches happen with polygon node, so does for connection point
# line shall happen similarly
# when lines shall update
# A as the branch/branches are moving around
# B after finished movement of theirs














# movement of all nodes can happen either
# by reparenting them, into singular node
# with for loop, of moving each one once, by dragging distance
# as it will happen the same way, as moving one
# as code is there to move one,
# it can check again to see, if some selector array of several nodes, is tere in place

# logic for selected batch of branches
# reparent all selected nodes into one singular node, move them all, based on their new parent location
# after finish, for example if esc clicked, new selection happened(on either nothing, or some other branch/branches), deselect them all


# drawing lines
# it can be an array of all the lines, needed creation
# all lines will need its two points of connection
# if a batch moves, lines will need movement too
#
# lines creation
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888      ┬  ┬┌┐┌┌─┐┌─┐  ┌─┐┬─┐┌─┐┌─┐┌┬┐┬┌─┐┌┐┌
#       888  `"Y8888o.   888ooooo888      │  ││││├┤ └─┐  │  ├┬┘├┤ ├─┤ │ ││ ││││
#       888      `"Y88b  888     888      ┴─┘┴┘└┘└─┘└─┘  └─┘┴└─└─┘┴ ┴ ┴ ┴└─┘┘└┘
#       888 oo     .d8P  888     888 
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# lines creation
#




# an branch shall have information, about which connection points, is connected to which line
# an line shall have dictionary information about which branches and which points, it is connected to
# a branch shall have

# line logic needed

# calculating path, based on atleast 2 o more points, its origins, etc so split points for lines too
# whenever the branches on scene moves, it shall check if these branches have any lines connected to them
# then the lines shall be recalculated for each of these points
# the path shall acount into, areas in which each of the branches are, probably plus offset, so lines are around each branch
#


func create_a_line():
	#print("uno  connection creation can continue further ")
	#pass
#
#func draw_a_line():
	print(" connection creation can continue further ", currently_created_line)
	# this needs to be more.. robust, as it can draw from 1/few to 1/few branches
	# count connection points at start
	# count connection points at end
	# calculate center point between them
	# make lines in correct points
	
	# voidadd_point(position: Vector2, index: int = -1)
	# it has x amount of points, dont se a line splitter
	
	# width_of_branch
	# currently_created_line { "starting_branch": { "node": "branch_2", "side": "right" }, "ending_branch": { "node": "branch_3", "side": "left" } }
	
	# currently_created_line
	
	var info_if_line_exist = check_if_line_already_in_node()
	if info_if_line_exist is String:
		print(" node construct return is a string type variant, ", info_if_line_exist)
		draw_construct_of_lines(info_if_line_exist)
		return
	elif info_if_line_exist == false:
		print(" node construct it is new line, just continue ")
	
	
	
	
	
	
	
	
	var new_line = Line2D.new()
	var number_of_line: String = str(branches_pool["tree"]["lines"]["current_number"])
	var line_name_now: String = "line_" + number_of_line
	
	var first_node_name = currently_created_line["starting_branch"]["node"]
	var first_node_point = get_child_branch(first_node_name)
	var position_of_connection_point
	if first_node_point == null:
		position_of_connection_point = Vector2(0.0,0.0)
	else:
		position_of_connection_point = first_node_point.global_position
	
	var left_node
	var right_node
	var left_node_position
	var right_node_position
	#var right_point
	add_line_to_dictionary(line_name_now)
	#func add_left_connection_to_line(line_name, left_con):
	#branches_pool["tree"]["lines"][line_name]["left_connections"].append(left_con)
#
#func add_right_connection_to_line(line_name, right_con):
	#branches_pool["tree"]["lines"][line_name]["right_connections"].append(right_con)
	print(" dilema checkin and why second time it kinda breaks ", currently_created_line)
	if currently_created_line["starting_branch"]["side"] == "left":
		print(" it is left starter")
		position_of_connection_point.x = position_of_connection_point.x - width_of_branch
		right_node = first_node_name
		add_right_connection_to_line(line_name_now, right_node)
		add_line_to_branch(right_node, line_name_now, "right")
		
		right_node_position = position_of_connection_point
	elif currently_created_line["starting_branch"]["side"] == "right":
		print(" it is right starter")
		position_of_connection_point.x = position_of_connection_point.x + width_of_branch
		left_node = first_node_name
		left_node_position = position_of_connection_point
		add_left_connection_to_line(line_name_now, left_node)
		add_line_to_branch(left_node, line_name_now, "left")
	
	#left_point = position_of_connection_point
	new_line.add_point(position_of_connection_point)
	
	
	var second_node_name = currently_created_line["ending_branch"]["node"]
	var second_node_point = get_child_branch(second_node_name)
	var position_of_second_connection_point = second_node_point.global_position
	
	if currently_created_line["ending_branch"]["side"] == "left":
		print(" it is left starter")
		position_of_second_connection_point.x = position_of_second_connection_point.x - width_of_branch
		right_node = second_node_name
		right_node_position = position_of_second_connection_point
		add_right_connection_to_line(line_name_now,right_node)
		add_line_to_branch(right_node, line_name_now, "right")
		
	elif currently_created_line["ending_branch"]["side"] == "right":
		print(" it is right starter")
		position_of_second_connection_point.x = position_of_second_connection_point.x + width_of_branch
		left_node = second_node_name
		left_node_position = position_of_second_connection_point
		add_left_connection_to_line(line_name_now,left_node)
		add_line_to_branch(left_node, line_name_now, "left")
	
	#right_point = position_of_second_connection_point
	new_line.add_point(position_of_second_connection_point)

	# lines amount, some line could be deleted, size of dictionary will change
	# additional key in "lines", named properties, information etc
	# where we could store an int, which we will +1 each time an line is being added
	#
	
	#add_connections_to_line_dictionary(line_name_now, left_node, right_node)
	branches_pool["tree"]["lines"][line_name_now]["points_of_connections"][left_node] = {}
	branches_pool["tree"]["lines"][line_name_now]["points_of_connections"][left_node]["position"] = left_node_position
	
	
	branches_pool["tree"]["lines"][line_name_now]["points_of_connections"][right_node] = {}
	branches_pool["tree"]["lines"][line_name_now]["points_of_connections"][right_node]["position"] = right_node_position
	
#func add_line_to_dictionary(line_name):
	#branches_pool["tree"]["lines"][line_name] = {
		#"left_connections": [],
		#"right_connections": []
	#}
	# lets add counter at the end
	branches_pool["tree"]["lines"]["current_number"] +=1
	print(" branches_pool[tree][lines][current_number] : ", branches_pool["tree"]["lines"]["current_number"])
	new_line.name = line_name_now
	add_child_line(new_line)
	print(" what went wrong saya first impact" , branches_pool["tree"]["lines"][line_name_now])
	
	# needs to be checked if the line exist, by first checking if, any of start or end, having any line
	# needs to create dictionary key for line
	# needs to fill dictionary key for line, the names of nodes, to have, them line positions
	#add_line_to_dictionary(line_name_now)

	
	
	

	
	pass


func draw_construct_of_lines(line_name):
	print()
	print(" what went wrong saya creation is here" , branches_pool["tree"]["lines"][line_name])
	# hmm x amount of left side points on construct
	# x amount of points on right side of construct
	# das ist need... for loop bitte
	# for loop bitte ya? ya, das ist needed, und zwei bitte what
	# oh yes array bitte i guess, array bitte ein zwei
	
	# as now i blessed scriptura with... key input and adding additional branches
	# we now can make another miracle, bless the scriptura to know, if we are making a connection first time
	# or we already had some, and just adding one
	# what if...
	# two lines shall become one
	# it shall first count how many additional lines are there in the line
	#
	# then it shall count branches in both connections of the line
	var line_to_check_amounts = get_child_line(line_name)
	var amounts_of_children = line_to_check_amounts.get_child_count()
	print("1812 amounts of nodes in a line node : ", amounts_of_children)
	if amounts_of_children > 0:
		print("1812 we shall do it different way ")
		var right_connections_amount = branches_pool["tree"]["lines"][line_name]["right_connections"].size()
		var left_connections_amount = branches_pool["tree"]["lines"][line_name]["left_connections"].size()
		var both_counted = right_connections_amount + left_connections_amount
		print(" 1812 it is for line : ", both_counted)
		# as we start from 0, a simple counter which starts from 1 shall give us name for next part anyway
		
		var new_additional_line_after = Line2D.new()
		new_additional_line_after.name = line_name + "_" + str(amounts_of_children)
		
		new_additional_line_after.add_point(Vector2(0,0))
		new_additional_line_after.add_point(Vector2(0,0))
		
		line_to_check_amounts.add_child(new_additional_line_after)
		
		redraw_construct_of_lines(line_name)
		
		#add_to_the_line_construct(line_name)
		return
	
	
	var left_side_points : Array = []
	var right_side_points : Array = []
	var left_x_array: Array = []
	var right_x_array: Array = []
	var left_y_array: Array = []
	var right_y_array: Array = []
	
	var highest_x_left : float = 0.0
	var highest_x_right : float = 0.0
	
	var lowest_x_left : float = 0.0
	var lowest_x_right : float = 0.0
	
	var furthest_left_x: float = 0.0
	var closest_right_x: float = 0.0
	
	var middle_point_x: float = 0.0
	var middle_point_y_highest: float  = 0.0
	var middle_point_y_lowest: float = 0.0
	var both_y_array : Array = []
	var node_of_the_main_line = get_child_line(line_name)
	
	
	# position_of_second_connection_point.x = position_of_second_connection_point.x - width_of_branch
	
	for branches_points_to_find in branches_pool["tree"]["lines"][line_name]["right_connections"]:
		print(" node construct branches in left side bitte : ", branches_points_to_find)
		var node_points_to_check = get_child_branch(branches_points_to_find)
		var node_position = node_points_to_check.global_position
		var point_position = Vector2(node_position.x - width_of_branch, node_position.y)
		right_side_points.append(point_position)
		left_x_array.append(point_position.x)
		both_y_array.append(point_position.y)
		
	for branches_points_to_find_r in branches_pool["tree"]["lines"][line_name]["left_connections"]:
		print(" node construct branches in right side bitte : ", branches_points_to_find_r)
		var node_to_check = get_child_branch(branches_points_to_find_r)
		var node_position = node_to_check.global_position
		var points_position = Vector2(node_position.x + width_of_branch, node_position.y)
		left_side_points.append(points_position)
		right_x_array.append(points_position.x)
		both_y_array.append(points_position.y)
		
	highest_x_left = left_x_array.max()
	lowest_x_left = left_x_array.min()
	
	highest_x_right = right_x_array.max()
	lowest_x_right = right_x_array.min()
	
	furthest_left_x = highest_x_left
	closest_right_x = lowest_x_right
	
	# furthest_left_x is the inner edge of the left group
	# closest_right_x is the inner edge of the right group
	middle_point_x = (furthest_left_x + closest_right_x) / 2.0
	
	middle_point_y_highest = both_y_array.max()
	middle_point_y_lowest = both_y_array.min()
	
	# each branch will use its own y
	# for second point x we will need to use either closest or furthest left/right x
	# singular middle point, for middle point lets reuse line node, we already did have
	# Vector2(middle_point_x, middle_point_y_highest)
	var mid_point = get_child_line(line_name)
	mid_point.set_point_position(0, Vector2(middle_point_x, middle_point_y_highest))
	mid_point.set_point_position(1, Vector2(middle_point_x, middle_point_y_lowest))
	
	
	var line_names_add : int = 0
	
	# --- RIGHT SIDE LOOP ---
	for branches_points_to_find in branches_pool["tree"]["lines"][line_name]["right_connections"]:
		var new_additional_line = Line2D.new()
		var node_points_to_check = get_child_branch(branches_points_to_find)
		
		# 1. Get positions in Global Space
		var global_node_pos = node_points_to_check.global_position
		var global_start = Vector2(global_node_pos.x - width_of_branch, global_node_pos.y)
		var global_end = Vector2(middle_point_x, global_node_pos.y)
		
		# 2. Convert to Local Space (relative to the parent line node)
		var local_start = global_start - node_of_the_main_line.global_position
		var local_end = global_end - node_of_the_main_line.global_position
		
		new_additional_line.add_point(local_start)
		new_additional_line.add_point(local_end)
		new_additional_line.name = line_name + "_" + str(line_names_add)
		
		node_of_the_main_line.add_child(new_additional_line)
		line_names_add +=1
	
	# --- LEFT SIDE LOOP ---
	for branches_points_to_find_r in branches_pool["tree"]["lines"][line_name]["left_connections"]:
		var new_additional_line = Line2D.new()
		var node_to_check = get_child_branch(branches_points_to_find_r)
		
		var global_node_pos = node_to_check.global_position
		var global_start = Vector2(global_node_pos.x + width_of_branch, global_node_pos.y)
		var global_end = Vector2(middle_point_x, global_node_pos.y)
		
		# Convert to Local
		var local_start = global_start - node_of_the_main_line.global_position
		var local_end = global_end - node_of_the_main_line.global_position
		
		new_additional_line.add_point(local_start)
		new_additional_line.add_point(local_end)
		
		new_additional_line.name = line_name + "_" + str(line_names_add)
		
		node_of_the_main_line.add_child(new_additional_line)
		line_names_add +=1
		




func redraw_construct_of_lines(line_name):
	print()
	print(" what went wrong saya creation is here" , branches_pool["tree"]["lines"][line_name])
	# hmm x amount of left side points on construct
	# x amount of points on right side of construct
	# das ist need... for loop bitte
	# for loop bitte ya? ya, das ist needed, und zwei bitte what
	# oh yes array bitte i guess, array bitte ein zwei
	var left_side_points : Array = []
	var right_side_points : Array = []
	var left_x_array: Array = []
	var right_x_array: Array = []
	var left_y_array: Array = []
	var right_y_array: Array = []
	
	var highest_x_left : float = 0.0
	var highest_x_right : float = 0.0
	
	var lowest_x_left : float = 0.0
	var lowest_x_right : float = 0.0
	
	var furthest_left_x: float = 0.0
	var closest_right_x: float = 0.0
	
	var middle_point_x: float = 0.0
	var middle_point_y_highest: float  = 0.0
	var middle_point_y_lowest: float = 0.0
	var both_y_array : Array = []
	var node_of_the_main_line = get_child_line(line_name)
	
	
	# position_of_second_connection_point.x = position_of_second_connection_point.x - width_of_branch
	
	for branches_points_to_find in branches_pool["tree"]["lines"][line_name]["right_connections"]:
		print(" node construct branches in left side bitte : ", branches_points_to_find)
		var node_points_to_check = get_child_branch(branches_points_to_find)
		var node_position = node_points_to_check.global_position
		var point_position = Vector2(node_position.x - width_of_branch, node_position.y)
		right_side_points.append(point_position)
		left_x_array.append(point_position.x)
		both_y_array.append(point_position.y)
		
	for branches_points_to_find_r in branches_pool["tree"]["lines"][line_name]["left_connections"]:
		print(" node construct branches in right side bitte : ", branches_points_to_find_r)
		var node_to_check = get_child_branch(branches_points_to_find_r)
		var node_position = node_to_check.global_position
		var points_position = Vector2(node_position.x + width_of_branch, node_position.y)
		left_side_points.append(points_position)
		right_x_array.append(points_position.x)
		both_y_array.append(points_position.y)
		
	highest_x_left = left_x_array.max()
	lowest_x_left = left_x_array.min()
	
	highest_x_right = right_x_array.max()
	lowest_x_right = right_x_array.min()
	
	furthest_left_x = highest_x_left
	closest_right_x = lowest_x_right
	
	# furthest_left_x is the inner edge of the left group
	# closest_right_x is the inner edge of the right group
	middle_point_x = (furthest_left_x + closest_right_x) / 2.0
	
	middle_point_y_highest = both_y_array.max()
	middle_point_y_lowest = both_y_array.min()
	
	# each branch will use its own y
	# for second point x we will need to use either closest or furthest left/right x
	# singular middle point, for middle point lets reuse line node, we already did have
	# Vector2(middle_point_x, middle_point_y_highest)
	var mid_point = get_child_line(line_name)
	mid_point.set_point_position(0, Vector2(middle_point_x, middle_point_y_highest))
	mid_point.set_point_position(1, Vector2(middle_point_x, middle_point_y_lowest))
	
	
	var line_names_add : int = 0
	
	# --- RIGHT SIDE LOOP ---
	for branches_points_to_find in branches_pool["tree"]["lines"][line_name]["right_connections"]:
		var new_additional_line_name = line_name + "_" + str(line_names_add)
		# func get_child_line_construct(line_name, line_part_name):
		var new_additional_line = node_of_the_main_line.get_node(new_additional_line_name)
		print(" do we even get some node R ", new_additional_line)
		var node_points_to_check = get_child_branch(branches_points_to_find)
		
		# 1. Get positions in Global Space
		var global_node_pos = node_points_to_check.global_position
		var global_start = Vector2(global_node_pos.x - width_of_branch, global_node_pos.y)
		var global_end = Vector2(middle_point_x, global_node_pos.y)
		
		# 2. Convert to Local Space (relative to the parent line node)
		var local_start = global_start - node_of_the_main_line.global_position
		var local_end = global_end - node_of_the_main_line.global_position
		
		new_additional_line.set_point_position(0, local_start)
		new_additional_line.set_point_position(1, local_end)
		line_names_add +=1
		#node_of_the_main_line.add_child(new_additional_line)
	
	# --- LEFT SIDE LOOP ---
	for branches_points_to_find_r in branches_pool["tree"]["lines"][line_name]["left_connections"]:
		var new_additional_line_name = line_name + "_" + str(line_names_add)
		var new_additional_line = node_of_the_main_line.get_node(new_additional_line_name)
		print(" do we even get some node L ", new_additional_line)
		var node_to_check = get_child_branch(branches_points_to_find_r)
		
		var global_node_pos = node_to_check.global_position
		var global_start = Vector2(global_node_pos.x + width_of_branch, global_node_pos.y)
		var global_end = Vector2(middle_point_x, global_node_pos.y)
		
		# Convert to Local
		var local_start = global_start - node_of_the_main_line.global_position
		var local_end = global_end - node_of_the_main_line.global_position
		
		new_additional_line.set_point_position(0, local_start)
		new_additional_line.set_point_position(1, local_end)
		line_names_add +=1
		#node_of_the_main_line.add_child(new_additional_line)



func add_to_the_line_construct(line_name):
	
	
	var left_side_points : Array = []
	var right_side_points : Array = []
	var left_x_array: Array = []
	var right_x_array: Array = []
	var left_y_array: Array = []
	var right_y_array: Array = []
	
	var highest_x_left : float = 0.0
	var highest_x_right : float = 0.0
	
	var lowest_x_left : float = 0.0
	var lowest_x_right : float = 0.0
	
	var furthest_left_x: float = 0.0
	var closest_right_x: float = 0.0
	
	var middle_point_x: float = 0.0
	var middle_point_y_highest: float  = 0.0
	var middle_point_y_lowest: float = 0.0
	var both_y_array : Array = []
	var node_of_the_main_line = get_child_line(line_name)
	
	
	# position_of_second_connection_point.x = position_of_second_connection_point.x - width_of_branch
	
	for branches_points_to_find in branches_pool["tree"]["lines"][line_name]["right_connections"]:
		print(" node construct branches in left side bitte : ", branches_points_to_find)
		var node_points_to_check = get_child_branch(branches_points_to_find)
		var node_position = node_points_to_check.global_position
		var point_position = Vector2(node_position.x - width_of_branch, node_position.y)
		right_side_points.append(point_position)
		left_x_array.append(point_position.x)
		both_y_array.append(point_position.y)
		
	for branches_points_to_find_r in branches_pool["tree"]["lines"][line_name]["left_connections"]:
		print(" node construct branches in right side bitte : ", branches_points_to_find_r)
		var node_to_check = get_child_branch(branches_points_to_find_r)
		var node_position = node_to_check.global_position
		var points_position = Vector2(node_position.x + width_of_branch, node_position.y)
		left_side_points.append(points_position)
		right_x_array.append(points_position.x)
		both_y_array.append(points_position.y)
		
	highest_x_left = left_x_array.max()
	lowest_x_left = left_x_array.min()
	
	highest_x_right = right_x_array.max()
	lowest_x_right = right_x_array.min()
	
	furthest_left_x = highest_x_left
	closest_right_x = lowest_x_right
	
	# furthest_left_x is the inner edge of the left group
	# closest_right_x is the inner edge of the right group
	middle_point_x = (furthest_left_x + closest_right_x) / 2.0
	
	middle_point_y_highest = both_y_array.max()
	middle_point_y_lowest = both_y_array.min()
	
	# each branch will use its own y
	# for second point x we will need to use either closest or furthest left/right x
	# singular middle point, for middle point lets reuse line node, we already did have
	# Vector2(middle_point_x, middle_point_y_highest)
	var mid_point = get_child_line(line_name)
	mid_point.set_point_position(0, Vector2(middle_point_x, middle_point_y_highest))
	mid_point.set_point_position(1, Vector2(middle_point_x, middle_point_y_lowest))
	
	
	var line_names_add : int = 0
	
	
	
	
	
	
	var line_to_check_amounts = get_child_line(line_name)
	var amounts_of_children = line_to_check_amounts.get_child_count()
	#mid_point.get_child_count()
	
	var right_connections_amount = branches_pool["tree"]["lines"][line_name]["right_connections"].size()
	var left_connections_amount = branches_pool["tree"]["lines"][line_name]["left_connections"].size()
	
	
	
	
	
	# --- RIGHT SIDE LOOP ---
	for branches_points_to_find in branches_pool["tree"]["lines"][line_name]["right_connections"]:
		var new_additional_line = Line2D.new()
		var node_points_to_check = get_child_branch(branches_points_to_find)
		
		# 1. Get positions in Global Space
		var global_node_pos = node_points_to_check.global_position
		var global_start = Vector2(global_node_pos.x - width_of_branch, global_node_pos.y)
		var global_end = Vector2(middle_point_x, global_node_pos.y)
		
		# 2. Convert to Local Space (relative to the parent line node)
		var local_start = global_start - node_of_the_main_line.global_position
		var local_end = global_end - node_of_the_main_line.global_position
		
		new_additional_line.add_point(local_start)
		new_additional_line.add_point(local_end)
		new_additional_line.name = line_name + "_" + str(line_names_add)
		
		node_of_the_main_line.add_child(new_additional_line)
		line_names_add +=1
	
	# --- LEFT SIDE LOOP ---
	for branches_points_to_find_r in branches_pool["tree"]["lines"][line_name]["left_connections"]:
		var new_additional_line = Line2D.new()
		var node_to_check = get_child_branch(branches_points_to_find_r)
		
		var global_node_pos = node_to_check.global_position
		var global_start = Vector2(global_node_pos.x + width_of_branch, global_node_pos.y)
		var global_end = Vector2(middle_point_x, global_node_pos.y)
		
		# Convert to Local
		var local_start = global_start - node_of_the_main_line.global_position
		var local_end = global_end - node_of_the_main_line.global_position
		
		new_additional_line.add_point(local_start)
		new_additional_line.add_point(local_end)
		
		new_additional_line.name = line_name + "_" + str(line_names_add)
		
		node_of_the_main_line.add_child(new_additional_line)
		line_names_add +=1


# lines_to_rewrite
func redraw_line_by_name(line_name_to_redrawn):
	
	print(" what went wrong saya newest" , branches_pool["tree"]["lines"][line_name_to_redrawn])
	
	# that ist will need redrawing check, if line singular, or if it is construct of line bitte
	
	var checker_if_return = check_if_line_is_singular(line_name_to_redrawn)
	if checker_if_return == true:
		print(" saya we shall do something ")
		redraw_construct_of_lines(line_name_to_redrawn)
		return
		
	
	
	#var point_to_chane
	var new_line = get_child_line(line_name_to_redrawn)
	var line_to_check_name = String(new_line.name)
	print(" dilema checkin the new fun ", branches_pool["tree"]["lines"])
	var number_bitte : int = 0
	
	for branches_in_line in branches_pool["tree"]["lines"][line_name_to_redrawn]["left_connections"]:
		print(" dilema checkin movement shall tell us ", branches_in_line, " it is line ", line_name_to_redrawn)
		# here is left connection of a line, well it can be anywhere, but it is still the 0 value of line point
		# but first we need to find, which side we are on, on that specific branch, in line 0 point
		# if line points are just changed, point 0, point 1, for now
		
		# position_of_second_connection_point.x = position_of_second_connection_point.x - width_of_branch
		
		if branches_pool["tree"]["branches"][branches_in_line]["left_connection"] == line_name_to_redrawn:
			print(" it is left connection of branch : ", branches_in_line, " and it is line : ", line_name_to_redrawn)
			var branch_node = get_child_branch(branches_in_line)
			var new_point_to_change_into = branch_node.global_position
			new_point_to_change_into.x = new_point_to_change_into.x - width_of_branch
			new_line.set_point_position(number_bitte, new_point_to_change_into) # (index: int, position: Vector2)
			number_bitte +=1
			
		elif branches_pool["tree"]["branches"][branches_in_line]["right_connection"] == line_name_to_redrawn:
			print(" it is right connection of branch : ", branches_in_line, " and it is line : ", line_name_to_redrawn)
			var branch_node = get_child_branch(branches_in_line)
			var new_point_to_change_into = branch_node.global_position
			new_point_to_change_into.x = new_point_to_change_into.x + width_of_branch
			new_line.set_point_position(number_bitte, new_point_to_change_into) # (index: int, position: Vector2)
			number_bitte +=1
			
		
	for branches_in_line_r in branches_pool["tree"]["lines"][line_name_to_redrawn]["right_connections"]:
		print(" dilema checkin movement shall tell us r :", branches_in_line_r, " it is line ", line_name_to_redrawn)
		# here is 1 point of line, for now as later i want them organized into singular branches 
	
		if branches_pool["tree"]["branches"][branches_in_line_r]["left_connection"] == line_name_to_redrawn:
			print(" it is left connection of branch : ", branches_in_line_r, " and it is line : ", line_name_to_redrawn)
			var branch_node = get_child_branch(branches_in_line_r)
			var new_point_to_change_into = branch_node.global_position
			new_point_to_change_into.x = new_point_to_change_into.x - width_of_branch
			new_line.set_point_position(number_bitte, new_point_to_change_into) # (index: int, position: Vector2)
			number_bitte +=1
			
		elif branches_pool["tree"]["branches"][branches_in_line_r]["right_connection"] == line_name_to_redrawn:
			print(" it is right connection of branch : ", branches_in_line_r, " and it is line : ", line_name_to_redrawn)
			var branch_node = get_child_branch(branches_in_line_r)
			var new_point_to_change_into = branch_node.global_position
			new_point_to_change_into.x = new_point_to_change_into.x + width_of_branch
			new_line.set_point_position(number_bitte, new_point_to_change_into) # (index: int, position: Vector2)
			number_bitte +=1
	#var number_of_line: String = str(branches_pool["tree"]["lines"]["current_number"])
	#var line_name_now: String = "line_" + number_of_line

	
	# voidadd_point(position: Vector2, index: int = -1)
	# it has x amount of points, dont se a line splitter
	
	# width_of_branch
	# currently_created_line { "starting_branch": { "node": "branch_2", "side": "right" }, "ending_branch": { "node": "branch_3", "side": "left" } }
	
	# currently_created_line
	
	

func check_if_line_is_singular(line_name):
	if branches_pool["tree"]["lines"][line_name]["left_connections"].size() + branches_pool["tree"]["lines"][line_name]["right_connections"].size() == 2:
		return false
	else:
		return true


func it_will_be():
	var first_node_name = currently_created_line["starting_branch"]["node"]
	var first_node_point = get_child_branch(first_node_name)
	var position_of_connection_point 
	
	var left_node
	var right_node
	var left_node_position
	var right_node_position
	#var right_point
	print(" dilema checkin and why second time it kinda breaks ", currently_created_line)
	if currently_created_line["starting_branch"]["side"] == "left":
		print(" it is left starter")
		position_of_connection_point.x = position_of_connection_point.x - width_of_branch
		right_node = first_node_name
		right_node_position = position_of_connection_point
	elif currently_created_line["starting_branch"]["side"] == "right":
		print(" it is right starter")
		position_of_connection_point.x = position_of_connection_point.x + width_of_branch
		left_node = first_node_name
		left_node_position = position_of_connection_point
	
	#left_point = position_of_connection_point
#	new_line.add_point(position_of_connection_point)
	
	
	var second_node_name = currently_created_line["ending_branch"]["node"]
	var second_node_point = get_child_branch(second_node_name)
	var position_of_second_connection_point = second_node_point.global_position
	
	if currently_created_line["ending_branch"]["side"] == "left":
		print(" it is left starter")
		position_of_second_connection_point.x = position_of_second_connection_point.x - width_of_branch
		right_node = second_node_name
		right_node_position = position_of_second_connection_point
	elif currently_created_line["ending_branch"]["side"] == "right":
		print(" it is right starter")
		position_of_second_connection_point.x = position_of_second_connection_point.x + width_of_branch
		left_node = second_node_name
		left_node_position = position_of_second_connection_point
	
	#right_point = position_of_second_connection_point
	#new_line.add_point(position_of_second_connection_point)


func check_if_lines_shall_be_redrawn(dragging_branch, currently_selected_offsets):
	print(" dilema checkin here we could redrawn lines, if any had some points", " singular branch being dragged : ", dragging_branch, " selection, if not empty i guess : ", currently_selected_offsets)
	if branches_pool["tree"]["branches"][dragging_branch]["left_connection"] != "":
		print(" dilema checkin there is left connection in that branch")
		lines_to_rewrite[branches_pool["tree"]["branches"][dragging_branch]["left_connection"]] = ""
	if branches_pool["tree"]["branches"][dragging_branch]["right_connection"] != "":
		print(" dilema checkin there is right connection in that branch")
		lines_to_rewrite[branches_pool["tree"]["branches"][dragging_branch]["right_connection"]] = ""
	
	if currently_selected_offsets.is_empty():
		print(" here we could redrawn lines, if any had some points info it being empty")
	else:
		print(" dilema checkin it is not empty ", currently_selected_offsets)
		for branch_name in currently_selected_offsets:
			print(" dilema checkin : " , branch_name)
			if branches_pool["tree"]["branches"][branch_name]["left_connection"] != "":
				print(" dilema checkin there is left connection in that branch")
				if not lines_to_rewrite.has(branches_pool["tree"]["branches"][branch_name]["left_connection"]):
					lines_to_rewrite[branches_pool["tree"]["branches"][branch_name]["left_connection"]] = ""
			if branches_pool["tree"]["branches"][branch_name]["right_connection"] != "":
				print(" dilema checkin there is right connection in that branch")
				if not lines_to_rewrite.has(branches_pool["tree"]["branches"][branch_name]["right_connection"]):
					lines_to_rewrite[branches_pool["tree"]["branches"][branch_name]["right_connection"]] = ""
	print(" dilema checkin i guess it should do smth, i there are lines in it " , lines_to_rewrite)
	
	
	for lines_to_be_redrawn in lines_to_rewrite:
		print(" dilema checkin hmm ", lines_to_be_redrawn)
		redraw_line_by_name(lines_to_be_redrawn)
		# first we shall
			
	# branches 1,2,3
	# one branch can be in selection and being an dragging branch
	# remove duplicate strings function would be a miracle and a blessing
	# each of them has which line info, information
	# i guess just simple rewrite of line creation function, minus acknowledgment in dictionary would suffice
	# array and append, oh, dictionary will have just key, and a way to... .has()
	# ok
	


# lines construction if not just two
# needed vars
# left batch
var branches_on_left
# right batch
var branches_on_right
# furthest X to the right, left batch
var furthest_x_to_the_right
# furthest X to the left, right batch
var furthest_x_to_the_left
# highest Y left batch
var highest_y_left
# highest Y right batch
var highest_y_right
# lowest Y left batch
var lowest_y_left
# lowest Y right batch
var lowest_y_right

func calculate_needed_points_for_line_structure(line_name):
	print()

func add_connections_to_line_dictionary(line_name, left_con, right_con):
	print(" branches test ", branches_pool["tree"]["lines"])
	branches_pool["tree"]["lines"][line_name]["left_connections"].append(left_con)
	
	branches_pool["tree"]["lines"][line_name]["right_connections"].append(right_con)
	
	print(" branches test ", branches_pool["tree"]["lines"])

func add_left_connection_to_line(line_name, left_con):
	branches_pool["tree"]["lines"][line_name]["left_connections"].append(left_con)

func add_right_connection_to_line(line_name, right_con):
	branches_pool["tree"]["lines"][line_name]["right_connections"].append(right_con)






# just removing one singular number from an array, is doable, but harder, than recreating it, with ommiting the one we dont wanna
# if array size equal 0, which means it is empty, we could ommit few lines
# what if the array is too long, what we wanna is first, would it run faster, if we somehow, pushback one? change singular cell into null?
# later logic could break
# more safe is recreation of the creation
func remove_left_connection_from_line(branch_name, line_name):
	var new_array_to_switch : Array = []
	for branch_to_remove in branches_pool["tree"]["lines"][line_name]["left_connections"]:
		if branch_to_remove != branch_name:
			new_array_to_switch.append(branch_to_remove)
			
	branches_pool["tree"]["lines"][line_name]["left_connections"] = new_array_to_switch

func remove_right_connection_from_line(branch_name, line_name):
	var new_array_to_switch : Array = []
	for branch_to_remove in branches_pool["tree"]["lines"][line_name]["right_connections"]:
		if branch_to_remove != branch_name:
			new_array_to_switch.append(branch_to_remove)
			
	branches_pool["tree"]["lines"][line_name]["right_connections"] = new_array_to_switch






func add_line_to_branch(node_name, line_name, direction):
	# simple two way if, into dictionary place
	# smart would be even using .has function for dictionary, to first check if that key even exist
	print("")
	if direction == "right":
		print("adding line to a branch left connection")
		branches_pool["tree"]["branches"][node_name]["left_connection"] = line_name
	if direction == "left":
		print("adding line to a branch right connection")
		branches_pool["tree"]["branches"][node_name]["right_connection"] = line_name

func remove_line_from_branch(node_name, line_name, direction):
	print("")
	if direction == "right":
		print("removing line to a branch left connection")
		branches_pool["tree"]["branches"][node_name]["left_connection"] = ""
	if direction == "left":
		print("removing line to a branch right connection")
		branches_pool["tree"]["branches"][node_name]["right_connection"] = ""






func check_if_branch_has_line(branch_name):
	print("check if branch has a line, to be updated")





func update_line_points(line_name):
	print("updating line positions")


func update_left_line_point(line_name, branch_name):
	print("updating left line point")
	
func update_right_line_point(line_name, branch_name):
	print("updating right line point")

func check_if_line_already_in_node():
	# to check if that line already exist in any branch,
	# as it moves right now, we either have singular moving branch, or selection being moved around,
	# that shall be checked first
	# 
	var state_of_check : int = 0
	# 0 means singular
	# 1 means there is a batch to be checked
	#if selected_branches != null:
		#print("construct lines selection is not empty")
		#state_of_check = 1
	#
	#match state_of_check:
		#0:
			#print()
		#1:
			#print()
			#for branches_to_check in selected_branches:
				#print(" construct lines branches_to_check " , branches_to_check)
	#currently_created_line
	var node_a_name = currently_created_line["starting_branch"]["node"]
	var node_a_side = currently_created_line["starting_branch"]["side"]
	var node_a_line_info = null
	var node_b_name = currently_created_line["ending_branch"]["node"]
	var node_b_side = currently_created_line["ending_branch"]["side"]
	var node_b_line_info = null
	#var node_a = get_node(node_a_name)
	#var node_b = get_node(node_b_name)
	# we get them node names
	# we can get info if, there is some line already connected to that branch, we shall also care about... if it is left and right side of the node
	if node_a_side == "left":
		node_a_line_info = branches_pool["tree"]["branches"][node_a_name]["left_connection"]
	elif node_a_side == "right":
		node_a_line_info = branches_pool["tree"]["branches"][node_a_name]["right_connection"]
	
	if node_b_side == "left":
		node_b_line_info = branches_pool["tree"]["branches"][node_b_name]["left_connection"]
	elif node_b_side == "right":
		node_b_line_info = branches_pool["tree"]["branches"][node_b_name]["right_connection"]
	print(" node construct information, a =  ", node_a_line_info , " b = ", node_b_line_info)
	
	if node_a_line_info != "" or node_b_line_info != "":
		print(" node construct one of em aint no null saya, we can... change simple line into an construct of lines ")
		# so what we gotta do from here
		# we got info that indeed, one of the connection points we aim at, does has line already
		# the line itself shall... add the one, that is null right now, to its.. pull of lines
		# to left or right side it shall be added?
		if node_a_line_info == "":
			print(" node construct node a one shall be added ")
			match node_a_side:
				"left":
					print(" node construct it is left one on node a")
					# if it is left side of node, that means its right side of the line
					# was it append bitte?
					# ya aufwiterzeien
					branches_pool["tree"]["lines"][node_b_line_info]["right_connections"].append(node_a_name)
					branches_pool["tree"]["branches"][node_a_name]["left_connection"] = node_b_line_info
					return node_b_line_info
				"right":
					print(" node construct it is right one on node a")
					branches_pool["tree"]["lines"][node_b_line_info]["left_connections"].append(node_a_name)
					branches_pool["tree"]["branches"][node_a_name]["right_connection"] = node_b_line_info
					return node_b_line_info
		if node_b_line_info == "":
			print(" node construct node b instead shall be added ")
			match node_b_side:
				"left":
					print(" node construct it is left side on node b")
					branches_pool["tree"]["lines"][node_a_line_info]["right_connections"].append(node_b_name)
					branches_pool["tree"]["branches"][node_b_name]["left_connection"] = node_a_line_info
					return node_a_line_info
				"right":
					print(" node construct it is right side on node b")
					branches_pool["tree"]["lines"][node_a_line_info]["left_connections"].append(node_b_name)
					branches_pool["tree"]["branches"][node_b_name]["right_connection"] = node_a_line_info
					return node_a_line_info
	
	return false
	




# 
















# depending on, if the grid is turned on, we shall have nicel organized tree
func generate_grid_spacing():
	pass

# editing parameters of a branch 
func open_editor_window():
	pass

# toolbar for tools,
func open_toolbar():
	pass


# history log, preview previous steps, undo to certain moment, redo to certain moment
func open_history_log_window():
	pass

# opening simulation timeline bar, for now it will mostly just show possible time
# dates, it will change colors of tree branches
# later connection with a map, 3d visualizer of parts creation, processing, change of warehouse
# calculations of needed materials etc
func open_simulation_timeline_bar():
	pass


# lines logic
# starting point shal always be, from left, to the right, what shall be checked next, is the
# reason for movement, which is next, shall it go higher, shall it go lower
# maybe it shall go back to the left, as somehow, ending point is, behind starting point
#



# singular nodes connections
#
# a ---- b
func connect_branches(node_a, node_b):
	pass

# a -x- b
func disconnect_branches(node_a,_node_b):
	pass

# a -|
# a -| - b
# a -| - b
func connect_multiple_branches(group_nodes_a, group_nodes_b):
	pass

# a -x
# a -x - b
# a -x - b
func disconnect_multiple_branches(group_nodes_a, group_nodes_b):
	pass

# a -|
# a -|- b
# a -|

func connect_multiple_to_one(group_nodes_a, node_b):
	pass

# a -x
# a -x- b
# a -x

func disconnect_multiple_to_one(group_nodes_a, node_b):
	pass

#    |- b
# a -|- b
#    |- b
func connect_one_to_multiple(node_a, group_nodes_b):
	pass







#########

var menu_width : float = 100.0
var menu_heigth : float = 50.0
var separator_width : float = 80.0
var separator_heigth : float = 5.0


# right click menu
# edit, remove
func draw_menu():
	print()
	# will need its own background body
	# over that there will need to be a text
	# between each texts we shall have separators
	var body_of_menu = Polygon2D.new()
	



# 2D matrix, for whole tree being, drawn, redrawn
# moved around
# kinda just collumns and rows of it in 2d
# to make it possible to add an row or collumn to whole structure
# a singular cell information, shall have things like
# name of part, information of its connection to what
# maybe creation can be more 1D up to certain point
# if another 1D points get a node/cell that exist at some 1D line already
# it shall attatch itself to it, instead of creating again, it might sometimes need to create few the same named cells
# as one type of screw will reappear per machine part
# but after all, every of these 1D lines, will end at singular point of whole machine









## the window of lod, load, changing states of cashed, loaded
## second window around it, so we have lvl of detail in three states
# window 1 = viewport of what will user see
## window 2 = zone between what user sees, and what is way too far to even see a corner
### window 3 = zone too far away to see anything
## it shall all be based on percentages, for ease of use, percentages shall mean values of 0 to 1, where 1 = 100%, 0.0 = 0%
## and for values higher than 100 percent we simply use 1.1 = 110%
var frustum_radius: float = 0.4
var proximity_buffer: float = 0.6
var deallocation_horizon: float = 0.8

var chunks_dictionary: Dictionary = {}
var chunk_size: float = 500.0

## changes will need to be done
# the file path, and number parts
# sometimes the part might use the same picture
# which means not for every part will look for a file and one file might be used for few parts
# either picture or branches will need a change of their parts
# i want dictionary of files paths, maybe even thumbnails storage per order, so it loads faster
# visibility lod might be needed



# input is vector2, adnoted with x and y
func calculate_chunk_pos(position_to_calculate):
	# input 1337.7, divide it by 500.0 it will equal to 2.7? so it will need to be at chunk 3 or 2
	# chunk 0 = from 0 to 500, then 1 = from 500 to 1000, 3 = from 1000 to 1500
	var pos_x = floor(position_to_calculate.x / chunk_size)
	var pos_y = floor(position_to_calculate.y / chunk_size)
	return Vector2i(pos_x, pos_y)

## it will also need in my opinion some chunks system for a map, so we check just nearby, instead of everything, even if it would be only thousand or few thousands of nodes
#
func add_branch_to_chunk(node):
	print("adding a branch to a chunk")
	var node_pos = node.global_position
	var position_of_chunk = calculate_chunk_pos(node_pos)
	
	if not chunks_dictionary.has(position_of_chunk.x):
		chunks_dictionary[position_of_chunk.x] = {}
	
	if not chunks_dictionary[position_of_chunk.x].has(position_of_chunk.y):
		chunks_dictionary[position_of_chunk.x][position_of_chunk.y] = {}
	
	chunks_dictionary[position_of_chunk.x][position_of_chunk.y][node.name] = node
	node.set_meta("current_chunk", Vector2i(position_of_chunk.x, position_of_chunk.y))
	#var state_label_node = node.get_node("state")
	
	#state_label_node.text = "chunk:" + str(position_of_chunk)
	return position_of_chunk
# moving branch between chunks, chunk could not exist, before creating a node
# removing a chunk might be needed, if that chunk has no node add all

# a node name is third key in dictionary
func move_node_in_chunks(node):
	#pass
	var name_of_node = str(node.name)
	var old_chunk = node.get_meta("current_chunk")
	var current_position = calculate_chunk_pos(node.global_position)
	# check if the it is still in the same chunk
	if old_chunk.x != current_position.x or old_chunk.y != current_position.y:
		# the position changed
		chunks_dictionary[old_chunk.x][old_chunk.y].erase(name_of_node)
		#pass
	else:
		# as it might be the same position, it shall return
		return
	# check if it had these positions in chunk dictionary
	if not chunks_dictionary.has(current_position.x):
		chunks_dictionary[current_position.x] = {}
	if not chunks_dictionary[current_position.x].has(current_position.y):
		chunks_dictionary[current_position.x][current_position.y] = {}
	
	node.set_meta("current_chunk", Vector2i(current_position.x, current_position.y))
	chunks_dictionary[current_position.x][current_position.y][name_of_node] = {}

func remove_node_from_chunks(node):
	var cur_chunk = node.get_meta("current_chunk")
	if chunks_dictionary.has(cur_chunk.x) and chunks_dictionary.has(cur_chunk.y):
		chunks_dictionary[cur_chunk.x][cur_chunk.y].erase(node.name)

func update_chunk_label(node):
	var label_nod = node.get_node("state")
	var text_for_label = node.get_meta("current_chunk")
	label_nod.text = str(text_for_label)


func get_camera_view_area() -> Rect2:
	var viewport_size = get_viewport_rect().size
	var zoom = $Camera2D.zoom # Assuming you have a Camera2D node
	
	# The size of the world area visible on screen
	# If zoom is 0.5 (zoomed out), the visible size is DOUBLED
	var visible_size_world = viewport_size / zoom
	
	# The top-left corner in world coordinates
	# camera.get_screen_center_position() gives the middle point
	var top_left = $Camera2D.get_screen_center_position() - (visible_size_world / 2.0)
	
	return Rect2(top_left, visible_size_world)



func update_visible_chunks():
	var view_area = get_camera_view_area()
	
	# Find the first and last chunk coordinates
	var start_x = floor(view_area.position.x / chunk_size)
	var end_x = floor(view_area.end.x / chunk_size)
	var start_y = floor(view_area.position.y / chunk_size)
	var end_y = floor(view_area.end.y / chunk_size)
	print("zoom info start_x : ", start_x, " end_x : ", end_x, " start_y : ", start_y, " end_y : ", end_y)
	# Now you have a range! 
	# For example: from Chunk X: 2 to 5, and Y: -1 to 3.
	for x in range(start_x, end_x + 1):
		for y in range(start_y, end_y + 1):
			if chunks_dictionary.has(x) and chunks_dictionary[x].has(y):
				# These branches are "On Screen"
				process_visible_chunk(x, y)

# to be done
func process_visible_chunk(x, y):
	var current_zoom = $Camera2D.zoom.x
	#var true_width = (width_of_branch * 2) * current_zoom
	var true_heigh = (height_of_branch * 2) * current_zoom
	# each visible chunk does not mean it has anything in it

	if true_heigh < 50:
		print(" it needs to change into singular background for some sprite ")
		return
		# as it is too small to even see, there is no reason to render it
	else:
		# it is bigger than just 50 pixels, lets try to find it first
		## of course, we can also store something in some dictionary or some set_meta stuff, the path to its tif file, we found already
		# so we look for it once and resuse the path
		# wait that part is done already
		var path_to_dir = file_path_cleanse()
		var tree_to_check = load_tree_gs()
		for a_branch in chunks_dictionary[x][y]:
			#print("zoom info found a branch currently visible, it is :", a_branch, " camera zoom stuff ", $Camera2D.zoom, " the branch size is : ", true_width, " by ", true_heigh)
			# here a logic to load and apply sprites textures of whatever we gotten from magick
			## path_to_dir
			var branch_node = get_child_branch(str(a_branch))
			if branch_node.has_meta("tif_path"):
					var existing_path = branch_node.get_meta("tif_path")
					if existing_path == "NOT_FOUND":
						continue # We already know it's not there, don't look again
					else:
						# It exists! Make sure the sprite is visible
						ensure_sprite_setup(branch_node, existing_path)
						continue
			##
			var word_to_check = tree_to_check["all_branches"][str(a_branch)]
			var full_file_path = check_for_file(path_to_dir, word_to_check)
			print(" zoom info, we might find that file - path to dir = ",path_to_dir, " word to check = ",word_to_check, " file full path = ",full_file_path)
			##
			if full_file_path == "":
				print(" it might be empty")
				branch_node.set_meta("tif_path", "NOT_FOUND")
			else:
				print("Search finished: Found ", full_file_path)
				branch_node.set_meta("tif_path", full_file_path)
				ensure_sprite_setup(branch_node, full_file_path)


func ensure_sprite_setup(node: Node2D, path: String):
	var sprite = node.get_node_or_null("MagickSprite")
	
	# If sprite doesn't exist yet, create it
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "MagickSprite"
		node.add_child(sprite)
		# Position it in the center of your branch cell
		sprite.position = Vector2(0, 0) 
	
	# If it's visible and doesn't have a texture yet, this is where Magick kicks in
	if sprite.texture == null:
		print("Ready to trigger Magick for: ", path)
		# apply_magick_to_sprite(sprite, path)
		sprite.texture = get_thumbnail_to_ram(path)

func check_for_file(path_to_directory: String, file_to_look_for: String) -> String:
	var dir = DirAccess.open(path_to_directory)
	if not dir:
		# Could not open directory (maybe network is down?)
		return ""

	dir.list_dir_begin()
	var file_or_folder = dir.get_next()

	while file_or_folder != "":
		# Ignore the 'hidden' system dots
		if file_or_folder == "." or file_or_folder == "..":
			file_or_folder = dir.get_next()
			continue

		var full_current_path = path_to_directory.path_join(file_or_folder)

		if dir.current_is_dir():
			# It's a folder! Let's look inside it.
			var result = check_for_file(full_current_path, file_to_look_for)
			if result != "":
				return result # We found it deep inside, pass the path back up!
		else:
			# It's a file! Let's check the name.
			# We use to_lower() so "Part.tif" matches "part.tif"
			if file_or_folder.to_lower().contains(file_to_look_for.to_lower()):
				if file_or_folder.get_extension().to_lower() == "tif":
					return full_current_path # Found a match!

		file_or_folder = dir.get_next()

	return "" # Found nothing in this branch

var cleaned_path : String = ""

func file_path_cleanse():
	if cleaned_path == "":
		# we can make it as it is not yet
		var path_to_files = GlobalState.load_file_path()
		#print("path to files : ", path_to_files, " some func : ", path_to_files.get_base_dir())
		cleaned_path = path_to_files.get_base_dir()
		return cleaned_path
	else:
		return cleaned_path

var tree_branch_stuff: Dictionary = {}

func load_tree_gs():
	#func load_tree_dict():
	#return tree_dictionary
	if tree_branch_stuff.is_empty():
		tree_branch_stuff = GlobalState.load_tree_dict()
		return tree_branch_stuff
	else:
		return tree_branch_stuff
# now we will need to look for tif file


func get_thumbnail_to_ram(tiff_path: String) -> Texture2D:
	var exe_path = ProjectSettings.globalize_path("res://bin/magick.exe")
	var input_path = ProjectSettings.globalize_path(tiff_path)
	
	# Keep the same args
	var args = [input_path + "[0]", "-thumbnail", "256x256", "inline:JPG:-"]
	
	var output = []
	var exit_code = OS.execute(exe_path, args, output, true)
	
	if exit_code == 0 and output.size() > 0:
		var full_output = output[0]
		
		# FIND where the image data actually starts
		var search_str = "data:image/jpeg;base64,"
		var start_index = full_output.find(search_str)
		
		if start_index != -1:
			# Cut off everything BEFORE and INCLUDING the "data:image/jpeg;base64,"
			var base64_data = full_output.substr(start_index + search_str.length())
			
			# Remove any trailing newlines or junk at the end
			base64_data = base64_data.strip_edges()
			
			var buffer = Marshalls.base64_to_raw(base64_data)
			var img = Image.new()
			var err = img.load_jpg_from_buffer(buffer)
			
			if err == OK:
				return ImageTexture.create_from_image(img)
			else:
				print("Image Load Error: ", err)
	
	print("RAM Load failed for: ", tiff_path)
	return null
