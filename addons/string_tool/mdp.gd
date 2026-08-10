@icon("res://addons/string_tool/MarkdownParserIcon.png")
class_name MarkdownParser extends StringTool.UnInstantiable
const ERROR_001 = "Cannot parse "
const ERROR_002 = "Unknown markdown string type"
const ERROR_003 = "Invalid markdown link"
const ERROR_004 = "Invalid markdown heading1"
const ERROR_005 = "Invalid markdown heading2"
const ERROR_006 = "Invalid markdown heading3"
const ERROR_007 = "Invalid markdown heading4"
const ERROR_008 = "Invalid markdown heading5"
const ERROR_009 = "Invalid markdown heading6"
static func parse(markdown:Variant, h1_size:=32, h2_size:=26, h3_size:=22, h4_size:=20, h5_size:=18, h6_size:=16) -> String:
	if markdown is StringTool.markdown.MarkdownDocument or markdown is StringTool.markdown.Markdown:
		markdown=markdown.text
	var lines: Array[String] = []
	var in_code:=false
	for line:String in markdown.split("\n"):
		if not in_code:
			if part_is_link(line):
				lines.append(parse_link(line))
			elif line.begins_with("# "):
				lines.append(parse_h1(line,h1_size))
			elif line.begins_with("## "):
				lines.append(parse_h2(line,h2_size))
			elif line.begins_with("### "):
				lines.append(parse_h3(line,h3_size))
			elif line.begins_with("#### "):
				lines.append(parse_h4(line,h4_size))
			elif line.begins_with("##### "):
				lines.append(parse_h5(line,h5_size))
			elif line.begins_with("###### "):
				lines.append(parse_h6(line,h6_size))
			elif line.begins_with("```"):
				in_code=true
			elif "`" in line:
				lines.append(parse_inline_code(line))
			else:
				lines.append(line)
		else:
			if line.begins_with("```"):
				in_code=false
	return "\n".join(lines)
static func is_link(string: String) -> bool:
	return string.find("(")!=-1 and string.find(")")!=-1 and string.find("[")!=-1 and string.find("]")!=-1 and string.find("(")<string.find(")") and string.find("[")<string.find("]") and string.find("(")>string.find("]") and string.begins_with("[")
static func part_is_link(line: String) -> bool:
	if line.find("(")!=-1 and line.find(")")!=-1 and line.find("[")!=-1 and line.find("]")!=-1:
		return is_link(line.substr(line.find("["),line.find(")")))
	return false
static func parse_link(string: String) -> String:
	if not part_is_link(string):
		push_error(ERROR_001+string, ERROR_003)
		return string
	var result = ""
	var remaining = string

	while remaining.find("[")!=-1 and remaining.find(")")!=-1:
		result += remaining.substr(0,remaining.find("["))
		result += "[url="+remaining.substr(remaining.find("(")+1,remaining.find(")")-remaining.find("("))+"]"+remaining.substr(remaining.find("[")+1,remaining.find("]")-remaining.find("["))+"[/url]"
		remaining = remaining.substr(remaining.find(")")+1)

	result += remaining
	return result
static func parse_h3(string: String, size:=22):
	if not string.begins_with("### "):
		push_error(ERROR_001+string, ERROR_006)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("### ")+4)+"[/font_size]"
static func parse_h2(string: String, size:=26):
	if not string.begins_with("## "):
		push_error(ERROR_001+string, ERROR_005)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("## ")+3)+"[/font_size]"
static func parse_h1(string: String, size:=32):
	if not string.begins_with("# "):
		push_error(ERROR_001+string, ERROR_004)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("# ")+2)+"[/font_size]"
static func parse_h4(string: String, size:=20):
	if not string.begins_with("#### "):
		push_error(ERROR_001+string, ERROR_007)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("#### ")+5)+"[/font_size]"
static func parse_h5(string: String, size:=18):
	if not string.begins_with("##### "):
		push_error(ERROR_001+string, ERROR_008)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("##### ")+6)+"[/font_size]"	
static func parse_h6(string: String, size:=16):
	if not string.begins_with("###### "):
		push_error(ERROR_001+string, ERROR_009)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("###### ")+7)+"[/font_size]"
static func parse_inline_code(string: String) -> String:
	var incode:=false
	var start = -1
	var i = 0
	for chr in string:
		if incode:
			if chr=="`":
				string = string.substr(0,start)+"[code]"+string.substr(start,i-start)+"[/code]"+string.substr(i+1)
				incode = false
		else:
			if chr=="`":
				incode = true
				start=i
		i+=1
	return string
