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
	var list = ""
	for line:String in markdown.split("\n"):
		if not in_code:
			if part_is_link(line):
				lines.append(parse_link(line))
			elif line.begins_with("-") or (line.length() > 1 and line[0].is_valid_int() and line[1] == "."):
				list += line + "\n"
				continue
			elif not list.is_empty():
				lines.append(parse_list(list))
				list = ""
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
			elif "***" in line:
				lines.append(parse_italic_bold(line))
			elif "**" in line:
				lines.append(parse_bold(line))
			elif "*" in line:
				lines.append(parse_italic(line))
			else:
				lines.append(line)
			if not list.is_empty():
				lines.append(parse_list(list))
				list=""
		else:
			if line.begins_with("```"):
				in_code=false
	
	return "\n".join(lines)
static func parse_list(string:String) -> String:
	var result="[list]\n"
	for line in string.split("\n"):
		if line.begins_with("- "):
			result+="[*] "+line.substr(2)+"\n"
		elif line.begins_with("1. ") \
		or line.begins_with("2. ") \
		or line.begins_with("3. "):
			result+="[*] "+line.substr(3)+"\n"
		else:
			result+=line+"\n"

	result+="[/list]"
	return result
static func parse_italic_bold(string: String):
	if "***" not in string:
		return string
	string=string.replace("***","[b][i]")
	string=string.replace("\\[b][i]","***")
	var count = string.count("[b][i]")
	var from = 0
	var codes = 0
	var i = 0
	while string.count("[b][i]")>count/2:
		var from_ = from
		from = string.find("[b][i]",from)+3
		if codes%2==1:
			string=string.substr(0,string.find("[b][i]",from_))+"[/i][/b]"+string.substr(string.find("[b][i]",from_)+6)
		codes+=1
		i+=1
	return string
static func parse_bold(string: String):
	if "**" not in string:
		return string
	string=string.replace("**","[b]")
	string=string.replace("\\[b]","**")
	var count = string.count("[b]")
	var from = 0
	var codes = 0
	var i = 0
	while string.count("[b]")>count/2:
		print(string)
		var from_ = from
		from = string.find("[b]",from)+3
		if codes%2==1:
			string=string.substr(0,string.find("[b]",from_))+"[/b]"+string.substr(string.find("[b]",from_)+3)
		codes+=1
		i+=1
	return string
static func parse_italic(string: String):
	if "*" not in string:
		return string
	string=string.replace("*","[i]")
	string=string.replace("\\[i]","*")
	var count = string.count("[i]")
	var from = 0
	var codes = 0
	var i = 0
	while string.count("[i]")>count/2:
		var from_ = from
		from = string.find("[i]",from)+3
		if codes%2==1:
			string=string.substr(0,string.find("[i]",from_))+"[/i]"+string.substr(string.find("[i]",from_)+3)
		codes+=1
		i+=1
	return string
static func is_link(string: String) -> bool:
	return string.find("(")!=-1 and string.find(")")!=-1 and string.find("[")!=-1 and string.find("]")!=-1 and string.find("(")<string.find(")") and string.find("[")<string.find("]") and string.find("(")>string.find("]") and string.begins_with("[")
static func part_is_link(line: String) -> bool:
	return line.find("(")!=-1 and line.find(")")!=-1 and line.find("[")!=-1 and line.find("]")!=-1 and line.find("(")<line.find(")") and line.find("[")<line.find("]") and line.find("(")>line.find("]")
static func parse_link(string: String) -> String:
	if not part_is_link(string):
		push_error(ERROR_001+string, ERROR_003)
		return string
	var result = ""
	var remaining = string

	while remaining.find("[")!=-1 and remaining.find(")")!=-1:
		result += remaining.substr(0,remaining.find("["))
		result += "[url="+remaining.substr(remaining.find("(")+1,remaining.find(")")-remaining.find("(")-1)+"]"+remaining.substr(remaining.find("[")+1,remaining.find("]")-remaining.find("[")-1)+"[/url]"
		remaining = remaining.substr(remaining.find(")")+1)

	result += remaining
	return result
static func parse_h3(string: String, size:=22):
	size = max(size, 1)
	if not string.begins_with("### "):
		push_error(ERROR_001+string, ERROR_006)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("### ")+4)+"[/font_size]"
static func parse_h2(string: String, size:=26):
	size = max(size, 1)
	if not string.begins_with("## "):
		push_error(ERROR_001+string, ERROR_005)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("## ")+3)+"[/font_size]"
static func parse_h1(string: String, size:=32):
	size = max(size, 1)
	if not string.begins_with("# "):
		push_error(ERROR_001+string, ERROR_004)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("# ")+2)+"[/font_size]"
static func parse_h4(string: String, size:=20):
	size = max(size, 1)
	if not string.begins_with("#### "):
		push_error(ERROR_001+string, ERROR_007)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("#### ")+5)+"[/font_size]"
static func parse_h5(string: String, size:=18):
	size = max(size, 1)
	if not string.begins_with("##### "):
		push_error(ERROR_001+string, ERROR_008)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("##### ")+6)+"[/font_size]"	
static func parse_h6(string: String, size:=16):
	size = max(size, 1)
	if not string.begins_with("###### "):
		push_error(ERROR_001+string, ERROR_009)
		return string		
	return "[font_size="+str(size)+"]"+string.substr(string.find("###### ")+7)+"[/font_size]"
static func parse_inline_code(string: String) -> String:
	string=string.replace("`","[code]")
	var count = string.count("[code]")
	var from = 0
	var codes = 0
	var i = 0
	while string.count("[code]")>count/2:
		var from_ = from
		from = string.find("[code]",from)+8
		if codes%2==1:
			string=string.substr(0,string.find("[code]",from_))+"[/code]"+string.substr(string.find("[code]",from_)+6)
		codes+=1
		i+=1
	return string
