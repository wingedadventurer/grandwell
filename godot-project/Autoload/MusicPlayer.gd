extends Node

func stop():
	for music_player in get_children():
		if music_player is AudioStreamPlayer:
			music_player.stop()

func play_descent():
	stop()
	$Descent.play()

func play_ascent():
	stop()
	$Ascent.play()

func play_discovery():
	stop()
	$Discovery.play()

func play_menu():
	stop()
	$Menu.play()
