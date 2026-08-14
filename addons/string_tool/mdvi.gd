@tool
extends EditorInspectorPlugin

var added_preview := false
var mdv: MarkdownViewer


func _can_handle(object: Object) -> bool:
	return object is MarkdownViewer


func _parse_begin(object: Object) -> void:
	mdv = object
	added_preview = false

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if name == "bg_color" and not added_preview:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 250)

		var background := ColorRect.new()
		background.color = mdv.bg_color
		var preview := RichTextLabel.new()
		preview.bbcode_enabled = true
		preview.fit_content = true
		preview.text = MarkdownParser.parse(
		mdv.markdown_text,
		mdv.head1_size,
		mdv.head2_size,
		mdv.head3_size,
		mdv.head4_size,
		mdv.head5_size,
		mdv.head6_size
		)
		preview.add_theme_color_override(
		"default_color",
		mdv.text_color
		)
		var style := StyleBoxFlat.new()
		style.bg_color = mdv.bg_color

		preview.add_theme_stylebox_override("normal", style)
		preview.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
		panel.add_child(background)
		panel.add_child(preview)
		add_custom_control(panel)
		added_preview = true
	return false
