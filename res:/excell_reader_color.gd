# Excel 文件读取器 - 颜色增强版 | Excel Reader - Color Enhanced
# Focus: Accuracy in detecting any background color difference.
class_name ExcelReaderColor extends RefCounted

class ExcelFile:
	extends RefCounted
	
	var _zip_reader: ZIPReader
	var _workbook: ExcelWorkbook = null
	var _path: String
	
	func _init(path: String):
		_path = path
		_zip_reader = ZIPReader.new()
		if _zip_reader.open(_path) != OK:
			push_error("Excel file failed to open: " + _path)
		_zip_reader.close()
		
	func get_workbook() -> ExcelWorkbook:
		_zip_reader.open(_path)
		if not _workbook:
			_workbook = ExcelWorkbook.new(_zip_reader)
		_zip_reader.close()
		return _workbook
	
	static func open(path: String) -> ExcelFile:
		return ExcelFile.new(path) if FileAccess.file_exists(path) else null

class ExcelWorkbook:
	extends RefCounted
	
	var _zip: ZIPReader
	var _sheets: Array[ExcelSheet] = []
	var _shared_strings: PackedStringArray = []
	var _styles: Array[Dictionary] = [] 
	
	func _init(zip: ZIPReader):
		_zip = zip
		_load_shared_strings()
		_load_styles() 
		_discover_sheets()
	
	func get_sheet_names() -> PackedStringArray:
		var names: PackedStringArray = []
		for sheet in _sheets:
			names.append(sheet.name)
		return names
	
	func get_sheet_by_name(sheet_name: String) -> Dictionary:
		var target_name = sheet_name.replace(" ", "").to_lower()
		for sheet in _sheets:
			if sheet.normalized_name == target_name:
				return {
					"name": sheet.name,
					"data": _convert_to_continuous_grid(sheet.rows)
				}
		return {}

	# --------- Style Loading (The "Color Detector") ---------
	
	func _load_styles():
		if not _zip.file_exists("xl/styles.xml"):
			return
		
		var data = _zip.read_file("xl/styles.xml")
		var parser = XMLParser.new()
		parser.open_buffer(data)
		
		var fonts: Array[Dictionary] = []
		var fills: Array[Dictionary] = []
		var cell_xfs: Array[Dictionary] = []
		
		var in_fonts = false
		var in_fills = false
		var in_cellxfs = false
		var current_font = {}
		var current_fill = {}
		
		while parser.read() == OK:
			match parser.get_node_type():
				XMLParser.NODE_ELEMENT:
					var node = parser.get_node_name().to_lower()
					match node:
						"fonts": in_fonts = true
						"fills": in_fills = true
						"cellxfs": in_cellxfs = true
						"font":
							if in_fonts: current_font = {"bold": false, "size": 11, "color": "FF000000"}
						"b":
							if in_fonts: current_font["bold"] = true
						"sz":
							if in_fonts: current_font["size"] = _get_attribute(parser, "val", "11").to_int()
						"color":
							var rgb = _get_attribute(parser, "rgb", "")
							if rgb != "":
								if in_fonts: current_font["color"] = rgb
								elif in_fills: current_fill["color"] = rgb
						"fgcolor":
							if in_fills:
								var rgb = _get_attribute(parser, "rgb", "")
								var indexed = _get_attribute(parser, "indexed", "")
								var theme = _get_attribute(parser, "theme", "")
								var tint = _get_attribute(parser, "tint", "0")

								if rgb != "":
									current_fill["color"] = rgb
								elif indexed != "":
									current_fill["indexed"] = indexed.to_int()
								elif theme != "":
									current_fill["theme"] = theme.to_int()
									current_fill["tint"] = tint.to_float()
						"patternfill":
							if in_fills:
								var pattern = _get_attribute(parser, "patternType", "none")
								current_fill = {
									"pattern": pattern,
									"color": "",
									"indexed": -1,
									"theme": -1,
									"tint": 0.0
								}
						"xf":
							if in_cellxfs:
								cell_xfs.append({
									"fontId": _get_attribute(parser, "fontId", "0").to_int(),
									"fillId": _get_attribute(parser, "fillId", "0").to_int()
								})
				
				XMLParser.NODE_ELEMENT_END:
					var node = parser.get_node_name().to_lower()
					if node == "font" and current_font:
						fonts.append(current_font.duplicate())
					elif node == "fill" and current_fill:
						fills.append(current_fill.duplicate())
					elif node == "fonts": in_fonts = false
					elif node == "fills": in_fills = false
					elif node == "cellxfs": in_cellxfs = false

		# Assemble Final Styles
		for xf in cell_xfs:
			var style = {
				"bold": false,
				"font_color": "FF000000",
				"bg_color": "FFFFFF", # Default white
				"has_bg": false
			}
			
			var f_idx = xf.fontId
			if f_idx < fonts.size():
				style["bold"] = fonts[f_idx].get("bold", false)
				style["font_color"] = fonts[f_idx].get("color", "FF000000")
			
			var fill_idx = xf.fillId
			if fill_idx < fills.size():
				var fill = fills[fill_idx]
				# Excel index 0 and 1 are usually 'none' and 'gray125'
				if fill.pattern == "solid":
					style["has_bg"] = true

					if fill.color != "":
						style["bg_color"] = fill.color
					elif fill.indexed != -1:
						style["bg_color"] = "INDEXED_%d" % fill.indexed
					elif fill.theme != -1:
						style["bg_color"] = "THEME_%d_TINT_%0.3f" % [fill.theme, fill.tint]
			
			_styles.append(style)

	func _load_shared_strings():
		if not _zip.file_exists("xl/sharedStrings.xml"): return
		var data = _zip.read_file("xl/sharedStrings.xml")
		var parser = XMLParser.new()
		parser.open_buffer(data)
		var current_string = ""
		var in_text = false
		while parser.read() == OK:
			match parser.get_node_type():
				XMLParser.NODE_ELEMENT:
					if parser.get_node_name().to_lower() == "t": in_text = true
				XMLParser.NODE_TEXT:
					if in_text: current_string += parser.get_node_data()
				XMLParser.NODE_ELEMENT_END:
					if parser.get_node_name().to_lower() == "t": in_text = false
					elif parser.get_node_name().to_lower() == "si":
						_shared_strings.append(current_string)
						current_string = ""

	func _discover_sheets():
		var sheet_map = _parse_workbook_relations()
		_parse_workbook_sheets(sheet_map)

	func _parse_workbook_relations() -> Dictionary:
		var relations = {}
		if not _zip.file_exists("xl/_rels/workbook.xml.rels"): return relations
		var parser = XMLParser.new()
		parser.open_buffer(_zip.read_file("xl/_rels/workbook.xml.rels"))
		while parser.read() == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name().to_lower() == "relationship":
				var target = _get_attribute(parser, "target")
				relations[_get_attribute(parser, "id")] = "xl/" + target.replace("\\", "/").lstrip("xl/")
		return relations

	func _parse_workbook_sheets(sheet_map: Dictionary):
		if not _zip.file_exists("xl/workbook.xml"): return
		var parser = XMLParser.new()
		parser.open_buffer(_zip.read_file("xl/workbook.xml"))
		while parser.read() == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name().to_lower() == "sheet":
				var s_path = sheet_map.get(_get_attribute(parser, "r:id", "id"), "")
				if _zip.file_exists(s_path):
					_sheets.append(_parse_sheet(s_path, _get_attribute(parser, "name")))

	func _parse_sheet(path: String, name: String) -> ExcelSheet:
		var parser = XMLParser.new()
		parser.open_buffer(_zip.read_file(path))
		var rows = []
		var current_row = {}
		var max_col = 0
		var current_cell_type = ""
		var current_style_idx = 0
		var current_col = 0
		
		while parser.read() == OK:
			match parser.get_node_type():
				XMLParser.NODE_ELEMENT:
					var node = parser.get_node_name().to_lower()
					if node == "c":
						current_cell_type = _get_attribute(parser, "t", "")
						current_style_idx = _get_attribute(parser, "s", "0").to_int()
						var r_ref = _get_attribute(parser, "r", "")
						var col_str = ""
						for char in r_ref:
							if char.is_valid_int(): break
							col_str += char
						current_col = _column_to_index(col_str)
						max_col = max(max_col, current_col)
					elif node == "v":
						parser.read()
						var raw_val = parser.get_node_data()
						var final_val = _parse_cell_value(raw_val, current_cell_type)
						var style = _styles[current_style_idx] if current_style_idx < _styles.size() else {"bg_color": "FFFFFF", "has_bg": false}
						current_row[current_col] = {"value": final_val, "style": style}
				XMLParser.NODE_ELEMENT_END:
					if parser.get_node_name().to_lower() == "row":
						var filled_row = {}
						for i in range(1, max_col + 1):
							filled_row[i] = current_row.get(i, {"value": "", "style": {"bg_color": "FFFFFF", "has_bg": false}})
						rows.append(filled_row)
						current_row = {}
		return ExcelSheet.new(name, rows)

	func _parse_cell_value(value: String, type: String):
		if type == "s":
			return _shared_strings[value.to_int()] if value.is_valid_int() else value
		return value.to_float() if value.is_valid_float() else value

	func _get_attribute(parser: XMLParser, name: String, fallback: String = "") -> String:
		for i in range(parser.get_attribute_count()):
			if parser.get_attribute_name(i).to_lower() == name.to_lower():
				return parser.get_attribute_value(i)
		return fallback

	func _column_to_index(col: String) -> int:
		var index = 0
		for c in col.to_upper():
			index = index * 26 + (c.unicode_at(0) - 64)
		return index

	func _convert_to_continuous_grid(rows: Array) -> Dictionary:
		var grid = {}
		for i in range(rows.size()):
			grid[i + 1] = rows[i]
		return grid

class ExcelSheet:
	extends RefCounted
	var name: String
	var normalized_name: String
	var rows: Array
	func _init(sheet_name: String, data: Array):
		name = sheet_name
		normalized_name = name.replace(" ", "").to_lower()
		rows = data
