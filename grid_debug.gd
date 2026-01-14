extends Node2D

var points_matrix_coordinates: Array = []
# 0 = horizontal, 1 = vertical, 2 unspecified, better than null most of te time
var screen_mode: int = 2
var screen_ratio: Vector2i
var points_distance: float
var zones_dictionary: Dictionary = {}
var separation_value: int = 1
# we start from 0, so 15 is 16 times
var ratio_a: int = 15
var ratio_b: int = 8
var calculation_in_process: int = 0
var central_zone_mode: String = "center"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#var X_MIDPOINT_INDEX: float = 1.5
	#var is_midpoint_a_whole_number = fmod(X_MIDPOINT_INDEX, 1.0) < 0.001 
	#print("first check ",is_midpoint_a_whole_number)
	
	#print("hmm")
	initialize_zones_dictionary()
	get_tree().root.size_changed.connect(_on_window_resize)
	var startup_viewport_size = get_viewport().size
	#get_tree().root.mode_changed.connect(_on_window_mode_changed)
	draw_points_for_interface(startup_viewport_size)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func draw_points_for_interface(viewport_current_size):
	if calculation_in_process == 1:
		return
	calculation_in_process = 1
	# first we get the viewport size from process, or signal, as the window size would change
	# based on points, we will fill, either Array or Dictionary, lets make vertical points the first ones
	# if Array used, it will be points_positions[0] - first row of points, points_positions[1] - second row of points and so on
	# in any row of points, we will have from 0 to x, depending on specified size of the 2d matrix, from points_positions[0][0] to points_positions[0][x]
	# to calculate points width and height, we will need to first check which dimension is shorter
	# horizontal and vertical app possible, but will need more calculation, for the.. viewport
	# need also check, if on that x lenght of points distances, we can fit all of these points, the whole program can either be centered
	# or it can fit to one of corners
	# i gues having them ratios, can make calculations faster and just base it on them, in certain way
	var lenght_to_set: float
	var mode_to_enlarge: String = "unknown"
	
	
	var total_lenght_of_splitted: float
	var lenght_to_add_in_center: float
	points_matrix_coordinates.clear()
	points_matrix_coordinates = []
	#print("points_matrix_coordinates ",points_matrix_coordinates)
	if viewport_current_size.x < viewport_current_size.y:
		screen_mode = 0
		screen_ratio = Vector2i(ratio_b,ratio_a)
		# the screen is in horizontal mode
		#print("horizontal mode")
	else:
		screen_mode = 1
		screen_ratio = Vector2i(ratio_a,ratio_b)
		# screen is in vertical mode
		
	var amount_to_add
	var which_is_choes: int = 2
	var which_vh_chosen: int = 2
	
	if screen_mode == 0 or 1:
		#
		var points_distance_a = viewport_current_size.x / screen_ratio.x
		var points_distance_b = viewport_current_size.y / screen_ratio.y
		# points_distance
		
		if points_distance_a == points_distance_b:
			#print("both points are equal")
			lenght_to_set = points_distance_a
			which_vh_chosen = 2
		elif points_distance_a < points_distance_b:
			print("vertical must be split and enlarged", points_distance_a)
			mode_to_enlarge = "vertical"
			lenght_to_set = points_distance_a
			which_vh_chosen = 0
			#amount_to_add = points_distance_a
		elif points_distance_b < points_distance_a:
			print("horizontal must be split and enlarged", points_distance_b)
			mode_to_enlarge = "horizontal"
			lenght_to_set = points_distance_b
			which_vh_chosen = 1
	
	#var horizontal_dimension_splitted = ()
	#var vertical_dimension_splitted
	
	# first calculate the amounts to add each for for loop loop
	#print("lenght_to_set : * x ", lenght_to_set * screen_ratio.x)
	#print("lenght_to_set * y: ", lenght_to_set * screen_ratio.y)
	#print("size : ", viewport_current_size)
	
	
	
	
	
	if mode_to_enlarge == "horizontal":
		
		# inside of that split we then must each time, check if its ration vertical or horizontal
		if screen_mode == 0:# 0 = vertical
			# divide by 2
			which_is_choes = 1
			print("aaa0 = V_H ", which_is_choes)
			print("lenght_to_set : * x ", lenght_to_set * screen_ratio.x)
			amount_to_add = viewport_current_size.x - (lenght_to_set * screen_ratio.x)
			print(" amount_to_add , divide by 2 : ", amount_to_add)
			#amount_to_add = amount_to_add / 2
			pass
		elif screen_mode == 1:# 1 = horizontal
			# add once
			which_is_choes = 0
			print("aaa1 = H_H", which_is_choes)
			print("lenght_to_set : * x ", lenght_to_set * screen_ratio.x)
			amount_to_add = viewport_current_size.x - (lenght_to_set * screen_ratio.x)
			print(" amount_to_add  : ", amount_to_add)
			pass
	
	elif mode_to_enlarge == "vertical":
		pass
		# checking if whole screen in v or h mode
		if screen_mode == 0:# 0 = vertical
			# add once
			which_is_choes = 0
			print("aaa2 = V_V", which_is_choes)
			print("lenght_to_set * y: ", lenght_to_set * screen_ratio.y)
			amount_to_add = viewport_current_size.y - (lenght_to_set * screen_ratio.y)
			print(" amount_to_add  : ", amount_to_add)
			pass
		elif screen_mode == 1:# 1 = horizontal
			# divide by 2
			which_is_choes = 1
			print("aaa3 = H_V", which_is_choes)
			print("lenght_to_set * y: ", lenght_to_set * screen_ratio.y)
			amount_to_add = viewport_current_size.y - (lenght_to_set * screen_ratio.y)
			print(" amount_to_add ,  divide by 2 : ", amount_to_add)
			#amount_to_add = amount_to_add / 2
			pass
	
	
	#if which_is_choes == 1:
		## divide number twice
		#pass
		##number_to_add_to_split
	#elif which_is_choes == 0:
		## add as is
		#pass

	var number_x:float = (screen_ratio.x + 1) / 2.0
	var number_y:float = (screen_ratio.y + 1) / 2.0
	var ratio_x_check = fmod(number_x, 1.0) < 0.001
	var ratio_y_check = fmod(number_y, 1.0) < 0.001
	print(" first check two number_x ", number_x, " - ", ratio_x_check, " and number_y ",number_y," - ", ratio_y_check)
	print(" number we look for, 4 and 7 , screen_ratio.x / 2 = ", screen_ratio.x / 2 , " screen_ratio.y / 2 = ", screen_ratio.y / 2)
	
	
	print("screen_ratio.x = ", screen_ratio.x, " ")

	for rows in range(screen_ratio.x + 1):
		#print(rows)
		var current_row = []
		
		for columns in range(screen_ratio.y + 1):
			#print("columns", columns)
			# checker for columns and rows, to check if we have more horizontal or vertical
			# already kinda done
			# horizontal
			# var number_to_add in center horizontally 
			# it equals, total width - calculated lenght_to_se
			# if current_row > 
			
			# first we check which place for split to create
			# screen_mode
			# 0 = horizontal
			# 1 = vertical
			
			# rows
			# columns
			if mode_to_enlarge == "horizontal":
				
				# inside of that split we then must each time, check if its ration vertical or horizontal
				if screen_mode == 0:# 0 = vertical
					# 
					#print("aaa0 = V_H ", which_is_choes)
					# Vertical_Horizontal
					# each 3rd and 4th row, in each column
					
					if rows == screen_ratio.x / 2:
						#print(columns)
						var cell_content = [] 
						var positions_of_point = Vector2((lenght_to_set * rows) + (amount_to_add / 2), lenght_to_set * columns)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
					elif rows > screen_ratio.x / 2:
						#print(columns)
						var cell_content = [] 
						var positions_of_point = Vector2((lenght_to_set * rows) + amount_to_add, lenght_to_set * columns)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
					else:
						#print(columns)
						var cell_content = [] 
						var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
				elif screen_mode == 1:# 1 = horizontal
					# Horizontal_Horizontal
					# column 7, once per row
					#print("aaa1 = H_H", which_is_choes)
					#if rows == 7:
						#var cell_content = [] 
						#var positions_of_point = Vector2((lenght_to_set * rows) + (amount_to_add / 2), lenght_to_set * columns)
						#cell_content.append(positions_of_point)
						#current_row.append(cell_content)
					if rows > screen_ratio.x / 2:
						var cell_content = [] 
						var positions_of_point = Vector2((lenght_to_set * rows) + amount_to_add, lenght_to_set * columns)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
					else:
						#print(columns)
						var cell_content = [] 
						var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
			elif mode_to_enlarge == "vertical":
				# checking if whole screen in v or h mode
				if screen_mode == 0:# 0 = vertical
					# Vertical_Vertical
					# each column at 7th row
					#print("aaa2 = V_V", which_is_choes)
					if columns > screen_ratio.y / 2:
						var cell_content = [] 
						var positions_of_point = Vector2(lenght_to_set * rows, (lenght_to_set * columns) + amount_to_add)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
					else:
						#print(columns)
						var cell_content = [] 
						var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
				elif screen_mode == 1:# 1 = horizontal
					# Horizontal_Vertical
					# Each Row, on columns 3 and 4
					#print("aaa3 = H_V", which_is_choes)
					if columns == screen_ratio.y / 2:
						var cell_content = [] 
						var positions_of_point = Vector2(lenght_to_set * rows, (lenght_to_set * columns) + amount_to_add / 2)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
					elif columns > screen_ratio.y / 2:
						var cell_content = [] 
						var positions_of_point = Vector2(lenght_to_set * rows, (lenght_to_set * columns) + amount_to_add)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
					else:
						#print(columns)
						var cell_content = [] 
						var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
						cell_content.append(positions_of_point)
						current_row.append(cell_content)
			#draw_circle(positions_of_point, dot_radius, dot_color)
			
		points_matrix_coordinates.append(current_row)
			#points_matrix_coordinates[rows][columns].append(positions_of_point)
	#print(points_matrix_coordinates[1][0])
	print("array check a ", points_matrix_coordinates[0])
	update_zones_dictionary_positions()
	queue_redraw() 
	calculation_in_process = 0



func _draw():
	# Only draw if the data has been loaded
	if points_matrix_coordinates.is_empty():
		return
		
	# --- Drawing Parameters ---
	var point_radius = 2.0
	var point_color = Color(0.8, 0.9, 1.0, 0.7) # Light blue, 70% opacity

	# Iterate through the rows and columns
	for row_array in points_matrix_coordinates:
		for cell_content in row_array:
			# Based on your previous structure, the Vector2 is the first item
			# in the innermost array (cell_content[0])
			var position_vector = cell_content[0]
			
			# Draw a circle at the specified position
			draw_circle(position_vector, point_radius, point_color)
	
	# i guess just drawing center can show us something,
	var P_start = zones_dictionary["center"]["position_a"]
	var P_end = zones_dictionary["center"]["position_b"]
	var rect_size = P_end - P_start
	
	var drawing_rect = Rect2(P_start, rect_size)
	var rect_color = Color.RED
	
	# Optional: Draw the border only (unfilled)
	var filled = false 
	
	# Draw the rectangle
	draw_rect(drawing_rect, rect_color, filled)
# func _on_viewport_resized():
#func _on_viewport_resized():
	#print("window changed")

func _on_window_resize():
	# Do your logic here
	var new_size = get_viewport().size
	#print("New window size: ", new_size)
	draw_points_for_interface(new_size)

func initialize_zones_dictionary():
	#print()
	# empty wording for each zone in dictionary, its position, current usage etc
	
	var zone_dictionary_blueprint: Dictionary = {
		"position_a": Vector2(0.0, 0.0),
		"position_b": Vector2(0.0, 0.0),
		"current_usage": ""
	}
	zones_dictionary["center"] = zone_dictionary_blueprint.duplicate(true)
	zones_dictionary["center_bottom"] = zone_dictionary_blueprint.duplicate(true)
	zones_dictionary["center_whole"] = zone_dictionary_blueprint.duplicate(true)
	zones_dictionary["top"] = zone_dictionary_blueprint.duplicate(true)
	zones_dictionary["bottom"] = zone_dictionary_blueprint.duplicate(true)
	zones_dictionary["left"] = zone_dictionary_blueprint.duplicate(true)
	zones_dictionary["right"] = zone_dictionary_blueprint.duplicate(true)
	
func update_zones_dictionary_positions():
	#print("points_matrix_coordinates 0 ", points_matrix_coordinates[1][1][0])
	
	# if it is horizontal mode, 16:9, but somehow in range had to be used to fill it all, so its 15:8 in code + 1
	#
#	if screen_ratio == Vector2i(15,8):
		#print("it is horizontal")
	#print("array check ", points_matrix_coordinates[0])
	if not points_matrix_coordinates[0].is_empty():
		zones_dictionary["center"]["position_a"] = points_matrix_coordinates[separation_value][separation_value][0]
		zones_dictionary["center"]["position_b"] = points_matrix_coordinates[screen_ratio.x - separation_value][screen_ratio.y - separation_value][0]
		zones_dictionary["center_bottom"]["position_a"] = points_matrix_coordinates[0][separation_value][0]
		zones_dictionary["center_bottom"]["position_b"] = points_matrix_coordinates[screen_ratio.x][screen_ratio.y][0]
		zones_dictionary["center_whole"]["position_a"] = points_matrix_coordinates[0][0][0]
		zones_dictionary["center_whole"]["position_b"] = points_matrix_coordinates[screen_ratio.x][screen_ratio.y][0]
		zones_dictionary["top"]["position_a"] = points_matrix_coordinates[0][0][0]
		zones_dictionary["top"]["position_b"] = points_matrix_coordinates[screen_ratio.x][separation_value][0]
		zones_dictionary["bottom"]["position_a"] = points_matrix_coordinates[0][screen_ratio.y - separation_value][0]
		zones_dictionary["bottom"]["position_b"] = points_matrix_coordinates[screen_ratio.x][separation_value][0]
		zones_dictionary["left"]["position_a"] = points_matrix_coordinates[0][separation_value][0]
		zones_dictionary["left"]["position_b"] = points_matrix_coordinates[separation_value][screen_ratio.y - separation_value][0]
		zones_dictionary["right"]["position_a"] = points_matrix_coordinates[screen_ratio.x - separation_value][separation_value][0]
		zones_dictionary["right"]["position_b"] = points_matrix_coordinates[screen_ratio.x][screen_ratio.y - separation_value][0]
		#print("zones_dictionary : ",zones_dictionary["center"]["position_a"])
	#elif screen_ratio == Vector2i(8,15):
		##print("it is vertical")
		#zones_dictionary["center"]["position_a"] = points_matrix_coordinates[1][1][0]
		#zones_dictionary["center"]["position_b"] = points_matrix_coordinates[7][14][0]
		#zones_dictionary["center_bottom"]["position_a"] = points_matrix_coordinates[1][0][0]
		#zones_dictionary["center_bottom"]["position_b"] = points_matrix_coordinates[8][15][0]
		#zones_dictionary["center_whole"]["position_a"] = points_matrix_coordinates[0][0][0]
		#zones_dictionary["center_whole"]["position_b"] = points_matrix_coordinates[8][15][0]
		#zones_dictionary["top"]["position_a"] = points_matrix_coordinates[0][0][0]
		#zones_dictionary["top"]["position_b"] = points_matrix_coordinates[1][15][0]
		#zones_dictionary["bottom"]["position_a"] = points_matrix_coordinates[7][0][0]
		#zones_dictionary["bottom"]["position_b"] = points_matrix_coordinates[1][15][0]
		#zones_dictionary["left"]["position_a"] = points_matrix_coordinates[1][0][0]
		#zones_dictionary["left"]["position_b"] = points_matrix_coordinates[7][1][0]
		#zones_dictionary["right"]["position_a"] = points_matrix_coordinates[1][14][0]
		#zones_dictionary["right"]["position_b"] = points_matrix_coordinates[7][15][0]
	
	# just top rows into one zone
	# just bottom rows into one zone
	# left/right zones, minus top and bottom
	# center zone
	# center zone, minus top zone
	# we have an array already, created from grounds up, each time when.. window resizes
	#

# so now points experience existence
# the next step would be creation of zones, points 0.0, 0.1, 1.0, 1.1 would be top left square called first zone/ zone zero,
# i guess for clicking purposes, just knowing where viewport clicked, could be calculated what zone it clicked
# making some prewritten consts, specifying.. pages of program lik websites
# where we make zones, kinda like div stuff,
# top zones being for menu for example, top right etc, middle zones becoming its own.. whole window array based on zones dimensions, where clicking can be calculated based on what zone we click
# what specific point of it.. was clicked etc
# either we draw that interface, or create the interfacs and scale containers, so they.. fit inside all assigned zones
# top bar, menu button, to whip out menu, home button to go to main.. screen, and maybe button in menu for each specific window
# bottom screen not assigned right now, mostly thinking of center, minus that top/ maybe just corner of screen, but zones divided by ratio is already there
# 


#func draw_debug_dot(position_to_draw_at):
	

#func _on_window_mode_changed():
	#var new_size = get_viewport().size
	#print("New window size: ", new_size)
	#draw_points_for_interface(new_size)


























			# checker for columns and rows, to check if we have more horizontal or vertical
			# already kinda done
			# horizontal
			# var number_to_add in center horizontally 
			# it equals, total width - calculated lenght_to_se
			# if current_row > 
			
			# first we check which place for split to create
			# screen_mode
			# 0 = horizontal
			# 1 = vertical
			
			# rows
			# columns
			
			

#
#
			#if mode_to_enlarge == "horizontal":
#
#
#
#
				## inside of that split we then must each time, check if its ration vertical or horizontal
				#if screen_mode == 0:# 0 = vertical
					## 
					##print("aaa0 = V_H ", which_is_choes)
					## Vertical_Horizontal
					## each 3rd and 4th row, in each column
					##print("aaa0 = V_H ", which_is_choes)
					## Vertical_Horizontal
					## each 3rd and 4th row, in each column
					#
		#if rows == 4:
			##print(columns)
			#var cell_content = [] 
			#var positions_of_point = Vector2((lenght_to_set * rows) + (amount_to_add / 2), lenght_to_set * columns)
			#cell_content.append(positions_of_point)
			#current_row.append(cell_content)
		#elif rows > 4:
			##print(columns)
			#var cell_content = [] 
			#var positions_of_point = Vector2((lenght_to_set * rows) + amount_to_add, lenght_to_set * columns)
			#cell_content.append(positions_of_point)
			#current_row.append(cell_content)
		#else:
			##print(columns)
			#var cell_content = [] 
			#var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
			#cell_content.append(positions_of_point)
			#current_row.append(cell_content)
#
#
#
#
#
#
	#elif screen_mode == 1:# 1 = horizontal
		## Horizontal_Horizontal
		## column 7, once per row
		##print("aaa1 = H_H", which_is_choes)
		##if rows == 7:
			##var cell_content = [] 
			##var positions_of_point = Vector2((lenght_to_set * rows) + (amount_to_add / 2), lenght_to_set * columns)
			##cell_content.append(positions_of_point)
			##current_row.append(cell_content)
		#if rows > 7:
			#var cell_content = [] 
			#var positions_of_point = Vector2((lenght_to_set * rows) + amount_to_add, lenght_to_set * columns)
			#cell_content.append(positions_of_point)
			#current_row.append(cell_content)
		#else:
			##print(columns)
			#var cell_content = [] 
			#var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
			#cell_content.append(positions_of_point)
			#current_row.append(cell_content)
#
#
#
#
#
#
#
#
	#elif mode_to_enlarge == "vertical":
		## checking if whole screen in v or h mode
		#if screen_mode == 0:# 0 = vertical
			## Vertical_Vertical
			## each column at 7th row
			##print("aaa2 = V_V", which_is_choes)
			#if columns > 7:
				#var cell_content = [] 
				#var positions_of_point = Vector2(lenght_to_set * rows, (lenght_to_set * columns) + amount_to_add)
				#cell_content.append(positions_of_point)
				#current_row.append(cell_content)
			#else:
				##print(columns)
				#var cell_content = [] 
				#var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
				#cell_content.append(positions_of_point)
				#current_row.append(cell_content)
				#
#
#
#
#
		#elif screen_mode == 1:# 1 = horizontal
			## Horizontal_Vertical
			## Each Row, on columns 3 and 4
			##print("aaa3 = H_V", which_is_choes)
			#if columns == 4:
				#var cell_content = [] 
				#var positions_of_point = Vector2(lenght_to_set * rows, (lenght_to_set * columns) + amount_to_add / 2)
				#cell_content.append(positions_of_point)
				#current_row.append(cell_content)
			#elif columns > 4:
				#var cell_content = [] 
				#var positions_of_point = Vector2(lenght_to_set * rows, (lenght_to_set * columns) + amount_to_add)
				#cell_content.append(positions_of_point)
				#current_row.append(cell_content)
			#else:
				##print(columns)
				#var cell_content = [] 
				#var positions_of_point = Vector2(lenght_to_set * rows, lenght_to_set * columns)
				#cell_content.append(positions_of_point)
				#current_row.append(cell_content)
#
#
#
#
#
#
