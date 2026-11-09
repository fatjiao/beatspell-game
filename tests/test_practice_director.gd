extends RefCounted

const Practice = preload("res://scripts/beatspell/practice_director.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var lesson = Practice.new()
	if lesson.current_skill() != "fireball": failures.append("practice starts with FLARE")
	lesson.record_cast("heal")
	lesson.record_cast("")
	if lesson.step != 0: failures.append("wrong spell and failure cannot advance lesson")
	lesson.record_cast("fireball")
	if lesson.step != 0: failures.append("one cast is insufficient")
	lesson.record_cast("fireball")
	if lesson.current_skill() != "heal" or lesson.counts.heal != 0: failures.append("next lesson clears premature casts")
	lesson.record_cast("heal")
	lesson.record_cast("heal")
	if lesson.current_skill() != "shield": failures.append("MEND advances to AEGIS")
	lesson.record_cast("shield")
	lesson.record_cast("shield")
	if lesson.current_skill() != "": failures.append("six correct casts unlock free practice")
	lesson.record_cast("fireball")
	lesson.reset()
	if lesson.step != 0 or lesson.counts.fireball != 0: failures.append("restart clears lesson progress")
	return failures
