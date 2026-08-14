## A markdown viewer extending RichTextLabel.
##
## [b]Warning[/b]: You can't use [Create Child Node -> MarkdownViewer] to create MarkdownViewer node, two options:[br]
## [br]
## 1. Use RichTextLabel and "extends StringTool.markdown.MarkdownViewer" to instead.[br]
## 2. Create MarkdownViewer object and use add_child(mdv) in script.[br]
@tool

@icon("res://addons/string_tool/MarkdownIcon.png")
class_name MarkdownViewer
extends RichTextLabel
@export var markdown_enabled := true:
	get:
		return _mden
	set(value):
		_mden = value
		_update_markdown()
		notify_property_list_changed()
var _mden := true

@export_multiline var markdown_text: String:
	get:
		return _text
	set(value):
		if value != _text:
			_text = value
			_update_markdown()
			text_changed.emit(value)

var _text := ""
@export_group("Heading")
@export var head1_size := 32:
	get:
		return _h1s
	set(value):
		_h1s = max(value, 1)
		_update_markdown()
		heading_convert_rule_changed.emit()
@export var head2_size := 26:
	get:
		return _h2s
	set(value):
		_h2s = max(value, 1)
		_update_markdown()
		heading_convert_rule_changed.emit()
@export var head3_size := 22:
	get:
		return _h3s
	set(value):
		_h3s = max(value, 1)
		_update_markdown()
		heading_convert_rule_changed.emit()
@export var head4_size := 20:
	get:
		return _h4s
	set(value):
		_h4s = max(value, 1)
		_update_markdown()
		heading_convert_rule_changed.emit()
@export var head5_size := 18:
	get:
		return _h5s
	set(value):
		_h5s = max(value, 1)
		_update_markdown()
		heading_convert_rule_changed.emit()
@export var head6_size := 16:
	get:
		return _h6s
	set(value):
		_h6s = max(value, 1)
		_update_markdown()
		heading_convert_rule_changed.emit()
		
var _h1s := 32
var _h2s := 26
var _h3s := 22
var _h4s := 20
var _h5s := 18
var _h6s := 16
@export_group("Preview")
@export_color_no_alpha var bg_color : Color = Color(0,0,0)
@export_color_no_alpha var text_color : Color = Color(1,1,1)
## @deprecated: this variable is deprecated.
var md: StringTool.markdown.Markdown
## @deprecated: this variable is deprecated.
var label: RichTextLabel
signal empty
signal text_added(add_text:String)
signal text_changed(new_text: String)
signal heading_convert_rule_changed
func _ready() -> void:
	bbcode_enabled = true
func _update_markdown() -> void:
	var current_txt := ""

	if _mden:
		current_txt = MarkdownParser.parse(_text, _h1s, _h2s, _h3s, _h4s, _h5s, _h6s)
	else:
		current_txt = _text

	text = current_txt

	if text.is_empty():
		empty.emit()
	
func _init(text=null) -> void:
	if text!=null:
		self.markdown_text=text
	else:
		empty.emit()
func add_text(text: String):
	_text += text
	_update_markdown()
	text_added.emit(text)
	text_changed.emit(_text)
func store_string(string:String):
	self.markdown_text = string
func store_md(md: StringTool.markdown.MarkdownDocument):
	self.markdown_text=str(md)
## @deprecated: Please use store_md() instead bind_md().
func bind_md(md: StringTool.markdown.Markdown):
	self.md=md
	md._bounded=true
	md._viewer=self
## @deprecated: Please use store_string() instead bind_string().
func bind_string(string:String):
	var md=StringTool.markdown.Markdown.new()
	md.text=string
	md._bounded=true
	md._viewer=self
	self.md=md
func clear():
	markdown_text=""
## Put everything if this object to default.[br]
## [br]
## Warning: use to_default clear text won't emit signal empty().
func to_default() -> void:
	_text=""
	super.clear()
	head1_size=32
	head2_size=26
	head3_size=22
	head4_size=20
	head5_size=18
	head6_size=16
