class_name Data
extends Resource

const FILE_LOCATION := "user://savedata.tres"

@export var username : String = "Player"


static func load_data() -> Data:
	if FileAccess.file_exists(FILE_LOCATION):
		return ResourceLoader.load(FILE_LOCATION) as Data
	else:
		var data := Data.new()
		data.save_data()
		return data


func save_data() -> void:
	var err := ResourceSaver.save(self, FILE_LOCATION)
	assert(err == OK, "Failed to save!")
