extends CanvasLayer

signal code_submitted(source_code: String)

@export var code: CodeEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_run_button_pressed() -> void:
	code_submitted.emit(code.text)	# Code will be sent to the Signal
