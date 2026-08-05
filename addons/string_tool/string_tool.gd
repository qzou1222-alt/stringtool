extends RefCounted
class_name StringTool

## Base class for classes that cannot be instantiated.[br]
##[br]
## Calling ClassName.new() will produce an error.
class UnInstantiable:
	static func new():
		push_error("This class cannot be instantiated")
		return null
const UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const LOWERCASE = "abcdefghijklmnopqrstuvwxyz"
const LETTERS = UPPERCASE + LOWERCASE
const NUMBERS = "0123456789"
const HALFWIDTH = "!@#$%^&*(){}[]\\|;:'\"-_+=,./<>?"
const FULLWIDTH = "！￥…（）—【】；：‘’“”《》，。、？"
const SYMBOLS = HALFWIDTH + FULLWIDTH
const VOWELS = "aeiou"
const CONSONANTS = "bcdfghjklmnpqrstvwxyz"
const NAME_CONSONANTS = "bcdfghjklmnprstvwxyz"
const START_COMBINATION = [
	"bl","br","cl","cr",
	"dr","fr","fl",
	"gl","gr",
	"kr","pr","pl",
	"sh","sl","tr","tw",
	"ch","th","st","sk","qu"
]
## A class for generated random strings.[br]
##[br]
## StringGenerator extends UnInstantiable, so calling StringGenerator.new() will produce an error.[br]
class StringGenerator extends UnInstantiable:
	static func is_valid_format(string:String) -> bool:
		for chr in string:
			if chr not in "Llnsca" and chr in LETTERS:
				return false
		return true
	## Select characters from the given characters to generate a string.[br]
	##[br]
	## Returns null if chars is empty.
	static func specific(length: int, chars: String = LETTERS + NUMBERS) -> Variant:
		var result = ""
		if chars.is_empty():
			return null
		for i in range(length):
			result += chars[randi() % chars.length()]

		return result
	## Generates a string in the given format.[br]
	## [br]
	## L: Uppercase letter[br]
	## [br]
	## l: Lowercase letter[br]
	## [br]
	## n: Numeric digit (0-9)[br]
	## [br]
	## s: Symbol character[br]
	## [br]
	## c: Chinese character (0x4E00 ~ 0x9FFF)[br]
	## [br]
	## a: Any Unicode character in 0x0000 ~ 0xFFFF[br]
	## [br]
	## Format strings may only use the special letters L, l, n, s, c, and a.[br]
	## [br]
	## Any other alphabetic character is considered invalid.[br]
	## [br]
	## @experimental
	## Experimental Warning: format character "a" is experimental because it will pick from most characters in Unicode.[br] 
	## [br]
	## This includes Chinese characters, uncommon symbols, and even control characters.
	static func from_format(format: String) -> Variant:
		var result = ""
		for chr in format:
			match chr:
				"L":
					result += UPPERCASE[randi() % 26]
				"l":
					result += LOWERCASE[randi() % 26]
				"n":
					result += NUMBERS[randi() % 10]
				"s":
					result += SYMBOLS[randi() % SYMBOLS.length()]
				"c":
					result += char(randi_range(0x4E00,0x9FFF))
				"a":
					result += char(randi_range(0,0xFFFF))
				_:
					if chr in LETTERS:
						push_error("Invalid format")
						return null
					result+=chr
		return result
class IDGenerator extends  StringGenerator:
	static var last_ordered_id: int = -1
	static var global_ids: Array[String] = []
	static func generate_id(length: int = 10):
		return specific(length, LETTERS + NUMBERS)
		
	static func generate_ordered_global_id(length: Variant = null):
		var strid=str(last_ordered_id+1)
		last_ordered_id+=1
		if length==null:
			return strid
		return "0".repeat(max(length-len(strid),0))+strid
	static func to_nozero_id(id: String) -> String:
		var start = true
		var ind = 0
		for c in id:
			if c == "0" and start:
				id=id.substr(ind+1)
			else:
				start = false
			ind += 1
		if id=="":
			id="0"
		return id
	## Generate an ID and store up in IDGenerator.global_ids.[br]
	## You won't get the same id from this function in one running.[br]
	## @experimental
	## Experimental Warning: This function will block program when you called this function as many times,[br]
	## because the more times it is called, the more times it needs to be iterated,
	## and the program will completely stuck when you called it too more times.
	static func generate_global_id(length: int = 10, ignore_leading_zeros: bool = true):
		var first = true
		var id_exists = false
		var id = ""
		while id_exists or first:
			if first:
				first=false
			id = generate_id(length)
			id_exists = false
			for item in global_ids:
				var condition = false
				if ignore_leading_zeros:
					condition = to_nozero_id(item)==to_nozero_id(id)
				else:
					condition = item == id
				if condition:
					id_exists = true
					break
			
		global_ids.append(id)
		return id
class NameGenerator extends StringGenerator:
	## Generates a pronounceable random name.[br]
	##[br]
	## Examples:[br]
	## - Bally[br]
	## - Grid[br]
	## - Sorry[br]
	##[br]
	## If capitalize is true, the first letter is uppercase.
	static func generate_name(capitalize: bool = true) -> String:
		var first = ""
		if randi() % 2:
			first = NAME_CONSONANTS[randi() % NAME_CONSONANTS.length()]
		else:
			first = START_COMBINATION[randi() % START_COMBINATION.size()]
		var result = first+VOWELS[randi() % VOWELS.length()]+NAME_CONSONANTS[randi() % NAME_CONSONANTS.length()]
		if randi() % 2 and not result.ends_with("y"):
			result = result+result[-1]+"y"
		if capitalize:
			result=result.capitalize()
		return result
	static func generate_user_name():
		if randi() % 2:
			return from_format("L"+"l".repeat(randi_range(0,6))+"nnn")
		else:
			return generate_name()+from_format("nnn")
## Select characters from the given characters to generate a string.[br]
##[br]
## Returns null if chars is empty.
func generate_string(length: int, chars: String = LETTERS + NUMBERS):
	return StringGenerator.specific(length, chars)
## Generates a string in the given format.[br]
## [br]
## L: Uppercase letter[br]
## [br]
## l: Lowercase letter[br]
## [br]
## n: Numeric digit (0-9)[br]
## [br]
## s: Symbol character[br]
## [br]
## c: Chinese character (0x4E00 ~ 0x9FFF)[br]
## [br]
## a: Any Unicode character in 0x0000 ~ 0xFFFF[br]
## [br]
## Format strings may only use the special letters L, l, n, s, c, and a.[br]
## [br]
## Any other alphabetic character is considered invalid.[br]
## [br]
## @experimental
## [b]Experimental Warning:[/b] format character "a" is experimental because it will pick from most characters in Unicode.
## [br]
## This includes Chinese characters, uncommon symbols, and even control characters.
func generate_string_format(format: String):
	return StringGenerator.from_format(format)
