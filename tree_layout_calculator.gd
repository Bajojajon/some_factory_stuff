# tree_layout_calculator.gd
# Two-pass tree layout algorithm for positioning branches
# Pass 1: Bottom-up (right-to-left) - calculate required vertical space
# Pass 2: Top-down (left-to-right) - position nodes with calculated space

class_name TreeLayoutCalculator
extends RefCounted

# Layout configuration
var vertical_spacing: float = 20.0  # Space between siblings
var horizontal_spacing: float = 150.0  # Space between depth levels
var branch_height: float = 50.0  # Height of each branch node

# Layout result structure
class LayoutResult:
	var positions: Dictionary = {}  # branch_name -> Vector2
	var total_height: float = 0.0
	var total_width: float = 0.0
	var column_info: Dictionary = {}  # depth -> {count, max_y}

# Main entry point for layout calculation
func calculate_layout(tree_dict: Dictionary) -> LayoutResult:
	print("\n=== Starting Tree Layout Calculation ===")
	
	var result = LayoutResult.new()
	
	# Extract tree structure info
	var branches = tree_dict.get("branches", {})
	var info = tree_dict.get("info", {})
	var amounts = info.get("amounts", {})
	
	print("Tree info: ", amounts)
	
	# Build parent-child relationships
	var tree_structure = _build_tree_structure(tree_dict)
	
	# PASS 1: Calculate required vertical space (bottom-up)
	print("\n--- PASS 1: Calculating vertical space requirements ---")
	var space_requirements = _calculate_space_requirements(tree_structure)
	
	# PASS 2: Position nodes (top-down)
	print("\n--- PASS 2: Positioning nodes ---")
	_position_nodes(tree_structure, space_requirements, result)
	
	print("\n=== Layout Complete ===")
	print("Total nodes positioned: ", result.positions.size())
	print("Total height: ", result.total_height)
	print("Total width: ", result.total_width)
	
	return result

# Build tree structure with parent-child relationships
func _build_tree_structure(tree_dict: Dictionary) -> Dictionary:
	var structure = {
		"roots": [],  # Top-level nodes (col_1)
		"children": {},  # parent_key -> [child_keys]
		"parents": {},  # child_key -> parent_key
		"depths": {},  # node_key -> depth_level
		"nodes": {}  # node_key -> node_data
	}
	
	var branches = tree_dict.get("branches", {})
	
	# Process all nodes and build relationships
	for node_key in branches:
		var node_data = branches[node_key]
		structure.nodes[node_key] = node_data
		
		# Determine if this is a root node (no parent keys in data)
		if not node_data.has("key_1"):
			# This is a root node
			structure.roots.append(node_key)
			structure.depths[node_key] = 0
		else:
			# Find parent key - use the highest level parent key available
			var parent_key = null
			var depth = 0
			
			# Check keys in reverse order to find immediate parent
			for i in range(6, 0, -1):
				var key_name = "key_%d" % i
				if node_data.has(key_name) and i > depth:
					if i == 1:
						parent_key = node_data[key_name]
						depth = 1
						break
					else:
						# This node's parent is at level i-1
						depth = i
						# Parent key is constructed from previous level keys
						var prev_key_name = "key_%d" % (i - 1)
						if node_data.has(prev_key_name):
							parent_key = node_data[prev_key_name]
							break
			
			if parent_key:
				structure.parents[node_key] = parent_key
				structure.depths[node_key] = depth
				
				# Add to children list
				if not structure.children.has(parent_key):
					structure.children[parent_key] = []
				structure.children[parent_key].append(node_key)
	
	print("Built tree structure:")
	print("  Roots: ", structure.roots.size())
	print("  Total nodes: ", structure.nodes.size())
	
	return structure

# PASS 1: Calculate vertical space requirements (bottom-up)
func _calculate_space_requirements(tree_structure: Dictionary) -> Dictionary:
	var requirements = {}  # node_key -> required_height
	
	# Process nodes from deepest to shallowest
	var max_depth = 0
	for node_key in tree_structure.depths:
		max_depth = max(max_depth, tree_structure.depths[node_key])
	
	# Process each depth level from deepest to shallowest
	for depth in range(max_depth, -1, -1):
		var nodes_at_depth = []
		for node_key in tree_structure.depths:
			if tree_structure.depths[node_key] == depth:
				nodes_at_depth.append(node_key)
		
		print("Processing depth ", depth, ": ", nodes_at_depth.size(), " nodes")
		
		for node_key in nodes_at_depth:
			var required_height = _calculate_node_height(node_key, tree_structure, requirements)
			requirements[node_key] = required_height
			print("  ", node_key, " requires ", required_height, " vertical space")
	
	return requirements

# Calculate required height for a single node
func _calculate_node_height(node_key: String, tree_structure: Dictionary, requirements: Dictionary) -> float:
	# Get children of this node
	var children = tree_structure.children.get(node_key, [])
	
	if children.is_empty():
		# Leaf node - just needs its own height
		return branch_height
	
	# Parent node - needs space for all children plus spacing
	var total_child_height = 0.0
	for child_key in children:
		total_child_height += requirements.get(child_key, branch_height)
	
	# Add spacing between children
	total_child_height += vertical_spacing * (children.size() - 1)
	
	# Node needs at least its own height, or enough for all children
	return max(branch_height, total_child_height)

# PASS 2: Position nodes with calculated space
func _position_nodes(tree_structure: Dictionary, space_requirements: Dictionary, result: LayoutResult) -> void:
	var column_counts = {}  # depth -> count of nodes
	
	# Start positioning from roots
	var start_y = 0.0
	
	for root_key in tree_structure.roots:
		var root_height = space_requirements.get(root_key, branch_height)
		_position_subtree(root_key, tree_structure, space_requirements, result, 0, start_y, start_y + root_height)
		start_y += root_height + vertical_spacing
	
	# Calculate total dimensions
	_calculate_total_dimensions(result)
	
	# Store column info
	for node_key in result.positions:
		var depth = tree_structure.depths.get(node_key, 0)
		if not column_counts.has(depth):
			column_counts[depth] = 0
		column_counts[depth] += 1
	
	result.column_info = column_counts

# Position a subtree recursively
func _position_subtree(node_key: String, tree_structure: Dictionary, space_requirements: Dictionary, 
					   result: LayoutResult, depth: int, y_start: float, y_end: float) -> void:
	# Position this node at center of allocated space
	var x = depth * horizontal_spacing
	var y = (y_start + y_end) / 2.0
	
	result.positions[node_key] = Vector2(x, y)
	print("Positioned ", node_key, " at (", x, ", ", y, ")")
	
	# Get children
	var children = tree_structure.children.get(node_key, [])
	if children.is_empty():
		return
	
	# Distribute vertical space among children
	var current_y = y_start
	for child_key in children:
		var child_height = space_requirements.get(child_key, branch_height)
		_position_subtree(child_key, tree_structure, space_requirements, result, 
						 depth + 1, current_y, current_y + child_height)
		current_y += child_height + vertical_spacing

# Calculate total dimensions of the layout
func _calculate_total_dimensions(result: LayoutResult) -> void:
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for pos in result.positions.values():
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	result.total_width = max_x - min_x
	result.total_height = max_y - min_y

# Alternative: Start from widest column first (mentioned in your question)
func calculate_layout_from_widest(tree_dict: Dictionary) -> LayoutResult:
	var result = LayoutResult.new()
	var info = tree_dict.get("info", {})
	var amounts = info.get("amounts", {})
	
	# Find widest column
	var max_col = 0
	var max_count = 0
	for i in range(1, 8):
		var col_key = "col_%d" % i
		if amounts.has(col_key):
			var count = amounts[col_key]
			if count > max_count:
				max_count = count
				max_col = i
	
	print("Widest column: col_", max_col, " with ", max_count, " nodes")
	
	# TODO: Implement positioning starting from widest column
	# This is more complex and requires working outward from center
	
	return result
	
