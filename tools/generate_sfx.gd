extends SceneTree

const Bank = preload("res://scripts/beatspell/sound_bank.gd")


func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/sfx/beatspell")
	DirAccess.make_dir_recursive_absolute("res://build")
	var preview := PackedByteArray()
	for kind in Bank.SOUNDS:
		var stream: AudioStreamWAV = Bank.generate(kind)
		var error := stream.save_to_wav("res://assets/sfx/beatspell/%s.wav" % kind)
		if error != OK:
			printerr("Unable to export sound: " + kind)
			quit(1)
			return
		preview.append_array(stream.data)
		var silence := PackedByteArray()
		silence.resize(int(Bank.RATE * 0.18) * 2)
		silence.fill(0)
		preview.append_array(silence)
	var reel := AudioStreamWAV.new()
	reel.format = AudioStreamWAV.FORMAT_16_BITS
	reel.mix_rate = Bank.RATE
	reel.data = preview
	var error := reel.save_to_wav("res://build/beatspell-sound-reel.wav")
	if error != OK:
		quit(1)
		return
	print("Exported %d original WAV effects and ordered sound reel." % Bank.SOUNDS.size())
	quit(0)
