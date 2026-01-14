extends Node2D

#@onready var file_dialog: FileDialog = $FileDialog
var file_dialog
# Called when the node enters the scene tree for the first time.

var file_chosen : String

var template_background_separators_container
var template_labels_container


# change or add, aditional value of the schematic used, as some might be mirrored
# the mirrored ones use the same schematics most of the time, and image might need to be reused
# as more than one node, might use the same picture
# there will be a need for change of the file lookup in tree branch script


func _ready() -> void:
# Setup the dialog via code (or do it in the Inspector)
	# i guess first we shall create some boxes where the data we will look for will be
	# 
	# [Stufe][Posn][Material][Anz.][Menge][ME][Abmess_1][ME][Abmes_2][Bezeichnung.............................][Zeinr]
	# 
	# 
	
	generate_template_row()
	
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	
	file_dialog.use_native_dialog = true
	
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.use_native_dialog = true # This makes it use Windows File Explorer
	
	# Connect the signal that gives you the path
	file_dialog.file_selected.connect(_on_file_selected)
	
	#string_checker_for_exact_positions()

var template_row_words : Array = ["Stufe", "Posn", "Material", "Anz.", "Menge", "ME", "Abmess_1", "ME", "Abmes_2", "Bezeichnung", "Zeinr"]

var template_row_name : String = "template_row"
var template_label_name : String = "template_label_"
var template_labels_dictionary : Dictionary = {}
var current_labels_height : float = 0.0
var all_labels_width : float = 0.0
#
#var template_background_separators_container
#var template_labels_container

func generate_template_row():
	#[Stufe][Posn][Material][Anz.][Menge][ME][Abmess_1][ME][Abmes_2][Bezeichnung.............................][Zeinr]

	var number_to_add : int = 0
	
	template_background_separators_container = Node2D.new()
	template_background_separators_container.name = "background_separators_container"
	add_child(template_background_separators_container)
	
	template_labels_container = Node2D.new()
	template_labels_container.name = template_row_name
	add_child(template_labels_container)
	
	
	for column_name in template_row_words:
		var label_to_generate = Label.new()
		var curr_name_to_set = template_label_name + str(number_to_add)
		label_to_generate.name = curr_name_to_set
		label_to_generate.text = column_name
		template_labels_container.add_child(label_to_generate)
		var width_of_label = label_to_generate.size.x
		print(" label width is ", width_of_label)
		
		if template_labels_dictionary.has(column_name):
			column_name = column_name + "_0"
		
		template_labels_dictionary[column_name] = {
			"width": width_of_label,
			"name": curr_name_to_set
		}
		number_to_add +=1
		all_labels_width = all_labels_width + width_of_label
		
	var first_label_node = template_labels_container.get_child(0)
	current_labels_height = first_label_node.size.y
	
	print(" first label_ node ", first_label_node, " its height : ", current_labels_height)
	draw_grid_for_template_row()
# var template_labels_dictionary : Dictionary = {}
# it will need to store keys of each label, their width

# draw grid with polygon2d
# 15 parts for 11 blocks/labels
# less than making 2 polygons for each
# first we will need screen width

var width_of_the_separators : float = 3.69

# width of separators being 8, how do i even wanna.... paint them i guess,
# the two main lines on top and bottom, would be, whole screen size
# in width, its height would be just 8
# then we have label height, probably label height depends if it will change
# will need current lenght for the top left corner of each separator
# with that we add that 8 to make top right corner, which will be new beginning for the label, next label
# height of the label will.. add to y, to make 3rd point
# for last point we will just - 8 to make it
# height = current_labels_height


func draw_grid_for_template_row():
	
	

	
	
	var startup_viewport_size = get_viewport().size
	print(" the size of viewport ", startup_viewport_size, " umm dictionary : ", template_labels_dictionary)
	# startup_viewport_size.x , whole size of the screen
	
	var background_polygon_width = startup_viewport_size.x
	var width_for_calculation = background_polygon_width - (width_of_the_separators * 12)
	var multiplication_calculation = width_for_calculation / all_labels_width
	
	var tester_label_to_check_heigh = Label.new()
	tester_label_to_check_heigh.text = "Test"
	add_child(tester_label_to_check_heigh)
	var current_fs = tester_label_to_check_heigh.get_theme_default_font_size()
	print(" test font size 1 " , tester_label_to_check_heigh.size)
	var new_fs = int(current_fs * multiplication_calculation)
	tester_label_to_check_heigh.add_theme_font_size_override("font_size", new_fs)
	print(" test font size 2 " , tester_label_to_check_heigh.size)
	
	var test_label_size = tester_label_to_check_heigh.size
	tester_label_to_check_heigh.queue_free()
	print(" do i have still the data test_label_size", test_label_size)
	current_labels_height = test_label_size.y
	
	
	
	
	var background_polygon_height = current_labels_height + (width_of_the_separators * 2)
	# 0.0, x,0, x,y, 0,y
	var background_polygon = Polygon2D.new()
	

	print(" possile multiplication value : ", multiplication_calculation)
	
		#array_of_points_for_selector_shape = PackedVector2Array([
			#selector_starting_point,  # Top-left
			#selector_point_b,   # Top-right
			#selector_ending_point,    # Bottom-right
			#selector_point_c    # Bottom-left
	var points_for_background = PackedVector2Array([
		Vector2(0, 0),
		Vector2(background_polygon_width, 0),
		Vector2(background_polygon_width, background_polygon_height),
		Vector2(0, background_polygon_height)
	])



		#body_polygon_selector = Polygon2D.new()
		#body_polygon_selector.name = "selector_polygon"
		#var points = array_of_points_for_selector_shape
		#body_polygon_selector.polygon = points
		#body_polygon_selector.color = Color(0.5, 0.8, 0.9, 0.22)
		#add_child(body_polygon_selector)
	background_polygon.name = "background_template"
	background_polygon.polygon = points_for_background
	background_polygon.color = Color.DIM_GRAY
	template_background_separators_container.add_child(background_polygon)
	
	# background is, it is now time for separators on top and bottom
	var top_separator = Polygon2D.new()
	
	var points_for_top_separator = PackedVector2Array([
		Vector2(0, 0),
		Vector2(background_polygon_width, 0),
		Vector2(background_polygon_width, width_of_the_separators),
		Vector2(0, width_of_the_separators)
	])
	top_separator.name = "top_separator"
	top_separator.polygon = points_for_top_separator
	top_separator.color = Color.LIGHT_GRAY
	template_background_separators_container.add_child(top_separator)
	
	# next value needed is 8 + label height
	# var background_polygon_height = current_labels_height + (width_of_the_separators * 2)
	# that one will be needed too
	var bottom_separator_height_top = current_labels_height + width_of_the_separators
	
	var bottom_separator = Polygon2D.new()
	var points_for_bottom_separator = PackedVector2Array([
		Vector2(0, bottom_separator_height_top),
		Vector2(background_polygon_width, bottom_separator_height_top),
		Vector2(background_polygon_width, background_polygon_height),
		Vector2(0, background_polygon_height)
	])
	bottom_separator.name = "bottom_separator"
	bottom_separator.polygon = points_for_bottom_separator
	bottom_separator.color = Color.LIGHT_GRAY
	template_background_separators_container.add_child(bottom_separator)
	# either start with separator once, then do for loop, or do for loop and after they are done, we are doing it again
	
	var horizontal_separators_name = "horizontal_separator_"
	var number_for_separator_name : int = 0
	
	var horizontal_separator_first = Polygon2D.new()
	var points_for_first_horizontal = PackedVector2Array([
		Vector2(0, 0 + width_of_the_separators),
		Vector2(width_of_the_separators, 0 + width_of_the_separators),
		Vector2(width_of_the_separators, bottom_separator_height_top),
		Vector2(0, background_polygon_height),
	])
	horizontal_separator_first.name = horizontal_separators_name + str(number_for_separator_name)
	horizontal_separator_first.polygon = points_for_first_horizontal
	horizontal_separator_first.color = Color.LIGHT_GRAY
	template_background_separators_container.add_child(horizontal_separator_first)
	number_for_separator_name +=1
	# top right of last horizontal lines, should be where label will be put in place too
	var last_horizontal_top_right = Vector2(width_of_the_separators, 0 + width_of_the_separators)
	var current_x_for_horizontal = width_of_the_separators
	# current x for horizontal, start is at 0, then we have it, plus we will have label
	
	
	
	# as here we touch them labels again, for the second time, we already could have.. calculated true needed size of it, oh
	# in previous for loop we can do that too.... hmm
	
	for labels in template_labels_dictionary:
		print(" for loop bitten, labels names to append? ", labels)
		var node_name_to_find = template_labels_dictionary[labels]["name"]
		var label_node_to_move = template_labels_container.get_node(node_name_to_find)
		print(" we gotten node, lets pray for miracle ", label_node_to_move)
		label_node_to_move.position = last_horizontal_top_right
		var current_font_size = label_node_to_move.get_theme_default_font_size()
		var new_font_size = int(current_font_size * multiplication_calculation)
		label_node_to_move.add_theme_font_size_override("font_size", new_font_size)
		
		var width_of_label = label_node_to_move.size.x
		#print(" dictionary width for label 1 ", template_labels_dictionary[labels]["width"])
		#print(" dictionary width for label x1", label_node_to_move.get_combined_minimum_size().x)
		template_labels_dictionary[labels]["width"] = template_labels_dictionary[labels]["width"] * multiplication_calculation
		#print(" dictionary width for label 2 ", template_labels_dictionary[labels]["width"])
		
		
		var width_to_add = template_labels_dictionary[labels]["width"]
		
		
		
		# as each label moved gracefully, now it is time to... add them separators, not each but one here in this scriptura part, few times, as many as needed
		var separator_horizontal_for = Polygon2D.new()
		var points_for_horizontal_for = PackedVector2Array([
			Vector2(last_horizontal_top_right.x + width_to_add, 0 + width_of_the_separators),
			Vector2(last_horizontal_top_right.x + width_to_add + width_of_the_separators, 0 + width_of_the_separators),
			Vector2(last_horizontal_top_right.x + width_to_add + width_of_the_separators, current_labels_height + width_of_the_separators),
			Vector2(last_horizontal_top_right.x + width_to_add, current_labels_height + width_of_the_separators)
		])
		separator_horizontal_for.name = horizontal_separators_name + str(number_for_separator_name)
		separator_horizontal_for.polygon = points_for_horizontal_for
		separator_horizontal_for.color = Color.LIGHT_GRAY
		template_background_separators_container.add_child(separator_horizontal_for)
		
		
		
		last_horizontal_top_right = Vector2(last_horizontal_top_right.x + width_to_add + width_of_the_separators, last_horizontal_top_right.y)
		number_for_separator_name +=1
		# 
	#print_tree_pretty()
	
	# it is crooked as we need to calculate the value of multiplication for all nodes fonts sizes to make them sizes alright
	#

	

func _input(event: InputEvent) -> void:
	#print("am i")
	if event is InputEventKey  and event.pressed:
		match event.keycode: 
			KEY_V:
				#print(" v was clicked ")
				_on_button_pressed()

func _on_button_pressed():
	# Show the explorer
	file_dialog.popup()
	

func _on_file_selected(path: String):
	# This 'path' is the string you are looking for
	file_chosen = path
	print("User picked this file: ", path)
	GlobalState.store_file_path(file_chosen)
	read_some_excell_with_colors(file_chosen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# first we will need to somehow whip out windows file explorer

func get_path_from_file_explorer():
	# open windows file explorer
	# get an string of path from it
	# hopefully it also will have... file at the end with its extension
	pass
	

# the data of excel being.. read fully, should probably also be stored in some kind of autoload var
# so i can access it from any other script as needed

var excel_data

func load_excel_file(path_of_file):
	# already written in tree scriptura
	# so just copy paste later
	pass
	
	
	


func read_some_excell_with_colors(path_to_xslx):
	var excel = ExcelReaderColor.ExcelFile.open(path_to_xslx)
	var workbook = excel.get_workbook()  # No parameters!
	print("Sheet: ", workbook.get_sheet_names())
	var singular_thingy = workbook.get_sheet_names()
	var number_thingy : int = 0
	var checker_state : bool = false
	var value_at_checker : int = -1
	var whole_sheet_data
	
	
	for page in singular_thingy:
		print(" sheet ", number_thingy ," name ", page)
		# we kinda look for "Produktionsstückliste"
		# in here
		
		
		
		
		# might be a problem, if a list is named differently
		var value_we_look_for = "Produktionsstückliste"
		
		
		
		
		
		
		
		if value_we_look_for == page:
			print(" it was found , number : ", number_thingy)
			checker_state = true
			value_at_checker = number_thingy
		
		number_thingy +=1
		
	# first we will probably need a way to figure out if the 0 is what we want, as simple accidental movement of mouse could break it all
	# just moving rectangle from left to right could break it, so i guess we will need to find which position of an array will be page we need
	# write with keyboard or selector of possible pages could help
	
	var array_from_refcount = []
	array_from_refcount.assign(singular_thingy)
	
	if checker_state == true:
		print(" checker is still there, value copied ", value_at_checker)
		var value_to_find = array_from_refcount.pop_at(value_at_checker)
		print("that value is : ", value_to_find)
			#var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
			#print(JSON.stringify(sheet_data["name"], "\t"))
			#print(JSON.stringify(sheet_data["data"], "\t"))
		whole_sheet_data = workbook.get_sheet_by_name(value_to_find)
		#print(JSON.stringify(whole_sheet_data["name"], "\t"))
		#print(JSON.stringify(whole_sheet_data["data"], "\t"))
		
		#var data_dict = JSON.parse_string(whole_sheet_data["data"])
		
		GlobalState.save_spreadsheet(whole_sheet_data)
		# data found, even stored, next point would be to check columns positions in loaded file
		check_columns_position_in_loaded_file()
		
	# nothing was found
	else:
		print(" checker is still there, value copied ", value_at_checker)
		# lets just use 0 one
		var value_to_find = array_from_refcount.pop_at(0)
		print("that value is : ", value_to_find)
			#var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
			#print(JSON.stringify(sheet_data["name"], "\t"))
			#print(JSON.stringify(sheet_data["data"], "\t"))
		whole_sheet_data = workbook.get_sheet_by_name(value_to_find)
		#print(JSON.stringify(whole_sheet_data["name"], "\t"))
		#print(JSON.stringify(whole_sheet_data["data"], "\t"))
		
		#var data_dict = JSON.parse_string(whole_sheet_data["data"])
		
		GlobalState.save_spreadsheet(whole_sheet_data)
		# data found, even stored, next point would be to check columns positions in loaded file
		check_columns_position_in_loaded_file()
	# if it failed, another method will be needed
	

# as first it is being read, as what pages or whatever there is in file
# we shall also choose which one, probably first one

# [Stufe][Posn][Material][Anz.][Menge][ME][Abmess_1][ME][Abmes_2][Bezeichnung.............................][Zeinr]

#func string_checker_for_exact_positions():
	## that function shall happen after entire the file/ maybe folder was selected
	#
	#var string_first = "Stufe"
	## finds from which point, looked for symbol/word etc starts, so ...Stufe = 3, Stufe = 0
	## n means case insensitive, so stufe == Stufe
	#var output_string = string_first.findn("stufe")
	## count how many times a string is inside an string
	## word looked for, from which position of the string, from beginning so 0, how many times it should be in string, 1, it being it here at all is all we need
	#var output_string_count = string_first.countn("stufe", 0, 1)
	#
	## the needed for loop
	## shall look through entire Array of all columns
	## as singular column name might.. happen twice,
	## "a", "b", "a"
	## so it should be dual for for loop, for columns we are looking for, and inside that loop, another for loop
	## that will have for columns we appended from excell file, each time we do find what we are looking for
	## that singular thing needs to be... deleted i guess from that array so we wont repeat it
	## bsearch(value) for array,
	#var array_find = ["a", "b", "c", "d"]
	#var array_find_2 = ["f", "e", "a", "b", "c", "d"]
	#print("test array find for loop : ", array_find_2)
	#array_find_2.sort()
	#print("test array find for loop : ", array_find_2)
	#var value_to_be_used = array_find_2.bsearch("f")
	#print(" array bsearch value ", value_to_be_used)
	#print("test array find for loop : ", array_find_2)
	#var take_it = array_find_2.get(value_to_be_used)
	#print("test array find for loop : ", array_find_2, " and new var : ", take_it)
	#var do_take_it = array_find_2.pop_at(value_to_be_used)
	#print("test array find for loop : ", array_find_2)
	#print(" do we still have it ", template_row_words)
	
	
	
func check_columns_position_in_loaded_file():
	
	var the_spreadsheet = GlobalState.load_spreadsheet()
	#var data_dict = JSON.parse_string(the_spreadsheet["data"])
	var spreadsheet_info = GlobalState.load_stored_info()
	# as i dont wanna touch fully clean copy paste of the spreadsheet, i wanna copy paste keys and values to make it a little bit more bearable to use and automate
	# array here is just as template to translate int of keys we have for dictionary row columns
	# into what it would been as template start from 0/1
	# lets start from 0 as its first number
	# so a key shall be named as number, and it shall be an dictionary
	
	
	
	print("second load from global state, dictionary file")
	
	#print(JSON.stringify(the_spreadsheet["name"], "\t"))
	#print(JSON.stringify(the_spreadsheet["data"][1], "\t"))
	var int_for_number_key : int = 0
	for column_word_to_find in template_row_words:
		var int_for_accessing_keys : int = 1
		
		
		## here some bool starting at false
		
		# now as it is going through it, we can predetermine columns understanding of each row, which is [][][here] as an int number
		# so again in that first for loop, we must... make another for loop, to check each of these columns
		for column_to_check in the_spreadsheet["data"][1]:
			
			print(" the data from within ", the_spreadsheet["data"][1][int_for_accessing_keys]["value"])
			var current_word_from_parsed_xlsx = the_spreadsheet["data"][1][int_for_accessing_keys]["value"]
			
			
			
			## needs a checker, and inputer of null data information, column not found, to make sure 
			## no bad data floods in, in case of missing some midddle collumn in file, it being differently setup
			## so only correct ones will be read, the most important ones being, two first ones informing about steps
			## and another are names of files and descriptions
			## possible just info of true false
			
			
			
			# word looked for, from which position of the string, from beginning so 0, how many times it should be in string, 1, it being it here at all is all we need
			var output_string_count = current_word_from_parsed_xlsx.countn(column_word_to_find)
			print(" the string checker output ", output_string_count, " looking for word : " , column_word_to_find)
			
			
			# if can work and not, depends on mercy of the same copy paste
			if output_string_count != 0:
				print(" it was found")
				
				## if it was found it shall change it to true
				
				spreadsheet_info[int_for_number_key] = {
					"name" = current_word_from_parsed_xlsx,
					"number" = int_for_accessing_keys
					}
				# umm i found it, and i wanna go back to previous loop, break.. will send me back to current for loop? or previous
				#int_for_accessing_keys +=1
				break
				
			int_for_accessing_keys +=1
			
		int_for_number_key +=1
		## here is the second for loop that finished, so we are back at the end of the first for loop
		
		## that means we can check if something is true, or false, to know if the value was not found/null
		
	print(" for loops ended, check info dictio : ", spreadsheet_info)
	GlobalState.save_dict_info(spreadsheet_info)
		
		
	generate_file_row()
	# bsearch, pop_at that value
	
	# var sheet_data = workbook.get_sheet_by_name("Produktionsstückliste")
	# print(JSON.stringify(sheet_data["name"], "\t"))
	# print(JSON.stringify(sheet_data["data"], "\t"))

# after getting whole file
# what is needed is to split the data on separate cathegories





#
#
#
#var template_row_words : Array = ["Stufe", "Posn", "Material", "Anz.", "Menge", "ME", "Abmess_1", "ME", "Abmes_2", "Bezeichnung", "Zeinr"]
#
#var template_row_name : String = "template_row"
#var template_label_name : String = "template_label_"
#var template_labels_dictionary : Dictionary = {}
#var current_labels_height : float = 0.0
#var all_labels_width : float = 0.0
#
#var template_background_separators_container
#var template_labels_container

var file_row_words

# to rewrite into using the loaded file row of columns with correct positions
var file_row_name : String = "file_row"
var file_label_name : String = "file_label_"
var file_labels_dictionary : Dictionary = {}
var current_file_row_labels_height : float = 0.0
var all_file_labels_width : float = 0.0

var file_background_separators_container
var file_labels_container


func generate_file_row():
	#[Stufe][Posn][Material][Anz.][Menge][ME][Abmess_1][ME][Abmes_2][Bezeichnung.............................][Zeinr]

	var number_to_add : int = 0
	
	file_background_separators_container = Node2D.new()
	file_background_separators_container.name = "file_row_separators_container"
	add_child(file_background_separators_container)
	
	file_labels_container = Node2D.new()
	file_labels_container.name = file_row_name
	add_child(file_labels_container)
	
	file_row_words = GlobalState.load_stored_info()
	
	#file_row_words[num]["name"]
	
	for column_name in file_row_words:
		print(" should been generating new row of what we found out : ", file_row_words[column_name]["name"])
		
		var name_to_set = file_row_words[column_name]["name"]
		
		var label_to_generate = Label.new()
		var curr_name_to_set = file_label_name + str(number_to_add)
		label_to_generate.name = curr_name_to_set
		label_to_generate.text = name_to_set
		file_labels_container.add_child(label_to_generate)
		var width_of_label = label_to_generate.size.x
		print(" label width is ", width_of_label)
		
		if file_labels_dictionary.has(column_name):
			column_name = column_name + "_0"
		
		file_labels_dictionary[column_name] = {
			"width": width_of_label,
			"name": curr_name_to_set
		}
		number_to_add +=1
		all_file_labels_width = all_file_labels_width + width_of_label
		
	var first_label_node = file_labels_container.get_child(0)
	current_file_row_labels_height = first_label_node.size.y
	
	print(" first label_ node ", first_label_node, " its height : ", current_file_row_labels_height)
	draw_grid_for_file_row()
# var template_labels_dictionary : Dictionary = {}
# it will need to store keys of each label, their width



#var current_file_row_labels_height : float = 0.0
#var all_file_labels_width : float = 0.0


# draw grid with polygon2d
# 15 parts for 11 blocks/labels
# less than making 2 polygons for each
# first we will need screen width

#var width_of_the_separators : float = 3.69

# width of separators being 8, how do i even wanna.... paint them i guess,
# the two main lines on top and bottom, would be, whole screen size
# in width, its height would be just 8
# then we have label height, probably label height depends if it will change
# will need current lenght for the top left corner of each separator
# with that we add that 8 to make top right corner, which will be new beginning for the label, next label
# height of the label will.. add to y, to make 3rd point
# for last point we will just - 8 to make it
# height = current_labels_height


func draw_grid_for_file_row():
	
	
	#var current_file_row_labels_height : float = 0.0
	#var all_file_labels_width : float = 0.0
	
	
	var startup_viewport_size = get_viewport().size
	print(" the size of viewport ", startup_viewport_size, " umm dictionary : ", file_labels_dictionary)
	# startup_viewport_size.x , whole size of the screen
	
	var background_polygon_width = startup_viewport_size.x
	var width_for_calculation = background_polygon_width - (width_of_the_separators * 12)
	var multiplication_calculation = width_for_calculation / all_file_labels_width
	
	var tester_label_to_check_heigh = Label.new()
	tester_label_to_check_heigh.text = "Test"
	add_child(tester_label_to_check_heigh)
	var current_fs = tester_label_to_check_heigh.get_theme_default_font_size()
	print(" test font size 1 " , tester_label_to_check_heigh.size)
	var new_fs = int(current_fs * multiplication_calculation)
	tester_label_to_check_heigh.add_theme_font_size_override("font_size", new_fs)
	print(" test font size 2 " , tester_label_to_check_heigh.size)
	
	var test_label_size = tester_label_to_check_heigh.size
	tester_label_to_check_heigh.queue_free()
	print(" do i have still the data test_label_size", test_label_size)
	current_file_row_labels_height = test_label_size.y
	
	
	
	
	var background_polygon_height = current_file_row_labels_height + (width_of_the_separators * 2)
	# 0.0, x,0, x,y, 0,y
	var background_polygon = Polygon2D.new()
	

	print(" possile multiplication value : ", multiplication_calculation)
	
		#array_of_points_for_selector_shape = PackedVector2Array([
			#selector_starting_point,  # Top-left
			#selector_point_b,   # Top-right
			#selector_ending_point,    # Bottom-right
			#selector_point_c    # Bottom-left
	var points_for_background = PackedVector2Array([
		Vector2(0, 0),
		Vector2(background_polygon_width, 0),
		Vector2(background_polygon_width, background_polygon_height),
		Vector2(0, background_polygon_height)
	])



		#body_polygon_selector = Polygon2D.new()
		#body_polygon_selector.name = "selector_polygon"
		#var points = array_of_points_for_selector_shape
		#body_polygon_selector.polygon = points
		#body_polygon_selector.color = Color(0.5, 0.8, 0.9, 0.22)
		#add_child(body_polygon_selector)
	background_polygon.name = "background_template"
	background_polygon.polygon = points_for_background
	background_polygon.color = Color.DIM_GRAY
	file_background_separators_container.add_child(background_polygon)
	
	# background is, it is now time for separators on top and bottom
	var top_separator = Polygon2D.new()
	
	var points_for_top_separator = PackedVector2Array([
		Vector2(0, 0),
		Vector2(background_polygon_width, 0),
		Vector2(background_polygon_width, width_of_the_separators),
		Vector2(0, width_of_the_separators)
	])
	top_separator.name = "top_separator"
	top_separator.polygon = points_for_top_separator
	top_separator.color = Color.LIGHT_GRAY
	file_background_separators_container.add_child(top_separator)
	
	# next value needed is 8 + label height
	# var background_polygon_height = current_labels_height + (width_of_the_separators * 2)
	# that one will be needed too
	var bottom_separator_height_top = current_file_row_labels_height + width_of_the_separators
	
	var bottom_separator = Polygon2D.new()
	var points_for_bottom_separator = PackedVector2Array([
		Vector2(0, bottom_separator_height_top),
		Vector2(background_polygon_width, bottom_separator_height_top),
		Vector2(background_polygon_width, background_polygon_height),
		Vector2(0, background_polygon_height)
	])
	bottom_separator.name = "bottom_separator"
	bottom_separator.polygon = points_for_bottom_separator
	bottom_separator.color = Color.LIGHT_GRAY
	file_background_separators_container.add_child(bottom_separator)
	# either start with separator once, then do for loop, or do for loop and after they are done, we are doing it again
	
	var horizontal_separators_name = "horizontal_separator_"
	var number_for_separator_name : int = 0
	
	var horizontal_separator_first = Polygon2D.new()
	var points_for_first_horizontal = PackedVector2Array([
		Vector2(0, 0 + width_of_the_separators),
		Vector2(width_of_the_separators, 0 + width_of_the_separators),
		Vector2(width_of_the_separators, bottom_separator_height_top),
		Vector2(0, background_polygon_height),
	])
	horizontal_separator_first.name = horizontal_separators_name + str(number_for_separator_name)
	horizontal_separator_first.polygon = points_for_first_horizontal
	horizontal_separator_first.color = Color.LIGHT_GRAY
	file_background_separators_container.add_child(horizontal_separator_first)
	number_for_separator_name +=1
	# top right of last horizontal lines, should be where label will be put in place too
	var last_horizontal_top_right = Vector2(width_of_the_separators, 0 + width_of_the_separators)
	var current_x_for_horizontal = width_of_the_separators
	# current x for horizontal, start is at 0, then we have it, plus we will have label
	
	
	
	# as here we touch them labels again, for the second time, we already could have.. calculated true needed size of it, oh
	# in previous for loop we can do that too.... hmm
	
	for labels in file_labels_dictionary:
		print(" for loop bitten, labels names to append? ", labels)
		var node_name_to_find = file_labels_dictionary[labels]["name"]
		var label_node_to_move = file_labels_container.get_node(node_name_to_find)
		print(" we gotten node, lets pray for miracle ", label_node_to_move)
		label_node_to_move.position = last_horizontal_top_right
		var current_font_size = label_node_to_move.get_theme_default_font_size()
		var new_font_size = int(current_font_size * multiplication_calculation)
		label_node_to_move.add_theme_font_size_override("font_size", new_font_size)
		
		var width_of_label = label_node_to_move.size.x
		#print(" dictionary width for label 1 ", template_labels_dictionary[labels]["width"])
		#print(" dictionary width for label x1", label_node_to_move.get_combined_minimum_size().x)
		file_labels_dictionary[labels]["width"] = file_labels_dictionary[labels]["width"] * multiplication_calculation
		#print(" dictionary width for label 2 ", template_labels_dictionary[labels]["width"])
		
		
		var width_to_add = file_labels_dictionary[labels]["width"]
		
		
		
		# as each label moved gracefully, now it is time to... add them separators, not each but one here in this scriptura part, few times, as many as needed
		var separator_horizontal_for = Polygon2D.new()
		var points_for_horizontal_for = PackedVector2Array([
			Vector2(last_horizontal_top_right.x + width_to_add, 0 + width_of_the_separators),
			Vector2(last_horizontal_top_right.x + width_to_add + width_of_the_separators, 0 + width_of_the_separators),
			Vector2(last_horizontal_top_right.x + width_to_add + width_of_the_separators, current_file_row_labels_height + width_of_the_separators),
			Vector2(last_horizontal_top_right.x + width_to_add, current_file_row_labels_height + width_of_the_separators)
		])
		separator_horizontal_for.name = horizontal_separators_name + str(number_for_separator_name)
		separator_horizontal_for.polygon = points_for_horizontal_for
		separator_horizontal_for.color = Color.LIGHT_GRAY
		file_background_separators_container.add_child(separator_horizontal_for)
		
		
		
		last_horizontal_top_right = Vector2(last_horizontal_top_right.x + width_to_add + width_of_the_separators, last_horizontal_top_right.y)
		number_for_separator_name +=1
		# 
#var file_background_separators_container
#var file_labels_container


	file_background_separators_container.global_position = Vector2(file_background_separators_container.global_position.x, file_background_separators_container.global_position.y + 333)
	file_labels_container.global_position = Vector2(file_labels_container.global_position.x, file_labels_container.global_position.y + 333)

	
	#print_tree_pretty()
	print(" the second row finished showing, time to arrange cells")
	sort_spreadsheet()





































var first_row : Dictionary = {}
# that one will have keys as correct way? maybe 0 will have simple data_name_0 ... data_name_11 and just value of what we see as it should be
# the another key will have position of that key for xlsl
var array_of_different_colors : Array = []
var bg_color_dict : Dictionary = {}
# here i think we will either just count them, maybe arrange them in 2d grid


func sort_spreadsheet():
	print()
#	print_orphan_nodes()
	# first access the parsed and loaded dictionary
	# 
	var loaded_spreadsheet = GlobalState.load_spreadsheet()
	# as there could be additional columns that could output different proper values for an order that was missing pieces, parts numbers
	# some additional columns, might need to be parsed, for later fine tuning
	# that shall be done in previous function, where the rows are checked
	# or maybe it for loops for amounts needed, and again for loops for all in loaded each time so more
	# proper way would be to make it a new function
	check_every_column(loaded_spreadsheet)
	

func check_every_column(spreadsheet_to_check):
	print()
	# we get dictionary, keys are named with numbers, and first number is 1
	# as its row 1, then columns, also from number 1, this will need int
	
	# it can check every or it can just check specified amount
	var starter_int : int = 1
	#print(spreadsheet_to_check)
	#print(" possibility : ", spreadsheet_to_check["data"][1][1])
	
	# that one seem not correct even if working
	# checking each column, and using that number of each row to check each column name
	# might need change, as there could be just few rows
	# just added key for first row only, should be better
	for possible_values in spreadsheet_to_check["data"][1]:
		if spreadsheet_to_check["data"][possible_values].has(possible_values):
			#print(" possibility : ", spreadsheet_to_check["data"][1][possible_values])
			if spreadsheet_to_check["data"][1][possible_values].has("value"):
				first_row[spreadsheet_to_check["data"][1][possible_values]["value"]] = {
					"number": starter_int
				
			}
			# a check for color can take place here, or in next loop to make it faster
			#print()
		starter_int +=1
	#print(first_row)
	var val_to_check : int = -1
	for check_for_first_bg_color in spreadsheet_to_check["data"][1]:
		
		if spreadsheet_to_check["data"][1][check_for_first_bg_color]["style"]["has_bg"] == true:
		
			val_to_check = check_for_first_bg_color
			break
	
	# another think would be figuring out stufe column number, which will be most likel 1 or 2, most of the time 1
	var stufe_number : int = 0
	for all_posib_columns in spreadsheet_to_check["data"][1]:
		if spreadsheet_to_check["data"][1][all_posib_columns].has("value"):
			#if spreadsheet_to_check["data"][1][all_posib_columns]["value"] == "Stufe":
				# that one is possibly always written correctly, but i think i seen it once as
				# Stufe., checking it with the begins with, first to lower
			#	stufe_number
			var currently_checked_value = spreadsheet_to_check["data"][1][all_posib_columns]["value"]
			#var looked_for_string = "stufe"
			if currently_checked_value.matchn("*stufe*"):
				print("stufe row been found")
				stufe_number = all_posib_columns
				
	print(" the bg check : ", val_to_check, " next stuf numb : ", stufe_number)
	#if not val_to_check == -1:
	# background color needs to be separately checked, as one row has just one 
	
	
	# now beside knowing where, i also will need to know what
	var material_row
	
	for material_rows in spreadsheet_to_check["data"][1]:
		var val_check_mat = spreadsheet_to_check["data"][1][material_rows]["value"] 
		
		if val_check_mat.matchn("*material*"):
			print(" material row been found")
			material_row = material_rows
	
	
	
	
	var last_val : int = 0
	var key_1
	var key_2
	var key_3
	var key_4
	var key_5
	var key_6
	var key_7
	var tree_dict : Dictionary = {}
	
	# to start counting as creating
	var col_1: int = 0
	var col_2: int = 0
	var col_3: int = 0
	var col_4: int = 0
	var col_5: int = 0
	var col_6: int = 0
	var col_7: int = 0
	
	var max_found_val : int = 0
	
	tree_dict = {
		"branches": {},
		"info": {},
		"all_branches": {}
	}
	
	var number_to_add: int = 0
	
	for color_of_row in spreadsheet_to_check["data"]:
		#if spreadsheet_to_check["data"][color_of_row][1].has("bg_color"):
		# so number can be a problem too, as columns can be added at start, in middle or ends, it can change
		# there will be a need to figure out best way to set number to even check for background color
		#  row color is : { "value": "l.p.", "style": { "bold": false, "font_color": "FF000000", "bg_color": "FFFFFF", "has_bg": false } }
		
		# if can make change to current main "branch", which will have its own tree maybe
		#print(" check ", spreadsheet_to_check["data"][color_of_row][val_to_check])
		
		# if wont help as here we just check if it had background
		# as its .1, ..2, ...3, and so on, we check for last string character
		# then it needs to be changed into int
		var current_value_for_nesting = spreadsheet_to_check["data"][color_of_row][val_to_check]["value"]
		# so i have the value
		#print(" test the last number ", current_value_for_nesting.right(1))
		var cur_val_int = int(current_value_for_nesting.right(1))
		
		if max_found_val < cur_val_int:
			max_found_val = cur_val_int
		
		
		if spreadsheet_to_check["data"][color_of_row][material_row]["value"] is float:
			#print("it is a float")
			spreadsheet_to_check["data"][color_of_row][material_row]["value"] = int(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
			spreadsheet_to_check["data"][color_of_row][material_row]["value"] = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
		
		var val = spreadsheet_to_check["data"][color_of_row][material_row]["value"]
		var new_val
		
		if tree_dict["all_branches"].has(val):
			print(" it existed already, the name will need a change ", number_to_add)
			var add_to_name = "_N" + str(number_to_add)
			new_val = val+add_to_name
			tree_dict["all_branches"][new_val] = val
			val = new_val
			spreadsheet_to_check["data"][color_of_row][material_row]["value"] = val
			number_to_add+=1
		else:
			tree_dict["all_branches"][val] = val
		
		
		match cur_val_int:
			1:
				# as we go in, we shall first set key here
				key_1 = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
				# material column shall tell us the name for the key
				# as it changes it makes new keys
				col_1 +=1
				
				#if tree_dict["branches"].has(key_1):
				#	print("it had it already")
				
				tree_dict["branches"][key_1] = {
					"entry_key" = color_of_row,
					"position" = Vector2(0.0,0.0),
					"name" = key_1
				}
			2:
				key_2 = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
				col_2 +=1
				tree_dict["branches"][key_1][key_2] = {
					"entry_key" = color_of_row,
					"position" = Vector2(0.0,0.0),
					"name" = key_2,
					"key_1" = key_1
				}
			3:
				key_3 = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
				col_3 +=1
				tree_dict["branches"][key_1][key_2][key_3] = {
					"entry_key" = color_of_row,
					"position" = Vector2(0.0,0.0),
					"name" = key_3,
					"key_1" = key_1,
					"key_2" = key_2
				}
			4:
				key_4 = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
				col_4 +=1
				tree_dict["branches"][key_1][key_2][key_3][key_4] = {
					"entry_key" = color_of_row,
					"position" = Vector2(0.0,0.0),
					"name" = key_4,
					"key_1" = key_1,
					"key_2" = key_2,
					"key_3" = key_3
				}
			5:
				key_5 = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
				col_5 +=1
				tree_dict["branches"][key_1][key_2][key_3][key_4][key_5] = {
					"entry_key" = color_of_row,
					"position" = Vector2(0.0,0.0),
					"name" = key_5,
					"key_1" = key_1,
					"key_2" = key_2,
					"key_3" = key_3,
					"key_4" = key_4
				}
			6:
				key_6 = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
				col_6 +=1
				tree_dict["branches"][key_1][key_2][key_3][key_4][key_5][key_6] = {
					"entry_key" = color_of_row,
					"position" = Vector2(0.0,0.0),
					"name" = key_6,
					"key_1" = key_1,
					"key_2" = key_2,
					"key_3" = key_3,
					"key_4" = key_4,
					"key_5" = key_5
				}
			7:
				key_7 = str(spreadsheet_to_check["data"][color_of_row][material_row]["value"])
				col_7 +=1
				tree_dict["branches"][key_1][key_2][key_3][key_4][key_5][key_6][key_7] = {
					"entry_key" = color_of_row,
					"position" = Vector2(0.0,0.0),
					"name" = key_7,
					"key_1" = key_1,
					"key_2" = key_2,
					"key_3" = key_3,
					"key_4" = key_4,
					"key_5" = key_5,
					"key_6" = key_6
				}
		
		#if spreadsheet_to_check["data"][color_of_row][val_to_check]["Value"] == true:
			
			#print(" row color is : ", spreadsheet_to_check["data"][color_of_row][val_to_check]["style"]) #["style"]["bg_color"]
			# these are the main ones, where color changes
			
			
			# here we shall sort it all into possible tree, the missig part will be
			# a visualization of whatever we wanted to see on the tree	
				
	# looks like dictionary created as i written it, not suprising
	
	# now we would need to also check which column has the most branches
	
	var max_amount_in_column = [col_1, col_2, col_3, col_4, col_5, col_6].max()
	
	tree_dict["info"]={
		"amounts" = {
			"col_1" = col_1,
			"col_2" = col_2,
			"col_3" = col_3,
			"col_4" = col_4,
			"col_5" = col_5,
			"col_6" = col_6,
			"max" = max_found_val,
			"max_col" = max_amount_in_column
		}
	}
	
	GlobalState.save_tree_dict(tree_dict)
	print("here")
	print(tree_dict["info"])
	make_tree_dictionary(spreadsheet_to_check)

# we got colors, first row all values 
# global state func save_tree_dict(value):


# each part having a tree branch, to arrange them all into a scene, first each tree will need to be arranged onto scene into their positions,
# after each part is completely arranged, they will need to be repositioned so every fits onto the scene
# from left to right,

var tree_dictionary : Dictionary = {}

# kinda left and right connections of everything, is already there, i would say it shall go from left to right
# each time a new one is being added to the left, under whatever was somewhere, to the left of it
# then it will need to store information of each col height
# the center point will need to be calculated there, after everything in that column was positioned
# each branch shall also have info about amounts already
# get_branch_width()
# get_branch_height()
var multiplier : float = 3.69
var current_y_offset : float = 0.0 # Track global vertical growth

func make_tree_dictionary(spreadsheet):
	var branch_width = GlobalState.get_branch_width()
	var branch_height = GlobalState.get_branch_height()
	var v_spacing = branch_height * multiplier
	var h_spacing = branch_width * multiplier
	
	var tree_dictio = GlobalState.load_tree_dict()
	current_y_offset = 0.0 # Reset for new calculation
	
	# Recursive function: Returns the Y position assigned to the node
	var position_node = func(node: Dictionary, col: int, self_ref):
		# 1. Collect valid child branches
		var children = []
		for key in node:
			if typeof(node[key]) == TYPE_DICTIONARY and node[key].has("entry_key"):
				children.append(node[key])
		
		var x_pos = col * h_spacing
		var final_y = 0.0
		
		if children.size() == 0:
			# LEAF: This is an end-point. Place it and move the cursor down.
			final_y = current_y_offset
			current_y_offset += v_spacing
		else:
			# BRANCH: Position all children first (Bottom-Up)
			var child_y_positions = []
			for child in children:
				var c_y = self_ref.call(child, col + 1, self_ref)
				child_y_positions.append(c_y)
			
			# Center this branch between its first and last child
			var min_y = child_y_positions[0]
			var max_y = child_y_positions[-1]
			final_y = (min_y + max_y) / 2.0
		
		node["position"] = Vector2(x_pos, final_y)
		return final_y

	# 2. Process all top-level roots
	if tree_dictio.has("branches"):
		for key in tree_dictio["branches"]:
			var root_node = tree_dictio["branches"][key]
			position_node.call(root_node, 0, position_node)

	GlobalState.save_tree_dict(tree_dictio)
	get_tree().change_scene_to_file("res://scenes/tree_branch.tscn")



func make_tree_dictionary_hmm(spreadsheet):
	#print()
	
	# first shot for checking which are the main ones, after the main one appears, until next will, it shall be worked on
	# keys should be as tree[main_branch][sub_branch] like tree[..2, posn numb][its sub branches so from ...3, its posn numb]
	# as for loops go on, its number of row is going up, the stufe list will need its own int
	
	var branch_width = GlobalState.get_branch_width()
	var branch_height = GlobalState.get_branch_height()
	
	var tree_dictio = GlobalState.load_tree_dict()
	var key_1
	var key_2
	var key_3
	var key_4
	var key_5
	var key_6
	var key_7
	
	var columns_info: Dictionary = {}
	
	
	var current_stufe_numb : int = 1
	for first_key in tree_dictio["branches"]:
		#print()
		#
		# number of which one it is in said column
		# number which one it is, currently in that column from that branch
		
		#it might need to be for loop of for loops
		for second_key in tree_dictio["branches"][first_key]:
			
			# and up to 7th key so far
			# as we go deeper its possible that we need to check if that wan even has something in it to go into next for loop, as something might
			# be up to 5th column, something to 7th one
			
			for third_key in tree_dictio["branches"][first_key][second_key]:
				
				
				for fourth_key in tree_dictio["branches"][first_key][second_key][third_key]:
					
					
					for fifth_key in tree_dictio["branches"][first_key][second_key][third_key][fourth_key]:
						
						
						for sixth_key in tree_dictio["branches"][first_key][second_key][third_key][fourth_key][fifth_key]:
							
							
							
							for seventh_key in tree_dictio["branches"][first_key][second_key][third_key][fourth_key][fifth_key][sixth_key]:
								
								print
		
		
		
	



# files have been loaded, columns have been understood
# the next step will be loading entire thing as tree
# getting different colors of lines found
# checking if the line is in bold
# then based on main lines that are colored, bolded, it will have its own sub lines, that connects to it
# the sub lines are divided by two, lines of parts that will connect it, and lines of parts that are similar to main one, difference of screws, bolts and cutouts
# 
