@tool
extends EditorPlugin
class_name StringToolEditorPlugin

static var instance: StringToolEditorPlugin
var inspector_plugin = preload("res://addons/string_tool/mdvi.gd").new()
	
func _enter_tree() -> void:
	add_inspector_plugin(inspector_plugin)
	instance = self

func _exit_tree() -> void:
	instance = null
	remove_inspector_plugin(inspector_plugin)
func create_preview_window(
	text: String,
	width: int,
	height: int,
	bg_color: Color,
	text_color: Color
) -> void:
	var window := Window.new()
	window.title = "Markdown Preview"
	window.size = Vector2i(width, height)

	var color_rect := ColorRect.new()
	color_rect.color = bg_color
	window.add_child(color_rect)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text
	label.add_theme_color_override("default_color", text_color)

	color_rect.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	get_editor_interface().get_base_control().add_child(window)
	window.popup_centered()
