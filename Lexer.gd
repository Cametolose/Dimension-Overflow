extends Node
class_name Lexer

# Add new keywords here. Current keywords: https://pynote.readthedocs.io/en/latest/Basics/Keywords.html#id1
const KEYWORDS := [
		'False', 
		'None', 
		'True', 
		'and', 
		'as', 
		'assert', 
		'async', 
		'await', 
		'break', 
		'class', 
		'continue', 
		'def', 
		'del', 
		'elif',
		'else', 
		'except', 
		'finally', 
		'for', 
		'from', 
		'global', 
		'if', 
		'import', 
		'in', 
		'is', 
		'lambda', 
		'nonlocal', 
		'not', 
		'or', 
		'pass', 
		'raise', 
		'return', 
		'try', 
		'while', 
		'with', 
		'yield',
]

var tab_size := 4
var cursor := 0
var current_column := 0
var current_line := 0
var source_code := ""
var tokens := []

class Token:
	var type: String
	var lexeme: String
	var literal 	# Can be anything (int, float, string)
	var line: int
	var col: int
	
	func _init(_type: String, _lexeme: String, _literal, _line: int, _col: int):
		type = _type
		lexeme = _lexeme
		literal = _literal
		line = _line
		col = _col
		
	func _to_string() -> String: 	# Debug for printing
		return "[%s | '%s' | Val: %s | Line: %d | Col: %d]" % [type, lexeme, str(literal), line, col]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func add_token(token_list: Array, type: String, lexeme: String, literal, line: int, col: int) -> void:
	var new_token = Token.new(type, lexeme, literal, line, col)
	token_list.append(new_token)
	
	print(token_list)

func is_letter(c: int) -> bool:
	return (c >= 65 and c <= 90) or (c >= 97 and c <= 122) or c == 95  # A-Z: 65-90, a-z: 97-122, "_": 95

func is_digit(c: int) -> bool:
	return (c >= 48 and c <= 57)	# 0-9: 48-57
	
func is_alphanumeric(c: int) -> bool:
	return is_letter(c) or is_digit(c)

func advance(n: int = 1) -> void:
	cursor += n
	current_column += n

func peek(offset: int = 0) -> int:
	if cursor + offset >= source_code.length():
		return 0
	return source_code.unicode_at(cursor + offset)

func tokenize(input_text: String) -> void:
	var start_time = Time.get_ticks_msec()
	source_code = input_text
	cursor = 0
	current_line = 1
	current_column = 1
	tokens = []


	while cursor < source_code.length():
		var char_code = source_code.unicode_at(cursor) 	# Get char at current cursor pos
		match char_code:
			32: # Space
				advance()
				continue
				
			9:  # Tab
				cursor += 1
				current_column += tab_size
				continue
				
			10: # New Line
				add_token(tokens, "NEWLINE", "\\n", null, current_line, current_column)
				current_line += 1
				current_column = 1
				cursor += 1
				continue
			
			# Punctuators (and equals)
			61: # "=" 
				if cursor + 1 < source_code.length() and peek(1) == 61:	   # Check for two "=" symbols
					add_token(tokens, "EQUALS", "==", null, current_line, current_column)
					advance(2)
				else:
					add_token(tokens, "ASSIGN", "=", null, current_line, current_column)
					advance()
				continue
			
			40: # "("
				add_token(tokens, "LEFT_PAREN", "(", null, current_line, current_column)
				advance()
				continue
			
			41: # ")"
				add_token(tokens, "RIGHT_PAREN", ")", null, current_line, current_column)
				advance()
				continue
			
			123: # "{"
				add_token(tokens, "LEFT_BRACE", "{", null, current_line, current_column)
				advance()
				continue
			
			125: # "}"
				add_token(tokens, "RIGHT_BRACE", "}", null, current_line, current_column)
				advance()
				continue
				
			91: # "["
				add_token(tokens, "LEFT_BRACKET", "[", null, current_line, current_column)
				advance()
				continue
			
			93: # "]"
				add_token(tokens, "RIGHT_BRACKET", "]", null, current_line, current_column)
				advance()
				continue
				
			58: # ":"
				add_token(tokens, "COLON", ":", null, current_line, current_column)
				advance()
				continue
				
			59: # ";"+
				add_token(tokens, "SEMICOLON", ";", null, current_line, current_column)
				advance()
				continue
				
			44: # ","
				add_token(tokens, "COMMA", ",", null, current_line, current_column)
				advance()
				continue
			
			46: # "."
				add_token(tokens, "PERIOD", ".", null, current_line, current_column)
				advance()
				continue
			
			92: # "\"
				add_token(tokens, "BACKSLASH", "\\", null, current_line, current_column)
				advance()
				continue
			
			35: # "#" (Comment)
				# Comment will be ignored until the end of the line. "\n": 10
				while peek() != 10 and cursor < source_code.length():
					advance()
				continue
			
			64: # "@"
				add_token(tokens, "ATSYMBOL", "@", null, current_line, current_column)
				advance()
				continue
			
			39: # "'"
				add_token(tokens, "APOSTROPHE", "\'", null, current_line, current_column)
				advance()
				continue
				
			34: # """
				add_token(tokens, "QUOTATION", "\"", null, current_line, current_column)
				advance()
				continue
				
			# Operators (Without equals)
			42: # "*"
				if cursor + 1 < source_code.length() and peek(1) == 42: 	# **
					if cursor + 2 < source_code.length() and peek(2) == 61:  # **=
						add_token(tokens, "ASSIGN_EXPONENT", "**=", null, current_line, current_column)
						advance(3)
					else:	# **
						add_token(tokens, "EXPONENT", "**", null, current_line, current_column)
						advance(2)
				else:	# *
					if cursor + 1 < source_code.length() and peek(1) == 61: # *=
						add_token(tokens, "ASSIGN_MULTIPLICATION", "*=", null, current_line, current_column)
						advance(2)
					else: # *
						add_token(tokens, "MULTIPLICATION", "*", null, current_line, current_column)
						advance(1)
				continue
			
			#37: # "%"
				#if cursor + 1 < source_code.length() and peek(1) == 61: 	# %=
					#add_token(tokens, "MODULO_")
				#else:	# *
					#if cursor + 1 < source_code.length() and peek(1) == 61: # *=
						#add_token(tokens, "ASSIGN_MULTIPLICATION", "*=", null, current_line, current_column)
						#advance(2)
					#else: # *
						#add_token(tokens, "MULTIPLICATION", "*", null, current_line, current_column)
						#advance(1)
				#continue
			
			
			
			
			
		
		# Identifier
		if is_letter(char_code):
			var start := cursor
			var start_column := current_column
			
			while cursor < source_code.length():
				var current_char := source_code.unicode_at(cursor) 	# New char at cursor pos
				
				if is_alphanumeric(current_char):
					advance()
				else:
					break 	# Break loop if no valid char is found
				
			var word := source_code.substr(start, cursor - start)
			
			if word in KEYWORDS:
				add_token(tokens, "KEYWORD_" + word.to_upper(), word, null, current_line, start_column)
			else:
				add_token(tokens, "IDENTIFIER", word, null, current_line, start_column)
			continue
			
		
		elif is_digit(char_code):
			var is_float := false
			var start := cursor
			var start_column := current_column
			
			while cursor < source_code.length():
				var current_num := source_code.unicode_at(cursor) 	# New number at cursor pos
				
				if is_digit(current_num):
					advance()
				elif current_num == 46 and is_float == false: 	# ".": 46 | Check if it is a float
					advance()
					is_float = true
				else:
					break
				
			var number = source_code.substr(start, cursor - start)
			var final_value
			
			if is_float:
				final_value = number.to_float()
			else:
				final_value = number.to_int()
	
			add_token(tokens, "NUMBER", number, final_value, current_line, start_column)
			continue
	
		# Unknown Character
		print("Unknown Character: ", char_code)
		advance()

func _on_interpreter_source_code_submitter(input_text: String) -> void:
	tokenize(input_text)
