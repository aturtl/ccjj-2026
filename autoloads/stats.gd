extends Node

signal confidence_updated

var confidence: int = 0:
	set(value): # really cool feature i just learned about
		confidence = value
		confidence_updated.emit(value)
