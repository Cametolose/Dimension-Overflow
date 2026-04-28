extends Node
class_name Lexer

# Collection of all Token Types
enum T {
	# Symbols
	LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, 
	LEFT_BRACKET, RIGHT_BRACKET, 
	COMMA, PERIOD, SEMICOLON, COLON, 
	BACKSLASH, ATSYMBOL, APOSTROPHE, QUOTATION,
	
	# Operator
	EQUALS, ASSIGN, WALRUS, 
	ASSIGN_EXPONENT, EXPONENT, 
	ASSIGN_MULTIPLICATION, MULTIPLICATION, 
	ASSIGN_MODULO, MODULO, 
	ASSIGN_INT_DIVISION, INT_DIVISION, ASSIGN_DIVISION, DIVISION,
	ASSIGN_SUBTRACTION, SUBTRACTION,
	ASSIGN_ADDITION, ADDITION,
	ASSIGN_SIGNED_RIGHT_SHIFT, SIGNED_RIGHT_SHIFT,
	ASSIGN_ZERO_FILL_LEFT_SHIFT, ZERO_FILL_LEFT_SHIFT,
	EQUAL_GREATER, GREATER, EQUAL_LESS, LESS,
	ASSIGN_AND, BITWISE_AND, 
	ASSIGN_OR, BITWISE_OR, 
	ASSIGN_XOR, BITWISE_XOR, 
	BITWISE_NOT, EQUAL_NOT,
	
	# Literals
	NUMBER, NUMBER_COMPLEX, NUMBER_HEX, NUMBER_BINARY, NUMBER_OCTAL,
	
	# Keywords
	FALSE, NONE, TRUE, AND, AS, ASSERT, ASYNC, AWAIT, BREAK, 
	CLASS, CONTINUE, DEF, DEL, ELIF, ELSE, EXCEPT, FINALLY, FOR, 
	FROM, GLOBAL, IF, IMPORT, IN, IS, LAMBDA, NONLOCAL, NOT, OR,
	PASS, RAISE, RETURN, TRY, WHILE, WITH, YIELD, MATCH, CASE, TYPE,
	
	# Not sure
	IDENTIFIER, NEWLINE, RETURN_TYPE_HINT,
}

# Add new keywords here. Current keywords: https://pynote.readthedocs.io/en/latest/Basics/Keywords.html#id1
const KEYWORDS := {
		'False': T.FALSE, 
		'None': T.NONE, 
		'True': T.TRUE, 
		'and': T.AND, 
		'as': T.AS, 
		'assert': T.ASSERT, 
		'async': T.ASYNC, 
		'await': T.AWAIT, 
		'break': T.BREAK, 
		'class': T.CLASS, 
		'continue': T.CONTINUE, 
		'def': T.DEF, 
		'del': T.DEL, 
		'elif': T.ELIF,
		'else': T.ELSE, 
		'except': T.EXCEPT, 
		'finally': T.FINALLY,  
		'for': T.FOR, 
		'from': T.FROM, 
		'global': T.GLOBAL, 
		'if': T.IF, 
		'import': T.IMPORT, 
		'in': T.IN, 
		'is': T.IS, 
		'lambda': T.LAMBDA, 
		'nonlocal': T.NONLOCAL, 
		'not': T.NOT, 
		'or': T.OR, 
		'pass': T.PASS, 
		'raise': T.RAISE, 
		'return': T.RETURN, 
		'try': T.TRY, 
		'while': T.WHILE, 
		'with': T.WITH, 
		'yield': T.YIELD,
		'match': T.MATCH,
		'case': T.CASE,
		'type': T.TYPE,
}

var tab_size := 4
var cursor := 0
var current_column := 0
var current_line := 0
var source_code := ""
var tokens := []

class Token:
	var type: T
	var lexeme: String
	var literal 	# Can be anything (int, float, string)
	var line: int
	var col: int
	
	func _init(_type: T, _lexeme: String, _literal, _line: int, _col: int):
		type = _type
		lexeme = _lexeme
		literal = _literal
		line = _line
		col = _col
		
	func _to_string() -> String: 	# Debug for printing
		var type_name = T.keys()[type]
		var val_str := str(literal) if literal != null else "null"
		return "[%-15s | '%s' | Val: %-8s | Line: %d | Col: %d]" % [type_name, lexeme, val_str, line, col]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func add_token(token_list: Array, type: T, lexeme: String, literal, line: int, col: int) -> void:
	var new_token = Token.new(type, lexeme, literal, line, col)
	token_list.append(new_token)
	
	print(token_list)

func is_letter(c: int) -> bool:
	return (c >= 65 and c <= 90) or (c >= 97 and c <= 122) or c == 95  # A-Z: 65-90, a-z: 97-122, "_": 95

func is_digit(c: int) -> bool:
	return (c >= 48 and c <= 57)	# 0-9: 48-57
	
func is_alphanumeric(c: int) -> bool:
	return is_letter(c) or is_digit(c)

func consume_number():
	var start_pos := cursor
	var start_col := current_column
	var number_type := T.NUMBER
	
	# Check for prefix (0x, 0b, 0o) Hexa, Binary, Okatal
	if peek() == 48:	# 0: 48
		var next = peek(1)
		
		if next == 120 or next == 88: # "x": 120, "X": 88
			return consume_prefixed_number(start_pos, start_col, 16, T.NUMBER_HEX)
		if next == 98 or next == 66: # "b": 98, "B": 66
			return consume_prefixed_number(start_pos, start_col, 2, T.NUMBER_BINARY)
		if next == 111 or next == 79: # "o": 111, "O": 79
			return consume_prefixed_number(start_pos, start_col, 8, T.NUMBER_OCTAL)
		
		# Python doesn't allow leading zeroes
		if is_digit(next):
			printerr("yntax Error: Leading zeros in decimal integer literals are not permitted.")
			#TODO add error handling
			
	var is_float := false
	
	# Use peek() function for char_code
	# Check for underscores and numbers before comma
	while is_digit(peek()) or peek() == 95: # "_": 95
		if peek() == 95:
			if not is_digit(peek(1)):
				print("Syntax Error: Underscore must be between digits.")
				# TODO: Add proper Error handling later
			advance()
		else:
			advance()
	
	# Check for after comma
	if peek() == 46: # Check for period (Float)
		is_float = true
		advance()
		
		while is_digit(peek()) or peek() == 95:
			advance()
	
	# Exponent (Scientific Notation)
	if peek() == 101 or peek() == 69: # "e": 101, "E": 69
		is_float = true
		advance() # Skip the e/E
		
		# Optional sign
		if peek() == 43 or peek() == 45: # "+" or "-"
			advance()
		
		if not is_digit(peek()):
			print("Syntax Error: Exponent requires digits.")
			# TODO: Add proper Error handling later
		
		while is_digit(peek()) or peek() == 95:
			advance()
	
	# Check for complex numbers
	if peek() == 106 or peek() == 74:	# "j": 106, "J": 74
		is_float = true
		number_type = T.NUMBER_COMPLEX
		advance()
	
	
	var lexeme := source_code.substr(start_pos, cursor - start_pos)
	var clean_value = lexeme.replace("_", "").trim_suffix("j").trim_suffix("J")
	
	var final_value
	if is_float:
		final_value = clean_value.to_float()
	else:
		final_value = clean_value.to_int()
		
	add_token(tokens, number_type, lexeme, final_value, current_line, start_col)

# TODO: Add Error handling for wrong letters/numbers (Octal: 0-7) (Hex: 0-F) (Binary: 0-1)
func consume_prefixed_number(start_pos: int, start_col: int, base: int, type: T):
	advance(2) # Skip "0x", "0b" etc.
	
	var value_start := cursor
	
	while is_alphanumeric(peek()) or peek() == 95:
		advance()
	
	var lexeme := source_code.substr(start_pos, cursor - start_pos)
	var value_part := source_code.substr(value_start, cursor - value_start).replace("_", "")
	var final_value = 0
	
	match base:
		16:
			final_value = value_part.hex_to_int()
		2:
			final_value = value_part.bin_to_int()
		8:
			final_value = _convert_to_base(value_part, 8)
		_:
			final_value = value_part.to_int()
	
	add_token(tokens, type, lexeme, final_value, current_line, start_col)

func _convert_to_base(string_value: String, base: int) -> int:
	var result = 0
	for char in string_value:
		result = result * base + char.to_int()
	return result
	
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
				add_token(tokens, T.NEWLINE, "\\n", null, current_line, current_column)
				current_line += 1
				current_column = 1
				cursor += 1
				continue
			
			46: # "."
				if is_digit(peek(1)):
					consume_number()
				else:
					add_token(tokens, T.PERIOD, ".", null, current_line, current_column)
					advance()
				continue
			
			# Punctuators
			61: # "=" 
				if peek(1) == 61:	   # Check for two "=" symbols
					add_token(tokens, T.EQUALS, "==", null, current_line, current_column)
					advance(2)
				else:
					add_token(tokens, T.ASSIGN, "=", null, current_line, current_column)
					advance()
				continue
			
			40: # "("
				add_token(tokens, T.LEFT_PAREN, "(", null, current_line, current_column)
				advance()
				continue
			
			41: # ")"
				add_token(tokens, T.RIGHT_PAREN, ")", null, current_line, current_column)
				advance()
				continue
			
			123: # "{"
				add_token(tokens, T.LEFT_BRACE, "{", null, current_line, current_column)
				advance()
				continue
			
			125: # "}"
				add_token(tokens, T.RIGHT_BRACE, "}", null, current_line, current_column)
				advance()
				continue
				
			91: # "["
				add_token(tokens, T.LEFT_BRACKET, "[", null, current_line, current_column)
				advance()
				continue
			
			93: # "]"
				add_token(tokens, T.RIGHT_BRACKET, "]", null, current_line, current_column)
				advance()
				continue
				
			58: # ":"
				if peek(1) == 61: 	# :=
					add_token(tokens, T.WALRUS, ":=", null, current_line, current_column)
					advance(2)
				else:	# :
					add_token(tokens, T.COLON, ":", null, current_line, current_column)
					advance()
				continue
				
			59: # ";"+
				add_token(tokens, T.SEMICOLON, ";", null, current_line, current_column)
				advance()
				continue
				
			44: # ","
				add_token(tokens, T.COMMA, ",", null, current_line, current_column)
				advance()
				continue
			
			92: # "\"
				add_token(tokens, T.BACKSLASH, "\\", null, current_line, current_column)
				advance()
				continue
			
			35: # "#" (Comment)
				# Comment will be ignored until the end of the line. "\n": 10
				while peek() != 10 and cursor < source_code.length():
					advance()
				continue
			
			64: # "@"
				add_token(tokens, T.ATSYMBOL, "@", null, current_line, current_column)
				advance()
				continue
			
			39: # "'"
				add_token(tokens, T.APOSTROPHE, "\'", null, current_line, current_column)
				advance()
				continue
				
			34: # """
				add_token(tokens, T.QUOTATION, "\"", null, current_line, current_column)
				advance()
				continue
				
			# Operators
			42: # "*"
				if peek(1) == 42: 	# **
					if peek(2) == 61:  # **=
						add_token(tokens, T.ASSIGN_EXPONENT, "**=", null, current_line, current_column)
						advance(3)
					else:	# **
						add_token(tokens, T.EXPONENT, "**", null, current_line, current_column)
						advance(2)
				else:	# *
					if peek(1) == 61: # *=
						add_token(tokens, T.ASSIGN_MULTIPLICATION, "*=", null, current_line, current_column)
						advance(2)
					else: # *
						add_token(tokens, T.MULTIPLICATION, "*", null, current_line, current_column)
						advance(1)
				continue
			
			37: # "%"
				if peek(1) == 61: 	# %=
					add_token(tokens, T.ASSIGN_MODULO, "%=", null, current_line, current_column)
					advance(2)
				else:	# %
					add_token(tokens, T.MODULO, "%", null, current_line, current_column)
					advance()
				continue
			
			47: # "/"
				if peek(1) == 47: 	# //
					if peek(2) == 61:  # //=
						add_token(tokens, T.ASSIGN_INT_DIVISION, "//=", null, current_line, current_column)
						advance(3)
					else:	# //
						add_token(tokens, T.INT_DIVISION, "//", null, current_line, current_column)
						advance(2)
				else:	# /
					if peek(1) == 61: # /=
						add_token(tokens, T.ASSIGN_DIVISION, "/=", null, current_line, current_column)
						advance(2)
					else: # /
						add_token(tokens, T.DIVISION, "/", null, current_line, current_column)
						advance(1)
				continue
			
			45: # "-"
				if peek(1) == 61: 	# -=
					add_token(tokens, T.ASSIGN_SUBTRACTION, "-=", null, current_line, current_column)
					advance(2)
				elif peek(1) == 62: 	# ->
					add_token(tokens, T.RETURN_TYPE_HINT, "->", null, current_line, current_column)
					advance(2)
				else:	# -
					add_token(tokens, T.SUBTRACTION, "-", null, current_line, current_column)
					advance()
				continue
				
			43: # "+"
				if peek(1) == 61: 	# +=
					add_token(tokens, T.ASSIGN_ADDITION, "+=", null, current_line, current_column)
					advance(2)
				else:	# +
					add_token(tokens, T.ADDITION, "+", null, current_line, current_column)
					advance()
				continue
			
			62: # ">"
				if peek(1) == 62: 	# >>
					if peek(2) == 61:  # >>=
						add_token(tokens, T.ASSIGN_SIGNED_RIGHT_SHIFT, ">>=", null, current_line, current_column)
						advance(3)
					else:	# >> -> Bitwise operator
						add_token(tokens, T.SIGNED_RIGHT_SHIFT, ">>", null, current_line, current_column)
						advance(2)
				else:	# >
					if peek(1) == 61: # >=
						add_token(tokens, T.EQUAL_GREATER, ">=", null, current_line, current_column)
						advance(2)
					else: # >
						add_token(tokens, T.GREATER, ">", null, current_line, current_column)
						advance(1)
				continue
				
			63: # "<"
				if peek(1) == 63: 	# <<
					if peek(2) == 61:  # <<=
						add_token(tokens, T.ASSIGN_ZERO_FILL_LEFT_SHIFT, "<<=", null, current_line, current_column)
						advance(3)
					else:	# << -> Bitwise operator
						add_token(tokens, T.ZERO_FILL_LEFT_SHIFT, "<<", null, current_line, current_column)
						advance(2)
				else:	# <
					if peek(1) == 61: # <=
						add_token(tokens, T.EQUAL_LESS, "<=", null, current_line, current_column)
						advance(2)
					else: # <
						add_token(tokens, T.LESS, "<", null, current_line, current_column)
						advance(1)
				continue
			
			38: # "&"
				if peek(1) == 61: 	# &=
					add_token(tokens, T.ASSIGN_AND, "&=", null, current_line, current_column)
					advance(2)
				else:	# &
					add_token(tokens, T.BITWISE_AND, "&", null, current_line, current_column)
					advance()
				continue
			
			124: # "|"
				if peek(1) == 61: 	# |=
					add_token(tokens, T.ASSIGN_OR, "|=", null, current_line, current_column)
					advance(2)
				else:	# |
					add_token(tokens, T.BITWISE_OR, "|", null, current_line, current_column)
					advance()
				continue
				
			94: # "^"
				if peek(1) == 61: 	# ^=
					add_token(tokens, T.ASSIGN_XOR, "^=", null, current_line, current_column)
					advance(2)
				else:	# ^
					add_token(tokens, T.BITWISE_XOR, "^", null, current_line, current_column)
					advance()
				continue
			
			126: # "~"
				add_token(tokens, T.BITWISE_NOT, "~", null, current_line, current_column)
				advance()
				continue
				
			33: # "!"
				if peek(1) == 61: 	# !=
					add_token(tokens, T.EQUAL_NOT, "!=", null, current_line, current_column)
					advance(2)
					continue


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
			var type: T = KEYWORDS.get(word, T.IDENTIFIER)
			
			add_token(tokens, type, word, null, current_line, start_column)
			continue
			
		# Number
		if is_digit(char_code):
			consume_number()
			continue
	
		# Unknown Character
		print("Unknown Character: ", char_code)
		advance()

func _on_interpreter_source_code_submitter(input_text: String) -> void:
	tokenize(input_text)
