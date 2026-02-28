extends Node
class_name Lexer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func create_token(token) -> void:
	if token:
		print(token) 


func tokenize(source_code: String) -> void:
	var tokens := []
	var cursor := 0
	var current_line := 1
	var column_number := 1
	var keywords := ["if", "else"]	# <- Hier immer neue Keywords hinzufügen 
	
	while cursor < source_code.length():
		var char_code = source_code.unicode_at(cursor) 	# Get char at current cursor pos
		match char_code:
			32: # Leerzeichen
				column_number += 1
			9:  # Tab
				column_number += 4
			10: # New Line
				current_line += 1
				column_number = 1
		
		if char_code == 61: 	# "=" Zeichen 
			if cursor + 1 < source_code.length() and source_code.unicode_at(cursor+1) == 61:
				create_token("EQUALS")
				cursor += 2
			else:
				create_token("ASSIGN")
				cursor += 1
		
		if \
		(char_code >= 65 and char_code <= 90) or \
		(char_code >= 97 and char_code <= 122) or \
		(char_code == 95): 	# A-Z: 65-90, a-z: 97-122, "_": 95
				
			var start := cursor
			
			while cursor < source_code.length():
				var current_char := source_code.unicode_at(cursor) 	# New char at cursor pos
				
				if \
				(current_char >= 48 and current_char <= 57) or \
				(current_char >= 65 and current_char <= 90) or \
				(current_char >= 97 and current_char <= 122) or \
				(current_char == 95):	# 0-9: 48-57, A-Z: 65-90, a-z: 97-122, "_": 95
					
					cursor += 1 	# Move Cursor further
				else:
					break 	# Break loop if no valid char is found
				
			var word := source_code.substr(start, cursor - start)
			
			if word in keywords:
				# Create a keyword token
				print("Keyword detected: " + str(word))
				pass
			else:
				# Create an Identifier-Token (Variable name)
				print(word)
				pass
			
		cursor += 1
		
	print("Line: " + str(current_line) + "\nColumn: " + str(column_number))
				
	

func _on_interpreter_source_code_submitter(source_code: String) -> void:
	tokenize(source_code)
