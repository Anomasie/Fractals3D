extends MarginContainer

signal close_me
#signal switch

signal changed

@onready var Main = $Content/MarginContainer/AdvancedOptions/Main

@onready var TranslationEdits = [
	$Content/MarginContainer/AdvancedOptions/Main/TranslationBox/TranslationX,
	$Content/MarginContainer/AdvancedOptions/Main/TranslationBox/TranslationY,
	$Content/MarginContainer/AdvancedOptions/Main/TranslationBox/TranslationZ
]
@onready var ContractionEdits = [
	$Content/MarginContainer/AdvancedOptions/Main/ContractionBox/ContractionX,
	$Content/MarginContainer/AdvancedOptions/Main/ContractionBox/ContractionY,
	$Content/MarginContainer/AdvancedOptions/Main/ContractionBox/ContractionZ
]
@onready var RotationEdits = [
	$Content/MarginContainer/AdvancedOptions/Main/RotationBox/RotationX,
	$Content/MarginContainer/AdvancedOptions/Main/RotationBox/RotationY,
	$Content/MarginContainer/AdvancedOptions/Main/RotationBox/RotationZ
]

@onready var CloseButton = $ElseBox/CloseButton
@onready var MatrixButton = $ElseBox/MatrixButton

var disabled = false

func _ready():
	# connect
	for node in TranslationEdits+ContractionEdits+RotationEdits:
		node.text_submitted.connect(_on_edit_text_submitted.bind(node))
	
	# tooltips
	Global.tooltip_nodes.append_array(
		[
			CloseButton, MatrixButton
		] + TranslationEdits + ContractionEdits + RotationEdits
	)

func open(contraction) -> void:
	load_ui(contraction)
	show()

func load_ui(contraction) -> void:
	TranslationEdits[0].placeholder_text = str(contraction.translation.x)
	TranslationEdits[1].placeholder_text = str(contraction.translation.y)
	TranslationEdits[2].placeholder_text = str(contraction.translation.z)
	
	ContractionEdits[0].placeholder_text = str(contraction.scale.x)
	ContractionEdits[1].placeholder_text = str(contraction.scale.y)
	ContractionEdits[2].placeholder_text = str(contraction.scale.z)
	
	RotationEdits[0].placeholder_text = str(contraction.rotation.x/PI*180)
	RotationEdits[1].placeholder_text = str(contraction.rotation.y/PI*180)
	RotationEdits[2].placeholder_text = str(contraction.rotation.z/PI*180)

func read_ui() -> Contraction:
	var contraction = Contraction.new()
	contraction.translation = Vector3(
		float(TranslationEdits[0].placeholder_text),
		float(TranslationEdits[1].placeholder_text),
		float(TranslationEdits[2].placeholder_text)
	)
	contraction.scale = Vector3(
		float(ContractionEdits[0].placeholder_text),
		float(ContractionEdits[1].placeholder_text),
		float(ContractionEdits[2].placeholder_text)
	)
	contraction.rotation = Vector3(
		float(RotationEdits[0].placeholder_text)*PI/180,
		float(RotationEdits[1].placeholder_text)*PI/180,
		float(RotationEdits[2].placeholder_text)*PI/180
	)
	contraction.calculate_matrix()
	return contraction

func _on_close_button_pressed():
	close_me.emit()

func _on_matrix_button_pressed():
	print("ERROR in GeometricOptions.gd: On matrix button pressed! Isn't that invisible?")
	#switch.emit()

# values changed

func _on_edit_text_submitted(new_text, Edit) -> void:
	if new_text:
		var value = float(new_text)
		Edit.placeholder_text = str(value)
		Edit.text = ""
		changed.emit()
	Edit.release_focus()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			# settings
			for i in len(TranslationEdits):
				TranslationEdits[i].tooltip_text = "Verschiebung entlang der "+["X","Y","Z"][i]+"-Achse"
				ContractionEdits[i].tooltip_text = "Verzerrung entlang der "+["X","Y","Z"][i]+"-Achse"
				RotationEdits[i].tooltip_text = "Rotation in °"
			# buttons
			CloseButton.tooltip_text = "erweiterte Optionen schließen"
			MatrixButton.tooltip_text = "Matrix-Ansicht"
		_:
			# settings
			for i in len(TranslationEdits):
				TranslationEdits[i].tooltip_text = "enter translation in "+["X","Y","Z"][i]+"-axis"
				ContractionEdits[i].tooltip_text = "enter scale in "+["X","Y","Z"][i]+"-axis"
				RotationEdits[i].tooltip_text = "enter rotation in °"
			# buttons
			CloseButton.tooltip_text = "close advanced options"
			MatrixButton.tooltip_text = "swtich to matrix view"
