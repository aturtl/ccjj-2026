extends Control


@onready var counter: RichTextLabel = $Counter


func _confidence_updated(value: int):
	counter.text = "CONFIDENCE: "+str(value)


func _ready():
	counter.text = "CONFIDENCE: 0"
	Stats.confidence_updated.connect(_confidence_updated)
