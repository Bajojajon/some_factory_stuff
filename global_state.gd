extends Node



# an autoload can store values between scenes and scripts, to share the data between
# 
var stored_spreadsheet
var spreadsheet_information : Dictionary = {}
# main keys being what is grayed out, inside of them their parts pieces
var tree_dictionary : Dictionary = {}


var width_of_branch: float = 100.0
var height_of_branch: float = 50.0

var path_to_file: String = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_branch_width():
	return width_of_branch

func get_branch_height():
	return height_of_branch



func save_spreadsheet(value):
	stored_spreadsheet = value

func load_spreadsheet():
	return stored_spreadsheet


func save_dict_info(value):
	spreadsheet_information = value

func load_stored_info():
	return spreadsheet_information


func save_tree_dict(value):
	tree_dictionary = value

func load_tree_dict():
	return tree_dictionary


func store_file_path(val):
	path_to_file = val
	
func load_file_path():
	return path_to_file
