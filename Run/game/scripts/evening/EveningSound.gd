class_name EveningSound
extends Node
## 無外部音檔的夜晚底聲。聲音只補觸感，靜音也能讀完所有內容。

const SAMPLE_RATE := 16000
const AMBIENCE_DB := -25.0
const CUE_DB := -19.0
const SILENT_DB := -80.0

var _muted := false
var _place := ""
var _current := -1
var _ambience: Array[AudioStreamPlayer] = []
var _cues: Array[AudioStreamPlayer] = []
var _cache: Dictionary = {}
var _transition: Tween
var _cue_index := 0


func _ready() -> void:
	_prepare_players()
	if not _place.is_empty():
		var initial_place := _place
		_place = ""
		set_place(initial_place)


func _exit_tree() -> void:
	shutdown()


func shutdown() -> void:
	# 主動解除所有播放與資源參照，讓切場後的音頻更新能完成回收。
	if is_instance_valid(_transition):
		_transition.kill()
	_transition = null
	for player in _ambience + _cues:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_cache.clear()
	_current = -1
	_place = ""


func set_place(place: String) -> void:
	var sound_place := _sound_place(place)
	if _place == sound_place:
		return
	_place = sound_place
	if not is_inside_tree():
		return
	_prepare_players()
	if is_instance_valid(_transition):
		_transition.kill()
	_transition = create_tween().set_parallel(true)
	_transition.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var previous := _current
	_current = 0 if _current != 0 else 1
	var incoming := _ambience[_current]
	incoming.stop()
	incoming.volume_db = SILENT_DB
	if sound_place != "silent":
		incoming.stream = _get_ambience(sound_place)
		incoming.play()
		_transition.tween_property(incoming, "volume_db", SILENT_DB if _muted else AMBIENCE_DB, 0.7)
	if previous >= 0:
		var outgoing := _ambience[previous]
		_transition.tween_property(outgoing, "volume_db", SILENT_DB, 0.7)
		_transition.chain().tween_callback(outgoing.stop)


func cue(kind: String) -> void:
	if _muted or not is_inside_tree() or kind.is_empty():
		return
	_prepare_players()
	var player := _cues[_cue_index % _cues.size()]
	_cue_index += 1
	var cache_key := "cue:" + kind
	if not _cache.has(cache_key):
		_cache[cache_key] = _make_cue(kind)
	player.stop()
	player.stream = _cache[cache_key]
	player.volume_db = CUE_DB
	player.play()


func set_muted(value: bool) -> void:
	_muted = value
	if not is_inside_tree():
		return
	if is_instance_valid(_transition):
		_transition.kill()
	_transition = create_tween().set_parallel(true)
	for index in _ambience.size():
		var target := AMBIENCE_DB if not _muted and index == _current and _place != "silent" else SILENT_DB
		_transition.tween_property(_ambience[index], "volume_db", target, 0.18)
		if index != _current or _place == "silent":
			_transition.tween_callback(_ambience[index].stop).set_delay(0.18)
	if _muted:
		for player in _cues:
			_transition.tween_property(player, "volume_db", SILENT_DB, 0.08)


func _prepare_players() -> void:
	if not _ambience.is_empty():
		return
	for index in 2:
		var player := AudioStreamPlayer.new()
		player.name = "NightAmbience%d" % index
		player.volume_db = SILENT_DB
		add_child(player)
		_ambience.append(player)
	for index in 3:
		var player := AudioStreamPlayer.new()
		player.name = "NightCue%d" % index
		player.volume_db = CUE_DB
		add_child(player)
		_cues.append(player)


func _sound_place(place: String) -> String:
	var lowered := place.to_lower()
	if lowered in ["", "silent", "black", "end", "none"]:
		return "silent"
	if "river" in lowered or "run" in lowered or "riverside" in lowered:
		return "river"
	if "store" in lowered or "shop" in lowered or "convenience" in lowered:
		return "store"
	if "home" in lowered or "room" in lowered or "phone" in lowered or "morning" in lowered:
		return "room"
	return "city"


func _get_ambience(place: String) -> AudioStreamWAV:
	var cache_key := "place:" + place
	if _cache.has(cache_key):
		return _cache[cache_key]
	var duration := 4.0
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(place)
	var noise := 0.0
	for index in count:
		var time := float(index) / SAMPLE_RATE
		noise = lerpf(noise, rng.randf_range(-1.0, 1.0), 0.035 if place == "river" else 0.11)
		var value := noise * 0.18
		match place:
			"river":
				value *= 0.75 + 0.25 * sin(TAU * time / duration)
			"store":
				value += sin(TAU * 60.0 * time) * 0.018 + sin(TAU * 120.0 * time) * 0.006
			"room":
				value *= 0.25
			"city":
				value += sin(TAU * 45.0 * time) * 0.015 * (0.65 + 0.35 * sin(TAU * time / duration))
		# 接縫兩端歸零，避免短循環的啪聲。
		var edge := minf(1.0, minf(time / 0.035, (duration - time) / 0.035))
		samples[index] = value * edge
	var stream := _to_wav(samples, true)
	_cache[cache_key] = stream
	return stream


func _make_cue(kind: String) -> AudioStreamWAV:
	var count := int(SAMPLE_RATE * 0.8)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(kind)
	var noise := 0.0
	for index in count:
		var time := float(index) / SAMPLE_RATE
		var value := 0.0
		noise = lerpf(noise, rng.randf_range(-1.0, 1.0), 0.4)
		match kind:
			"footstep", "footsteps", "walk":
				for onset in [0.02, 0.34]:
					var step_time: float = time - onset
					if step_time > 0.0:
						value += (noise * 0.17 + sin(TAU * 94.0 * step_time) * 0.09) * exp(-step_time * 35.0) * minf(step_time * 130.0, 1.0)
			"drink", "can", "touch", "cup":
				value = (noise * 0.15 + sin(TAU * 340.0 * time) * 0.045) * exp(-time * 19.0) * minf(time * 100.0, 1.0)
			"chime", "door":
				value = sin(TAU * 659.25 * time) * exp(-time * 8.0) * 0.12
				if time > 0.18:
					value += sin(TAU * 523.25 * (time - 0.18)) * exp(-(time - 0.18) * 8.0) * 0.1 * minf((time - 0.18) * 120.0, 1.0)
			_:
				value = (sin(TAU * 740.0 * time) * 0.075 + sin(TAU * 987.77 * time) * 0.035) * exp(-time * 12.0)
		value *= minf(time * 120.0, 1.0) * minf((0.8 - time) * 80.0, 1.0)
		samples[index] = value
	return _to_wav(samples, false)


func _to_wav(samples: PackedFloat32Array, looped: bool) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for index in samples.size():
		var sample := int(clampf(samples[index], -1.0, 1.0) * 32767.0)
		bytes.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream
