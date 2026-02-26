extends CodeEdit

var old_text := ""
var variable := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_text_changed() -> void:
	var lines = text.split("\n")
	
	if text != old_text:
		old_text = text
		print(text)
		for line in lines:
			if "=" in line:
				var text_list := line.split("=")
				variable[text_list[0].strip_edges()] = text_list[1].strip_edges()
				
	if len(variable) > 0:
		for line in lines:
			for i in variable:
				if "print({0})".format({0: i}) in line:
					print(variable[i])
