class_name EveningSave
extends RefCounted
## 第一晚獨立存檔；只有明確呼叫 write 才會改動檔案。

const SAVE_PATH := "user://first_evening_v1.json"
const BACKUP_PATH := SAVE_PATH + ".bak"
const TEMP_PATH := SAVE_PATH + ".tmp"
const VERSION := 1


static func exists() -> bool:
	return not read().is_empty()


static func read() -> Dictionary:
	var current := _read_path(SAVE_PATH)
	if not current.is_empty():
		return current
	return _read_path(BACKUP_PATH)


static func write(data: Dictionary) -> bool:
	var candidate := data.duplicate(true)
	if not candidate.has("version"):
		candidate["version"] = VERSION
	var normalized := _validate(candidate)
	if normalized.is_empty():
		return false
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("第一晚：暫存檔無法開啟，本次進度仍保留在遊戲中。")
		return false
	file.store_string(JSON.stringify(normalized, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK or _read_path(TEMP_PATH) != normalized:
		_remove_temp()
		return false

	# 只把有效舊主檔移成備份；損毀主檔不能蓋過可用備份。
	var moved_previous := false
	if FileAccess.file_exists(SAVE_PATH):
		if not _read_path(SAVE_PATH).is_empty():
			if FileAccess.file_exists(BACKUP_PATH):
				if DirAccess.remove_absolute(BACKUP_PATH) != OK:
					_remove_temp()
					return false
			if DirAccess.rename_absolute(SAVE_PATH, BACKUP_PATH) != OK:
				_remove_temp()
				return false
			moved_previous = true
		elif DirAccess.remove_absolute(SAVE_PATH) != OK:
			_remove_temp()
			return false

	if DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH) != OK:
		if moved_previous:
			DirAccess.rename_absolute(BACKUP_PATH, SAVE_PATH)
		_remove_temp()
		push_warning("第一晚：存檔未完成，下次仍可讀取上次的有效進度。")
		return false
	return true


static func _read_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var raw := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(raw) != OK:
		return {}
	if typeof(parser.data) != TYPE_DICTIONARY:
		return {}
	return _validate(parser.data)


static func _validate(data: Dictionary) -> Dictionary:
	if not _is_integer(data.get("version")) or data["version"] != VERSION:
		return {}
	var cursor: Variant = data.get("cursor", 0)
	if not _is_integer(cursor) or cursor < 0:
		return {}
	var choices: Variant = data.get("choices", {})
	if typeof(choices) != TYPE_DICTIONARY:
		return {}
	for key in choices:
		if typeof(key) != TYPE_STRING or typeof(choices[key]) != TYPE_STRING:
			return {}
	var complete: Variant = data.get("complete", false)
	if typeof(complete) != TYPE_BOOL:
		return {}
	var settings: Variant = data.get("settings", {})
	if typeof(settings) != TYPE_DICTIONARY:
		return {}
	var muted: Variant = settings.get("muted", false)
	if typeof(muted) != TYPE_BOOL:
		return {}
	return {
		"version": VERSION,
		"cursor": int(cursor),
		"choices": choices.duplicate(true),
		"complete": complete,
		"settings": {"muted": muted},
		"social": _social_state(data.get("social", {})),
	}


static func _social_state(value: Variant) -> Dictionary:
	# 舊版沒有這些欄位也能續讀；壞掉的偏好不應使有效的故事進度失效。
	var clean := {"liked": {}, "saved": {}}
	if not value is Dictionary:
		return clean
	for section in clean:
		var entries: Variant = value.get(section, {})
		if not entries is Dictionary:
			continue
		for key in entries:
			if key is String and entries[key] is bool:
				clean[section][key] = entries[key]
	return clean


static func _is_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	# JSON 以浮點數讀入；拒絕小數、非有限值與超出安全整數的值。
	return typeof(value) == TYPE_FLOAT and is_finite(value) and floor(value) == value \
		and absf(value) <= 9007199254740991.0


static func _remove_temp() -> void:
	if FileAccess.file_exists(TEMP_PATH):
		DirAccess.remove_absolute(TEMP_PATH)
