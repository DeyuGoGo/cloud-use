extends SceneTree
## 由 run_evening_systems.ps1 在隔離的 user:// 中執行。

const Save = preload("res://scripts/evening/EveningSave.gd")
const Sound = preload("res://scripts/evening/EveningSound.gd")
var _failures: Array[String] = []
var _assertions := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# 防止直接對正式遊戲的資料目錄執行寫入測試。
	if "run-with-me-evening-tests-" not in OS.get_user_data_dir().to_lower():
		printerr("REFUSED: tests require the isolated PowerShell runner.")
		quit(2)
		return
	_test_save()
	_test_social_state()
	await _test_sound()
	if _failures.is_empty():
		print("PASS: evening systems — %d assertions" % _assertions)
		quit(0)
	else:
		for failure in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _test_save() -> void:
	_put("user://run_save.json", "legacy untouched")
	_check(not Save.exists(), "No save is not resumable")
	_check(Save.read().is_empty(), "No save returns empty Dictionary")
	_check(not FileAccess.file_exists(Save.SAVE_PATH), "Reading does not create a save")
	_check(Save.write({}), "Missing fields receive defaults on explicit write")
	_check(Save.read() == {"version": 1, "cursor": 0, "choices": {}, "complete": false, "settings": {"muted": false}, "social": {"liked": {}, "saved": {}}}, "Defaults are normalized")
	var first := {"cursor": 8, "choices": {"evening": "walk"}, "complete": false, "settings": {"muted": true}}
	_check(Save.write(first), "First choice saves")
	_check(Save.exists(), "Valid save is resumable")
	_check(Save.read()["cursor"] is int, "JSON cursor is returned as int")
	_check(Save.read()["choices"] == first["choices"], "Choices survive roundtrip")
	_check(Save.read()["settings"]["muted"] == true, "Mute setting survives roundtrip")
	_check(not FileAccess.file_exists(Save.TEMP_PATH), "Successful save removes temp through promotion")
	var second := {"cursor": 15, "choices": {"evening": "photo"}, "complete": true}
	_check(Save.write(second), "Later progress saves")
	_check(_json(Save.BACKUP_PATH)["cursor"] == 8, "Backup is the previous committed beat")
	var good_primary := FileAccess.get_file_as_string(Save.SAVE_PATH)
	var invalid_values: Array = [
		"{broken", "[]", "null", '{"version":2}', '{"cursor":0}',
		'{"version":"1"}', '{"version":1,"cursor":-1}',
		'{"version":1,"cursor":2.4}', '{"version":1,"cursor":true}',
		'{"version":1,"choices":[]}', '{"version":1,"choices":{"x":1}}',
		'{"version":1,"complete":"false"}', '{"version":1,"settings":[]}',
		'{"version":1,"settings":{"muted":1}}',
	]
	for invalid in invalid_values:
		_put(Save.SAVE_PATH, invalid)
		_check(Save.read().get("cursor", -1) == 8, "Invalid primary falls back: " + invalid)
		_check(Save.exists(), "Backup makes corrupted primary resumable")
	_put(Save.SAVE_PATH, good_primary)
	_check(not Save.write({"cursor": -1}), "Invalid writes are rejected")
	_check(not Save.write({"choices": {"x": false}}), "Invalid choice values are rejected")
	_check(not Save.write({"settings": {"muted": "yes"}}), "Invalid mute value is rejected")
	_check(FileAccess.get_file_as_string(Save.SAVE_PATH) == good_primary, "Rejected writes preserve the old file")
	# 寫暫存失敗時，舊主檔與備份都必須保持可讀。
	DirAccess.make_dir_absolute(Save.TEMP_PATH)
	_check(not Save.write({"cursor": 20}), "Filesystem write failure returns false")
	_check(Save.read()["cursor"] == 15, "Write failure preserves committed progress")
	DirAccess.remove_absolute(Save.TEMP_PATH)
	_put(Save.SAVE_PATH, "{bad")
	_check(Save.write({"cursor": 22}), "Can save after reading a recovered backup")
	_check(_json(Save.BACKUP_PATH)["cursor"] == 8, "Corrupt primary never replaces valid backup")
	DirAccess.remove_absolute(Save.SAVE_PATH)
	_put(Save.TEMP_PATH, '{"version":1,"cursor":99}')
	_check(Save.read()["cursor"] == 8, "Interrupted promotion reads backup, never unfinished temp")
	_put(Save.BACKUP_PATH, "{also bad")
	_check(Save.read().is_empty() and not Save.exists(), "Both bad files do not expose Continue")
	_check(FileAccess.get_file_as_string("user://run_save.json") == "legacy untouched", "Legacy save is never changed")
	DirAccess.remove_absolute(Save.TEMP_PATH)


func _test_social_state() -> void:
	_put(Save.SAVE_PATH, '{"version":1,"cursor":41,"choices":{"photo_choice":"candid"}}')
	var older := Save.read()
	_check(older["cursor"] == 41 and older["social"] == {"liked": {}, "saved": {}}, "Old M1 saves resume without social preferences")
	older["social"] = {"liked": {"before_04": true}, "saved": {"phone_photo_candid": true}}
	_check(Save.write(older), "Alive preferences can be committed with the current beat")
	var restored := Save.read()
	_check(restored["social"] == older["social"], "Likes and bookmarks survive reload")
	_check(restored["cursor"] == 41 and restored["choices"] == older["choices"], "Social changes preserve story progress and choices")
	restored["social"]["liked"]["before_04"] = false
	Save.write(restored)
	_check(not Save.read()["social"]["liked"]["before_04"], "Unlike survives reload")
	restored["social"] = {"liked": {"before_04": true, "bad": "yes"}, "saved": [], "unused": 1}
	Save.write(restored)
	_check(Save.read()["social"] == {"liked": {"before_04": true}, "saved": {}}, "Malformed optional preferences are sanitized independently")
	restored["social"] = "broken"
	Save.write(restored)
	_check(Save.read()["cursor"] == 41 and Save.read()["social"] == {"liked": {}, "saved": {}}, "Malformed social data does not discard valid narrative progress")
	_check(FileAccess.get_file_as_string("user://run_save.json") == "legacy untouched", "Alive preferences never write legacy save")


func _test_sound() -> void:
	var sound := Sound.new()
	sound.set_muted(true)
	sound.set_place("river")
	root.add_child(sound)
	await process_frame
	for place in ["river", "store", "room", "city"]:
		var stream: AudioStreamWAV = sound._get_ambience(place)
		_check(stream.data.size() > 0 and stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Loop generated: " + place)
		_check(stream.data.decode_s16(0) == 0, "Loop starts at zero: " + place)
	for kind in ["footsteps", "drink", "chime", "notification"]:
		var stream: AudioStreamWAV = sound._make_cue(kind)
		var peak := 0
		for offset in range(0, stream.data.size(), 2):
			peak = maxi(peak, absi(stream.data.decode_s16(offset)))
		_check(peak > 0 and peak < 10000, "Cue is present and conservative: " + kind)
		sound.cue(kind)
	_check(sound._cue_index == 0, "Muted cues are skipped")
	sound.set_muted(false)
	sound.cue("notification")
	_check(sound._cue_index == 1, "Unmuting allows cues")
	for place in ["store", "river", "city", "room"]:
		sound.set_place(place)
		await process_frame
	await create_timer(0.85).timeout
	var active_count := 0
	for player in sound._ambience:
		if player.playing:
			active_count += 1
	_check(active_count == 1, "Rapid scene switches settle to a single ambience")
	sound.set_muted(true)
	await create_timer(0.25).timeout
	for player in sound._ambience:
		_check(player.volume_db <= -79.0, "Muting fades ambience to silence")
	sound.set_place("silent")
	sound.set_muted(false)
	await create_timer(0.25).timeout
	for player in sound._ambience:
		_check(player.volume_db <= -79.0, "Silent scene stays silent after unmuting")
	# 同一畫格內重用音效池，並在播放途中切走，不能留下播放資源。
	sound.set_place("city")
	for index in 12:
		sound.cue("notification")
	var audio_refs := _audio_refs(sound)
	root.remove_child(sound)
	for player in sound._ambience + sound._cues:
		_check(player.stream == null and not player.has_stream_playback(), "Exiting sound detaches each playback and stream")
	_check(sound._cache.is_empty(), "Exiting sound releases synthesized stream cache")
	sound.queue_free()
	_check(await _await_audio_release(audio_refs), "Audio thread releases WAV and playback references after scene exit")


func _audio_refs(sound: Node) -> Array[WeakRef]:
	var references: Array[WeakRef] = []
	for stream in sound._cache.values():
		references.append(weakref(stream))
	for player in sound._ambience + sound._cues:
		if player.has_stream_playback():
			references.append(weakref(player.get_stream_playback()))
	return references


func _await_audio_release(references: Array[WeakRef]) -> bool:
	var deadline := Time.get_ticks_msec() + 1000
	while Time.get_ticks_msec() < deadline:
		await create_timer(0.025).timeout
		var remaining := false
		for reference in references:
			if reference.get_ref() != null:
				remaining = true
		if not remaining:
			return true
	return false


func _put(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()


func _json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func _check(condition: bool, description: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(description)
