## A markdown viewer extending RichTextLabel.
##
## [b]Warning[/b]: You can't use [Create Child Node -> MarkdownViewer] to create MarkdownViewer node, two options:[br]
## [br]
## 1. Use RichTextLabel and "extends StringTool.markdown.MarkdownViewer" to instead.[br]
## 2. Create MarkdownViewer object and use add_child(mdv) in script.[br]
@icon("res://addons/string_tool/MarkdownIcon.png")
class_name MarkdownViewer
extends RichTextLabel
@export_multiline var markdown_text: String:
	get:
		return _text
	set(value):
		if value!=_text:
			_text = value
			text=_text
			text_changed.emit(value)
			if text.is_empty():
				empty.emit()
var _text := ""
## @deprecated: this variable is deprecated.
var md: StringTool.markdown.Markdown
## @deprecated: this variable is deprecated.
var label: RichTextLabel
signal empty
signal text_added(add_text:String)
signal text_changed(new_text: String)
func _init(text=null) -> void:
	if text!=null:
		self.markdown_text=text
	else:
		empty.emit()
func add_text(text: String):
	self.text += text
	_text += text
		
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
