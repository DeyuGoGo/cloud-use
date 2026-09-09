extends SceneTree
## 使用真場景、輸入事件與存檔，驗證玩家實際閱讀的流程。

const Save = preload("res://scripts/evening/EveningSave.gd")
var _failures: Array[String] = []
var _assertions := 0
var _runner: Control
var _router: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if "run-with-me-evening-tests-" not in OS.get_user_data_dir().to_lower():
		printerr("REFUSED: flow tests require the isolated PowerShell runner.")
		quit(2)
		return
	_router = root.get_node("SceneRouter")
	await _test_new_game_and_controls()
	await _test_path({"jason_choice": "tease", "photo_choice": "candid", "reply_choice": "yijun"}, true)
	await _test_completed_resume()
	_router.new_game()
	await scene_changed
	_runner = current_scene
	await _test_path({"jason_choice": "admit", "photo_choice": "posed", "reply_choice": "ray"}, false)
	await _test_scene_actions()
	await _test_alive_navigation()
	await _test_visual_transitions()
	var audio_refs := _audio_refs(_runner._sound)
	current_scene.queue_free()
	_runner = null
	_check(await _await_audio_release(audio_refs), "Final scene releases its audio resources before process exit")
	if _failures.is_empty():
		print("PASS: evening flow — %d assertions; 2 routes through real progression" % _assertions)
		quit(0)
	else:
		for failure in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _test_new_game_and_controls() -> void:
	_router.back_to_title()
	await scene_changed
	_check(_find_button(current_scene, "繼續這個晚上").disabled, "Continue is disabled without valid progress")
	Save.write({"cursor": 17, "choices": {}, "settings": {"muted": true}})
	var previous := FileAccess.get_file_as_string(Save.SAVE_PATH)
	_find_button(current_scene, "開始這個晚上").grab_focus()
	await _press_key(KEY_ENTER)
	_runner = current_scene
	_check(_runner.name == "FirstEvening", "Enter on focused title button opens the evening")
	_check(FileAccess.get_file_as_string(Save.SAVE_PATH) == previous, "Starting over preserves the previous save")
	_check(_runner.cursor == 0 and _runner.decisions.is_empty(), "New game starts fresh in memory")
	_runner._toggle_volume()
	_check(FileAccess.get_file_as_string(Save.SAVE_PATH) == previous, "Changing sound before the first beat does not overwrite progress")
	# 排除首次圖片載入耗時，固定字稿在剛開始播放的狀態。
	_runner.set_process(false)
	_runner._show_current()
	_runner._advance.grab_focus()
	await _press_key(KEY_SPACE)
	_check(_runner.cursor == 0 and not _runner._typing, "Space on Continue first reveals current dialogue")
	_check(FileAccess.get_file_as_string(Save.SAVE_PATH) == previous, "Revealing text does not overwrite progress")
	await _press_key(KEY_SPACE)
	_check(_runner.cursor == 1 and Save.read()["cursor"] == 1, "Second Space advances and saves the first clean beat")
	var before: int = _runner.cursor
	await _press_key(KEY_ESCAPE)
	_check(_runner._paused, "Escape opens pause")
	_runner._next()
	_check(_runner.cursor == before, "Pause prevents direct progression")
	_check(_focus_inside_modal(), "Pause transfers keyboard focus into the modal")
	for index in 5:
		await _press_key(KEY_TAB)
		_check(_focus_inside_modal(), "Tab stays inside pause modal (%d)" % index)
	_find_button(_runner._modal, "回到這個晚上").grab_focus()
	await _press_key(KEY_ENTER)
	_check(not _runner._paused and _runner.cursor == before, "Focused pause Return accepts Enter without advancing story")
	await _press_key(KEY_L)
	_check(_runner._paused, "L opens dialogue history")
	_check(_focus_inside_modal(), "History transfers focus into the modal")
	await _press_key(KEY_ESCAPE)
	_check(not _runner._paused, "Escape dismisses history")
	_check(root.gui_get_focus_owner() != null, "Closing a modal restores usable keyboard focus")
	_runner.set_process(true)


func _test_path(route: Dictionary, resume_midway: bool) -> void:
	var guard := 0
	var branch_count := 0
	while not _runner.finished and guard < _runner.beats.size() * 3:
		if not await _await_scene_action():
			return
		guard += 1
		var beat: Dictionary = _runner._active
		var beat_id: String = str(beat["id"])
		var options: Array = beat.get("choices", [])
		if not options.is_empty():
			var before: int = _runner.cursor
			_runner._next()
			_check(_runner.cursor == before, "Continue cannot skip unanswered choice: " + beat_id)
			var wanted: String = route[beat_id]
			var option_index := -1
			for index in options.size():
				if options[index]["value"] == wanted:
					option_index = index
			_check(option_index >= 0, "Route choice exists: " + beat_id)
			if option_index < 0:
				return
			_find_choice_button(_runner._choices, wanted).grab_focus()
			await _press_key(KEY_SPACE if branch_count % 2 == 0 else KEY_ENTER)
			branch_count += 1
			_check(_runner.decisions.get(beat_id) == wanted, "Keyboard commits focused choice: " + beat_id)
			_check(Save.read()["choices"].get(beat_id) == wanted, "Choice is persisted: " + beat_id)
			_check(_runner.cursor > before, "Choice advances through the real callback: " + beat_id)
			if _runner.cursor <= before:
				return
			if resume_midway and beat_id in ["jason_choice", "reply_choice"]:
				await _resume_and_compare()
		else:
			# 兩次 _next 分別顯示全文與推進，保留真實文字播放的行為。
			if _runner._typing:
				_runner._next()
			_runner._next()
			await process_frame
	_check(_runner.finished, "Route reaches completion through normal controls")
	_check(branch_count == 3, "All three choices were explicitly answered")
	_check(Save.read().get("complete", false), "Ending persists completion")
	_check(Save.read()["choices"] == route, "Completed save preserves every decision")
	var shown_ids: Array[String] = []
	for index in _runner.visited:
		shown_ids.append(_runner.beats[index]["id"])
	var expected := [
		"jason_recall_" + route["jason_choice"],
		"phone_photo_" + route["photo_choice"],
		"reply_" + route["reply_choice"] + "_01",
		"end_" + route["reply_choice"],
	]
	for beat_id in expected:
		_check(shown_ids.has(beat_id), "Chosen consequence is in history: " + beat_id)
	var excluded := [
		"jason_recall_" + ("admit" if route["jason_choice"] == "tease" else "tease"),
		"phone_photo_" + ("posed" if route["photo_choice"] == "candid" else "candid"),
		"end_" + ("ray" if route["reply_choice"] == "yijun" else "yijun"),
	]
	for beat_id in excluded:
		_check(not shown_ids.has(beat_id), "Unchosen consequence is absent from history: " + beat_id)


func _test_scene_actions() -> void:
	var seated_image := 0
	for step in [
		{"id":"store_02", "next":"store_03", "before":0, "after":1},
		{"id":"store_04", "next":"store_05", "before":2, "after":3},
	]:
		var beat_id: String = step["id"]
		var index := _story_index(beat_id)
		_check(index >= 0, "Scene action exists: " + beat_id)
		if index < 0:
			return
		_runner.cursor = index
		_runner.finished = false
		_runner._rebuild_history()
		_runner._show_current()
		await process_frame
		var buttons := _visible_scene_buttons()
		_check(buttons.size() == 1, "Scene action has exactly one visible scene control: " + beat_id)
		_check(not _runner._advance.is_visible_in_tree(), "Scene action has no duplicate Continue button: " + beat_id)
		_check(not _runner._typing and _runner._dialogue.visible_characters == -1, "Invitation is fully visible before its action: " + beat_id)
		_check(_runner._active.get("choices", []).is_empty(), "Linear interaction is not presented as a branch: " + beat_id)
		_check(_runner._bg.get_meta("action_frame", -1) == step["before"], "Invitation shows its expected starting image: " + beat_id)
		if buttons.size() != 1:
			return
		var action: Button = buttons[0]
		_check(action.get_meta("scene_action", "") == beat_id, "The visible action targets this invitation: " + beat_id)
		var prior_image := _image_hash(_runner._bg.texture)
		var prior_decisions: Dictionary = _runner.decisions.duplicate(true)
		if beat_id == "store_02":
			action.grab_focus()
			await _press_key(KEY_SPACE)
		else:
			await _click_button(action)
		_check(_runner.cursor == index + 1 and _runner._active["id"] == step["next"], "One activation commits the next beat: " + beat_id)
		_check(Save.read()["cursor"] == index + 1, "Action result is saved before the crossfade finishes: " + beat_id)
		_check(_runner.decisions == prior_decisions and Save.read()["choices"] == prior_decisions, "Scene action does not add or alter decisions: " + beat_id)
		_check(_runner._action_in_progress, "Action starts a visible transition: " + beat_id)
		_runner._next()
		_runner._next()
		_check(_runner.cursor == index + 1, "Repeated activation cannot skip the action result: " + beat_id)
		if beat_id == "store_02":
			await _press_key(KEY_ESCAPE)
			_check(_runner._paused and _runner._action_tween != null and not _runner._action_tween.is_running(), "Pause suspends the scene-action crossfade")
			await create_timer(0.55).timeout
			_check(_runner._action_in_progress and _runner.cursor == index + 1, "Paused action stays in place beyond its normal duration")
			await _press_key(KEY_ESCAPE)
			_check(not _runner._paused, "Closing pause resumes the scene action")
		if not await _await_scene_action():
			return
		_check(_runner._action_layer.get_child_count() == 0, "Completed action removes its transition overlay: " + beat_id)
		_check(_runner._bg.get_meta("action_frame", -1) == step["after"], "Action displays its resulting frame: " + beat_id)
		var result_image := _image_hash(_runner._bg.texture)
		_check(prior_image != 0 and result_image != 0 and result_image != prior_image, "Action changes actual image pixels rather than only its label: " + beat_id)
		if beat_id == "store_02":
			seated_image = result_image
		else:
			_check(result_image != seated_image, "Receiving water has a different visible result from sitting down")
		await _resume_and_compare()
		_check(not _runner._action_in_progress, "Resume reconstructs the result without replaying its action: " + beat_id)
		_check(_runner._action_layer.get_child_count() == 0, "Resume has no stale action overlay: " + beat_id)
		_check(_runner._bg.get_meta("action_frame", -1) == step["after"] and _image_hash(_runner._bg.texture) == result_image, "Resume preserves the exact resulting action image: " + beat_id)
	# 水在 05、06 拍仍拿著；07 拍飲水後回到坐姿，08 拍回到正常多人場面。
	var received_image := _image_hash(_runner._bg.texture)
	for continuation in [
		{"id":"store_06", "frame":3, "image":received_image},
		{"id":"store_07", "frame":1, "image":seated_image},
		{"id":"store_08", "frame":-1, "image":0},
	]:
		if _runner._typing:
			_runner._next()
		_runner._next()
		if not await _await_scene_action():
			return
		_check(_runner._active["id"] == continuation["id"] and _runner._bg.get_meta("action_frame", -1) == continuation["frame"], "Action image follows scene continuity: " + str(continuation["id"]))
		if continuation["image"] != 0:
			_check(_image_hash(_runner._bg.texture) == continuation["image"], "Continuing dialogue retains the expected physical state: " + str(continuation["id"]))
	_check(_visible_scene_buttons().is_empty() and _runner._advance.is_visible_in_tree(), "Normal scene removes action hotspots and restores ordinary reading")
	_check(_runner._action_layer.get_child_count() == 0, "Normal scene has no leftover action overlay")
	_check(_runner._bg.texture == _runner._texture("res://art/bg/store.png") and _runner._actors.get_child_count() == 2, "Normal scene restores its background and two-person staging")


func _story_index(beat_id: String) -> int:
	for index in _runner.beats.size():
		if _runner.beats[index]["id"] == beat_id:
			return index
	return -1


func _visible_scene_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for button in _runner._choices.find_children("*", "Button", true, false):
		if button.is_visible_in_tree():
			buttons.append(button)
	return buttons


func _image_hash(texture: Texture2D) -> int:
	if texture == null:
		return 0
	var picture := texture.get_image()
	return 0 if picture == null else hash(picture.get_data())


func _await_scene_action() -> bool:
	if not _runner._action_in_progress:
		return true
	var deadline := Time.get_ticks_msec() + 2000
	while _runner._action_in_progress and Time.get_ticks_msec() < deadline:
		await create_timer(0.01).timeout
	var completed: bool = not _runner._action_in_progress
	_check(completed, "Scene-action transition finishes and releases its progression guard")
	return completed


func _resume_and_compare() -> void:
	var prior_cursor: int = _runner.cursor
	var prior_decisions: Dictionary = _runner.decisions.duplicate(true)
	var prior_history: Array = _runner.visited.duplicate()
	var prior_beat: String = _runner._active["id"]
	var prior_settings: Dictionary = _runner.settings.duplicate(true)
	_router.back_to_title()
	await scene_changed
	var resume := _find_button(current_scene, "繼續這個晚上")
	_check(not resume.disabled, "Continue becomes available after progression")
	resume.grab_focus()
	await _press_key(KEY_ENTER)
	_runner = current_scene
	_check(_runner.cursor == prior_cursor and _runner._active["id"] == prior_beat, "Continue resumes the exact displayed beat")
	_check(_runner.decisions == prior_decisions, "Continue restores decisions")
	_check(_runner.visited == prior_history, "Continue reconstructs only the previously visited branch")
	_check(_runner.settings == prior_settings, "Continue restores sound setting")
	_check(not _router.evening_resume, "Resume request is consumed after loading")


func _test_completed_resume() -> void:
	var completed := FileAccess.get_file_as_string(Save.SAVE_PATH)
	_router.back_to_title()
	await scene_changed
	_router.continue_game()
	await scene_changed
	_runner = current_scene
	_check(_runner.finished, "Continue on completed save opens the ending")
	_check(not _runner._advance.visible, "Completed story cannot advance into invalid beats")
	_check(_find_button(_runner, "回到標題") != null, "Ending provides an exit to title")
	_check(FileAccess.get_file_as_string(Save.SAVE_PATH) == completed, "Loading completion does not rewrite the save")


func _test_visual_transitions() -> void:
	# 只在隔離流程中替換記憶體內容，確保新畫面類型不依賴指定 beat ID。
	_runner.beats = [
		{"id":"test_record","scene":"river","bg":"embankment","speaker":"旁白","text":"","visual":"run_record","cast":["ray"]},
		{"id":"test_invite","scene":"home","bg":"apartment","speaker":"立翔","text":"原來不用先報名。","visual":"invite","visual_data":{"location":"測試集合點","time":"20:10"}},
		{"id":"test_feed","scene":"home","bg":"apartment","speaker":"旁白","text":"","kind":"phone","visual":"feed","visual_data":{"caption":"週五見。"}},
		{"id":"test_selected","scene":"store","bg":"store","speaker":"Ray","text":"就這張。","visual":"selected_photo"},
		{"id":"test_preview","scene":"store","bg":"store","speaker":"旁白","text":"","visual":"photo_preview","visual_data":{"photo":"posed"}},
		{"id":"test_scene","scene":"store","bg":"store","speaker":"Ray","text":"走吧。","cast":["ray"]},
		{"id":"test_phone","scene":"home","bg":"apartment","kind":"phone","thread":"Ray","speaker":"Ray","text":"到了。"},
		{"id":"test_silent_scene","scene":"home","bg":"apartment","speaker":"旁白","text":""},
	]
	_runner.cursor = 0
	_runner.finished = false
	_runner.decisions = {"photo_choice":"candid"}
	_runner.visited = []
	_runner._show_current()
	_check(_runner._visual.visible and _runner._actors.get_child_count()==0, "Visual beat replaces character staging")
	_check(not _runner._typing and not _runner._dialogue.visible, "Silent visual has no empty typewriter or dialogue")
	_check(not _runner._log_body(_runner._active).is_empty(), "Silent visual remains identifiable in history")
	_runner._advance.grab_focus()
	await _press_key(KEY_SPACE)
	_check(_runner.cursor==1 and Save.read()["cursor"]==1, "One Space advances a silent visual and commits progress")
	_check(_has_label(_runner._visual,"測試集合點") and _has_label(_runner._visual,"20:10"), "Invitation renders configured place and time")
	_check(_runner._dialogue.visible and not _runner._typing and not _runner._speaker.visible, "Visual reaction appears without another dialogue playback")
	await _press_key(KEY_ESCAPE)
	_check(_runner._paused and _focus_inside_modal(), "Visual beats retain keyboard pause controls")
	await _press_key(KEY_ESCAPE)
	await _press_key(KEY_ENTER)
	_check(_runner.cursor==2 and not _runner._visual.visible and is_instance_valid(_runner._phone), "Feed is rendered by the Alive phone instead of the visual card")
	_check(_has_label(_runner._phone,"週五見。"), "Alive feed uses its short configured caption")
	_check(_runner._phone._posts.size()==1 and _runner._phone._posts[0]["texture"]!=null, "Alive feed loads its post image resource")
	_runner._next()
	_check(_runner._visual.get_child(0).get_meta("photo_choice")=="candid", "Selected-photo beat renders the player's chosen image")
	_check(_visual_has_picture(), "Selected photo has a real texture")
	_runner._next()
	_check(_runner._visual.get_child(0).get_meta("photo_choice")=="posed", "Photo preview honors configured image independently of decisions")
	_runner._next()
	_check(not _runner._visual.visible and _runner._visual.get_child_count()==0, "Returning to a normal scene clears visual content")
	_check(_runner._actors.get_child_count()==1 and _runner._speaker.visible, "Returning to a normal scene restores cast and dialogue")
	if _runner._typing:
		_runner._next()
	_runner._next()
	await process_frame
	_check(is_instance_valid(_runner._phone) and not _runner._visual.visible, "Phone transition creates only the current phone view")
	_check(not _has_label(_runner._phone,"回到家了。") and not _has_label(_runner._phone,"手機亮著，外面的聲音遠了一點。"), "Phone does not repeat the old fixed emotional captions")
	_runner._next()
	_check(not is_instance_valid(_runner._phone) and not _runner._typing, "Leaving phone clears it and silent scene remains one-step readable")
	_runner._next()
	_check(_runner.finished and Save.read()["complete"], "Visual-inclusive route completes and saves normally")


func _test_alive_navigation() -> void:
	var ann_index := -1
	for index in _runner.beats.size():
		if _runner.beats[index]["id"]=="phone_ann":
			ann_index=index
	_check(ann_index>=0,"Alive test can locate the first unlocked DM")
	if ann_index<0:
		return
	_runner.cursor=ann_index
	_runner.finished=false
	_runner.decisions={"jason_choice":"tease","photo_choice":"candid"}
	_runner._rebuild_history()
	_runner._show_current()
	_runner._persist()
	var before: int=_runner.cursor
	var phone: Panel=_runner._phone
	_check(phone._view=="dm" and phone._thread=="Ann","Current phone beat opens its own Alive DM")
	_check(phone._threads.has("Ann") and not phone._threads.has("Ray") and not phone._threads.has("怡君"),"Alive receives only already seen DM threads")
	_check(not phone.open_thread("怡君"),"Opening an unreached conversation is rejected")
	_check(phone._threads["Ann"].size()==1,"Later messages inside the same DM are not exposed early")
	phone.show_inbox()
	_check(_runner.cursor==before and _runner._phone_browsing,"Browsing inbox leaves story progress unchanged")
	_runner._next()
	_check(_runner.cursor==before and phone._view=="dm" and not _runner._phone_browsing,"Continue while browsing returns to current story without advancing")
	_find_alive_action(phone,"tab:feed").grab_focus()
	await _press_key(KEY_SPACE)
	_check(phone._view=="feed" and _runner.cursor==before,"Keyboard feed navigation does not change story progress")
	_check(phone._scroll.follow_focus,"Alive scroll follows keyboard focus")
	phone._scroll.scroll_vertical=int(phone._scroll.get_v_scroll_bar().max_value)
	await process_frame
	var prior_scroll: int=phone._scroll.scroll_vertical
	_find_alive_action(phone,"like:before_04").grab_focus()
	await _press_key(KEY_SPACE)
	await process_frame
	_check(prior_scroll>0 and absi(phone._scroll.scroll_vertical-prior_scroll)<=1,"Liking an older post preserves its scroll position")
	_check(phone._post("phone_photo_posed").is_empty() and not phone._post("phone_photo_candid").is_empty(),"Feed includes only the selected photo branch")
	_check(not phone.toggle_like("unreached_post"),"Unknown posts cannot be liked into existence")
	_find_alive_action(phone,"like:phone_photo_candid").grab_focus()
	await _press_key(KEY_SPACE)
	_check(_runner.social_state["liked"].get("phone_photo_candid",false),"Visible Like control updates social state")
	_check(Save.read().get("social",{}).get("liked",{}).get("phone_photo_candid",false),"Like persists through the normal save API")
	phone.toggle_saved("phone_photo_candid")
	_check(Save.read().get("social",{}).get("saved",{}).get("phone_photo_candid",false),"Bookmark persists through the normal save API")
	_check(Save.read()["cursor"]==before,"Social actions preserve the current story cursor")
	phone.show_saved()
	_check(phone._view=="saved" and _runner.cursor==before,"Saved tab is functional without advancing story")
	_check(phone.open_post_image("phone_photo_candid") and is_instance_valid(phone._zoom),"Unlocked post image opens a full-screen enlargement")
	await _press_key(KEY_ESCAPE)
	_check(not is_instance_valid(phone._zoom) and not _runner._paused,"Escape closes the photo before any game pause is opened")
	_check(not phone.open_post_image("phone_photo_posed"),"Unselected photo cannot be enlarged from history")
	phone.return_to_current()
	_check(phone._view=="dm" and phone._thread=="Ann" and _runner._choices.visible,"Return-to-current restores the active DM and story controls")
	await _resume_and_compare()
	_check(_runner.social_state["liked"].get("phone_photo_candid",false) and _runner.social_state["saved"].get("phone_photo_candid",false),"Resuming restores liked and bookmarked posts")
	_check(_runner._phone._view=="dm" and _runner._phone._thread=="Ann","Resuming restores current narrative rather than old browsing tab")
	_runner.decisions["reply_choice"]="ray"
	for index in _runner.beats.size():
		if _runner.beats[index]["id"]=="reply_ray_01":
			_runner.cursor=index
	_runner._rebuild_history()
	_runner._show_current()
	_check(_find_alive_action(_runner._phone,"attachment:reply_ray_02")==null,"Ray's photo attachment is not visible before he sends it")
	_runner._next()
	_check(_find_alive_action(_runner._phone,"attachment:reply_ray_02")!=null,"Ray's arrived message includes the chosen photo attachment")
	var attachment_cursor: int=_runner.cursor
	_find_alive_action(_runner._phone,"attachment:reply_ray_02").grab_focus()
	await _press_key(KEY_SPACE)
	_check(is_instance_valid(_runner._phone._zoom) and _runner.cursor==attachment_cursor,"DM attachment opens the photo without skipping its message")
	await _press_key(KEY_ESCAPE)


func _find_alive_action(phone: Node, action: String) -> Button:
	for button in phone.find_children("*","Button",true,false):
		if button.get_meta("alive_action","")==action:
			return button
	return null


func _has_label(node: Node, value: String) -> bool:
	for child in node.get_children():
		if child is Label and child.text==value:
			return true
		if _has_label(child,value):
			return true
	return false


func _visual_has_picture() -> bool:
	for picture in _runner._visual.find_children("*","TextureRect",true,false):
		if picture.texture != null:
			return true
	return false


func _focus_inside_modal() -> bool:
	var focused := root.gui_get_focus_owner()
	return focused != null and is_instance_valid(_runner._modal) and _runner._modal.is_ancestor_of(focused)


func _press_key(key: Key) -> void:
	var down := InputEventKey.new()
	down.keycode = key
	down.physical_keycode = key
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var up := InputEventKey.new()
	up.keycode = key
	up.physical_keycode = key
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame
	await process_frame


func _click_button(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.button_mask = MOUSE_BUTTON_MASK_LEFT
	down.position = point
	down.global_position = point
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = point
	up.global_position = point
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame
	await process_frame


func _find_button(node: Node, label: String) -> Button:
	for child in node.get_children():
		if child is Button and child.text == label:
			return child
		var found := _find_button(child, label)
		if found != null:
			return found
	return null


func _find_choice_button(node: Node, value: String) -> Button:
	for child in node.get_children():
		if child is Button and child.get_meta("choice_value", "") == value:
			return child
	return null


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


func _check(condition: bool, description: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(description)
