extends Node

signal source_code_submitter(source_code: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func run_code():
	pass


func _on_ui_code_submitted(source_code: String) -> void:
	print("Interpreter: Received Code.")
	source_code_submitter.emit(source_code)
		
	
