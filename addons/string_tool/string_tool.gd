## A simple string utility library for Godot. (v0.4.0)[br]
##
## [b]Contents Updated![/b][br]
##[br]
## 1. Added uncompleted HTML.[br]
## 2. Added more signals.[br]
## 3. Added more Inspector variables.[br]
## 4. Added preview.[br]
## 5. Heading now won't be negative.[br]
@icon("res://addons/string_tool/icon04.png")
extends RefCounted
class_name StringTool
## Base class for classes that cannot be instantiated.[br]
##[br]
## Calling ClassName.new() will produce an error.
class UnInstantiable:
	func _init() -> void:
		push_error("This class cannot be instantiated")
		return
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
## A color class to make colorstrings.
class color extends UnInstantiable:
	## This class help making color text.
	class Fore extends UnInstantiable:
		const BLACK: String = "\u001b[30m"
		const RED: String = "\u001b[31m"
		const GREEN: String = "\u001b[32m"
		const YELLOW: String = "\u001b[33m"
		const BLUE: String = "\u001b[34m"
		const MAGENTA: String = "\u001b[35m"
		const CYAN: String = "\u001b[36m"
		const WHITE: String = "\u001b[37m"
		const RESET: String = "\u001b[0m"
		static func to_red(string:String, auto_reset: bool = true) -> String:
			string=RED+string
			if auto_reset:
				string+=RESET
			return string
		static func to_black(string:String, auto_reset: bool = true) -> String:
			string=BLACK+string
			if auto_reset:
				string+=RESET
			return string
		static func to_green(string:String, auto_reset: bool = true) -> String:
			string=GREEN+string
			if auto_reset:
				string+=RESET
			return string
		static func to_yellow(string:String, auto_reset: bool = true) -> String:
			string=YELLOW+string
			if auto_reset:
				string+=RESET
			return string
		static func to_blue(string:String, auto_reset: bool = true) -> String:
			string=BLUE+string
			if auto_reset:
				string+=RESET
			return string
		static func to_magenta(string:String, auto_reset: bool = true) -> String:
			string=MAGENTA+string
			if auto_reset:
				string+=RESET
			return string
		static func to_cyan(string:String, auto_reset: bool = true) -> String:
			string=CYAN+string
			if auto_reset:
				string+=RESET
			return string
		static func to_white(string:String, auto_reset: bool = true) -> String:
			string=WHITE+string
			if auto_reset:
				string+=RESET
			return string
		static func reset():
			print(RESET)
	static func hex_to_rgb(hex: String):
		var c = Color.html(hex)
		return [
			roundi(c.r * 255),
			roundi(c.g * 255),
			roundi(c.b * 255)
		]
	static func rgb_to_hex(rgb: Array[int], hashtag: bool = true, capitalize_hex: bool = true):
		var r = rgb[0]
		var g = rgb[1]
		var b = rgb[2]
		var string=String.num_int64(int(Color(r/255,g/255,b/255).to_rgba32()),16,capitalize_hex).substr(0,6)
		if hashtag:
			string="#"+string
		return string
class markdown extends UnInstantiable:
	const MarkdownViewer = preload("res://addons/string_tool/mdv.gd")
	const MarkdownParser = preload("res://addons/string_tool/mdp.gd")
	## @deprecated: Please use MarkdownDocument instead Markdown.
	## [b]This class is be deprecated. Please use MarkdownDocument instead Markdown.[/b]
	class Markdown:
		var text = ""
		var _bounded := false
		var _viewer: MarkdownViewer
		func _init() -> void:
			pass
		func add_link(name: String, link: String) -> String:
			var string=markdown.link(name,link)
			text+=string+"\n"
			if _bounded:
				_viewer.add_text(string)
			return string
		func add_code(language: String, ...codes):
			var code="\n".join(codes)
			var string=markdown.code(language,code)+"\n"
			text+=string
			if _bounded:
				_viewer.add_text(string)
			return string
		func add_h1(text: String) -> String:
			var string=markdown.h1(text)+"\n"
			self.text+=string
			if _bounded:
				_viewer.add_text(string)
			return string
		func add_h2(text: String) -> String:
			var string=markdown.h2(text)+"\n"
			self.text+=string
			if _bounded:
				_viewer.add_text(string)
			return string
		func add_h3(text: String) -> String:
			var string=markdown.h3(text)+"\n"
			self.text+=string
			if _bounded:
				_viewer.add_text(string)
			return string
		func save(file: String, debug:=false):
			var fp=FileAccess.open(file,FileAccess.WRITE)
			if fp==null:
				if debug:
					print("[Info] Open Failed")
				assert(false, "Error: Cannot open file "+file)
			if debug:
				print("[Info] Writing text to "+file)
			fp.store_string(self.text)
			fp.close()
			if debug:
				print("[Info] successfully saved markdown in "+file+"!")
		static func loadmd(file: String, error:=true):
			var fp=FileAccess.open(file,FileAccess.READ)
			if fp == null:
				if error:
					assert(false, "Error: Cannot find file \""+file+"\", file is not exists or be deleted or moved")
				return null
			var md=Markdown.new()
			md.text=fp.get_as_text()
			fp.close()
			return md
		func _to_string() -> String:
			return text
	class MarkdownDocument:
		var text = ""
		func _init() -> void:
			pass
		func add_link(name: String, link: String) -> String:
			var string=markdown.link(name,link)
			text+=string+"\n"
			return string
		func add_code(language: String, ...codes):
			var code="\n".join(codes)
			var string=markdown.code(language,code)+"\n"
			text+=string
			return string
		func add_h1(text: String) -> String:
			var string=markdown.h1(text)+"\n"
			self.text+=string
			return string
		func add_h2(text: String) -> String:
			var string=markdown.h2(text)+"\n"
			self.text+=string
			return string
		func add_h3(text: String) -> String:
			var string=markdown.h3(text)+"\n"
			self.text+=string
			return string
		func save(file: String, debug:=false):
			var fp=FileAccess.open(file,FileAccess.WRITE)
			if fp==null:
				if debug:
					print("[Info] Open Failed")
				assert(false, "Error: Cannot open file "+file)
			if debug:
				print("[Info] Writing text to "+file)
			fp.store_string(self.text)
			fp.close()
			if debug:
				print("[Info] successfully saved markdown in "+file+"!")
		static func loadmd(file: String, error:=true):
			var fp=FileAccess.open(file,FileAccess.READ)
			if fp == null:
				if error:
					assert(false, "Error: Cannot find file \""+file+"\", file is not exists or be deleted or moved")
				return null
			var md=MarkdownDocument.new()
			md.text=fp.get_as_text()
			fp.close()
			return md
		func _to_string() -> String:
			return text
	static func link(name: String, link: String) -> String:
		return "["+name+"]("+link+")"
	static func code(language: String, code: String) -> String:
		return "```"+language+"\n"+code+"\n"+"```"
	static func h1(text: String) -> String:
		return "# "+text
	static func h2(text: String) -> String:
		return "## "+text
	static func h3(text: String) -> String:
		return "### "+text

class html extends UnInstantiable:
	class HTMLDocument:
		var text = ""
		func save(file: String, debug:=false):
			var fp=FileAccess.open(file,FileAccess.WRITE)
			if fp==null:
				if debug:
					print("[Info] Open Failed")
				assert(false, "Error: Cannot open file "+file)
			if debug:
				print("[Info] Writing text to "+file)
			fp.store_string(self.text)
			fp.close()
			if debug:
				print("[Info] successfully saved HTML in "+file+"!")
		func preview():
			save("C:/Users/Administrator/Local/Temp/stringtool_preview.html",FileAccess.WRITE)
			OS.shell_open("file:///C:/Users/Administrator/Local/Temp/stringtool_preview.html")
		func _to_string() -> String:
			return self.text
		func add_h1(text: String) -> String:
			var string=html.h1(text)+"\n"
			self.text+=string
			return string
		func add_h2(text: String) -> String:
			var string=html.h2(text)+"\n"
			self.text+=string
			return string
		func add_h3(text: String) -> String:
			var string=html.h3(text)+"\n"
			self.text+=string
			return string
		func to_markdown():
			return self.text.replace("<h1>", "# ").replace("<h2>", "## ").replace("<h3>", "### ").replace("</h1>", "").replace("</h2>", "").replace("</h3>", "")
	static func create_html(code: String) -> HTMLDocument:
		var htm = HTMLDocument.new()
		htm.text=code
		return htm
	static func h1(text: String) -> String:
		return "<h1>"+text+"</h1>"
	static func h2(text: String) -> String:
		return "<h2>"+text+"</h2>"
	static func h3(text: String) -> String:
		return "<h3>"+text+"</h3>"
