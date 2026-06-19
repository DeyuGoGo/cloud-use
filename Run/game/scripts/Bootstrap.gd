extends Node
## Dev helper: when launched with `-- --screenshot`, wait for the first scene to
## settle (fonts + layout), grab the framebuffer, write res://_preview.png, quit.
## No effect during normal play. Used to verify the slice headlessly-ish from CLI.

func _ready() -> void:
	var user_args := OS.get_cmdline_user_args()
	if "--screenshot" not in user_args:
		return
	await get_tree().create_timer(1.4).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png("res://_preview.png")
	get_tree().quit()
