extends SceneTree

const OUT := "res://docs/media/gameplay/"

class Figure extends Control:
	const INK := Color("19343d")
	const MUTED := Color("566974")
	const TEAL := Color("007e79")
	const GOLD := Color("ac620a")
	const RED := Color("b33c48")
	var kind := 0
	var font: SystemFont
	var screenshots: Dictionary = {}

	func _init() -> void:
		font = SystemFont.new()
		font.font_names = PackedStringArray(["Microsoft YaHei", "Noto Sans CJK SC"])
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


	func text(at: Vector2, value: String, size_px: int = 28, color: Color = INK) -> void:
		draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)


	func center_text(at: Vector2, value: String, size_px: int = 28, color: Color = INK) -> void:
		var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
		text(at - Vector2(width * 0.5, 0), value, size_px, color)


	func header(title: String, subtitle: String) -> void:
		draw_rect(Rect2(0, 0, 1200, 940), Color("f6f4ee"))
		text(Vector2(48, 55), title, 36)
		text(Vector2(48, 94), subtitle, 24, MUTED)


	func arrow(from: Vector2, to: Vector2, color: Color = MUTED) -> void:
		draw_line(from, to, color, 3, true)
		var direction := (to - from).normalized()
		draw_colored_polygon(PackedVector2Array([to, to - direction.rotated(0.5) * 15, to - direction.rotated(-0.5) * 15]), color)


	func badge(at: Vector2, label: String) -> void:
		draw_circle(at, 20, TEAL)
		center_text(at + Vector2(0, 10), label, 27, Color.WHITE)


	func shot(path: String, at: Vector2 = Vector2(120, 130)) -> void:
		if not screenshots.has(path):
			var raw := Image.load_from_file(ProjectSettings.globalize_path(path))
			screenshots[path] = ImageTexture.create_from_image(raw)
		draw_texture_rect(screenshots[path], Rect2(at, Vector2(960, 540)), false)


	func chip(at: Vector2, label: String, type: String = "step") -> void:
		var color := TEAL if type == "step" else GOLD
		if type == "rest":
			draw_circle(at, 24, Color("d8dfdf"))
			center_text(at + Vector2(0, 9), "—", 26, MUTED)
		elif type == "step":
			draw_circle(at, 26, color)
		else:
			draw_colored_polygon(PackedVector2Array([at + Vector2(0, -30), at + Vector2(30, 0), at + Vector2(0, 30), at + Vector2(-30, 0)]), color)
		center_text(at + Vector2(0, 67), label, 26, MUTED)


	func box(rect: Rect2, first: String, second: String, color: Color = TEAL) -> void:
		draw_rect(rect, Color.WHITE)
		draw_rect(Rect2(rect.position, Vector2(7, rect.size.y)), color)
		center_text(rect.get_center() + Vector2(0, -5), first, 28, color)
		center_text(rect.get_center() + Vector2(0, 36), second, 24, MUTED)


	func _draw() -> void:
		match kind:
			0: overview()
			1: timing()
			2: spells()
			3: combat()
			4: boss_cues()
			9: languages()
			10: encounters()
			11: records()
			12: prism()
			13: session_safety()
			5:
				header("练习模式怎么用", "实机截图 · 无伤害练习，从三个基础术式开始")
				shot("res://build/beatspell-practice-preview.png")
				text(Vector2(120, 735), "① 标题按 T 进入练习，FLARE → MEND → AEGIS 各成功两次。", 26)
				text(Vector2(120, 786), "② 课程完成后按 T，切换无伤害防御训练；R 重置课程。", 26)
				text(Vector2(120, 837), "练习不限时，成功施法后双方生命恢复，不会击杀目标。", 25, MUTED)
			6:
				header("结算时看什么", "实机截图 · 先看胜负，再看时机与术式成功率")
				shot("res://build/beatspell-record-result-preview.png")
				text(Vector2(120, 735), "等级：术式成功率、Miss 输入和平均绝对偏差共同决定。", 26)
				text(Vector2(120, 786), "偏差：越接近 0ms 越准；EARLY / LATE 表示整体早晚倾向。", 26)
				text(Vector2(120, 837), "新纪录行：评级、最快通关、连击突破时显示；V 查看战绩。", 26)
				text(Vector2(120, 888), "示例统计。超时指令和局末未完成组合各记一次失败。", 25, MUTED)
			7: poses()
			8:
				header("五种防御训练与训练报告", "实机截图 · 左右键切换节奏，Tab 查看本轮各模式的成绩")
				shot("res://build/beatspell-drill-report-preview.png")
				text(Vector2(120, 735), "TRY 尝试 / BLK 格挡 / PRF 精准格挡 / RUN 最佳连续精准格挡。", 25)
				text(Vector2(120, 786), "每种节奏连续精准格挡 3 次标为 OK；切换模式保留本轮成绩。", 25)
				text(Vector2(120, 837), "P 开始三拍恢复准备；R 重开清空。新增 ECHO 回声 / OFFBEAT 反拍。", 25)


	func overview() -> void:
		header("战斗画面一眼读懂", "实机截图 · 圆形数字为文档标注，游戏中不显示这些编号")
		shot("res://build/beatspell-rush-warning-preview.png")
		var points := [Vector2(72, 15), Vector2(256, 15), Vector2(158, 82), Vector2(252, 124), Vector2(159, 151), Vector2(60, 87)]
		for index in points.size():
			badge(Vector2(120, 130) + points[index] * 3, str(index + 1))
		var labels := ["玩家生命：归零则本局失败", "Boss 生命：归零即可获胜", "公共节拍环：按实际位置判断早晚", "攻击预警：听完节奏，在小节末接招", "术式卡：火球、护盾与治疗的配方", "玩家角色：观察蓄力、施法和护盾"]
		for index in labels.size():
			var origin := Vector2(75 + (index % 2) * 570, 735 + (index / 2) * 68)
			badge(origin, str(index + 1))
			text(origin + Vector2(34, 10), labels[index], 25)


	func timing() -> void:
		header("圆环如何显示快慢", "示意图 · 四拍一圈 2000ms，输入落点保留真实角度")
		for index in 3:
			var origin := Vector2(215 + index * 385, 348)
			draw_arc(origin, 120, 0, TAU, 100, Color("a1b2b8"), 3, true)
			for beat in 4:
				var angle := -PI / 2 + beat * PI / 2
				draw_circle(origin + Vector2(cos(angle), sin(angle)) * 120, 6, MUTED)
			var target := origin + Vector2(0, -120)
			draw_circle(target, 11, INK)
			var offset: int = [-90, 0, 180][index]
			var angle := -PI / 2 + TAU * float(offset) / 2000.0
			var location := origin + Vector2(cos(angle), sin(angle)) * 96
			draw_line(target, location, RED if index == 2 else TEAL, 3, true)
			draw_circle(location, 11, RED if index == 2 else TEAL)
			center_text(origin + Vector2(0, 10), ["偏早", "准时", "偏晚"][index], 32)
			center_text(origin + Vector2(0, 184), ["-90ms · Good", "0ms · Perfect", "+180ms · Miss"][index], 26, RED if index == 2 else TEAL)
		center_text(Vector2(600, 172), "顶部黑点是示例目标拍；彩色点是实际按下的位置", 26, MUTED)
		chip(Vector2(290, 650), "圆点 = D / F 动作")
		chip(Vector2(860, 650), "菱形 = J / K 结束", "finish")
		center_text(Vector2(600, 822), "超出 ±135ms 的输入也会显示，并标为红色。", 28, RED)


	func spells() -> void:
		header("三种术式怎么按", "示意图 · 任选一个整拍起手；每一列相隔 500ms")
		for index in 3:
			center_text(Vector2(440 + index * 300, 178), ["起手拍 0ms", "下一拍 500ms", "第三拍 1000ms"][index], 25, MUTED)
		var names := ["FLARE 火球", "MEND 治疗", "AEGIS 护盾"]
		for row in 3:
			var y := 280 + row * 205
			text(Vector2(55, y + 10), names[row], 30)
			draw_line(Vector2(380, y), Vector2(1080, y), Color("c8d3d4"), 3)
			chip(Vector2(440, y), "D / F")
			if row == 0:
				chip(Vector2(740, y), "J / K", "finish")
				center_text(Vector2(1040, y + 8), "已完成", 27, MUTED)
			elif row == 1:
				chip(Vector2(740, y), "D / F")
				chip(Vector2(1040, y), "J / K", "finish")
			else:
				chip(Vector2(740, y), "这一拍不按", "rest")
				chip(Vector2(1040, y), "J / K", "finish")
		text(Vector2(55, 894), "按下 J / K 立即识别。成功后，下一段输入继续跟随公共节拍。", 27, MUTED)


	func combat() -> void:
		header("防守如何换来更强的火球", "关系图 · 弱点和共鸣可以同时强化下一发 FLARE")
		box(Rect2(45, 155, 310, 125), "Perfect AEGIS", "在命中前 600ms 内完成")
		arrow(Vector2(370, 217), Vector2(445, 217))
		box(Rect2(460, 155, 300, 125), "精准格挡", "本次免伤，破防值 +2")
		arrow(Vector2(775, 217), Vector2(845, 217))
		box(Rect2(860, 155, 295, 125), "破防累计 3 格", "普通格挡也能 +1")
		arrow(Vector2(1007, 295), Vector2(1007, 365))
		box(Rect2(860, 380, 295, 125), "Boss 暴露弱点", "下一发火球 +2", GOLD)
		box(Rect2(45, 380, 310, 125), "连续成功 4 次", "包括火球、治疗和护盾")
		arrow(Vector2(370, 442), Vector2(445, 442))
		box(Rect2(460, 380, 300, 125), "共鸣就绪", "下一发火球 +1", GOLD)
		arrow(Vector2(610, 520), Vector2(610, 640), GOLD)
		arrow(Vector2(1007, 520), Vector2(900, 640), GOLD)
		box(Rect2(180, 660, 840, 140), "Perfect 火球 2 + 弱点 2 + 共鸣 1", "不计棱镜姿态为 5；棱镜护甲再 -1，开放再 +1", GOLD)
		center_text(Vector2(600, 882), "术式失败、超时或受击：连击归零，未使用共鸣清除。", 27, RED)


	func boss_cues() -> void:
		header("Boss 预警节奏怎么听", "时序图 · 四次提示的位置会变，攻击均在本小节 2000ms 处命中")
		var left := 300.0
		var right := 1080.0
		var patterns := [[0, 500, 1000, 1500], [0, 750, 1000, 1750], [0, 1000, 1500, 1750]]
		for row in 3:
			var y := 265 + row * 200
			text(Vector2(48, y + 8), ["标准 Standard", "切分 Syncopated", "加速 Rush"][row], 26)
			draw_rect(Rect2(left + (right - left) * 0.7, y - 65, (right - left) * 0.3, 130), Color("d2e8e2"))
			draw_line(Vector2(left, y), Vector2(right, y), MUTED, 3)
			for tick in patterns[row]:
				var x := left + float(tick) / 2000.0 * (right - left)
				draw_circle(Vector2(x, y), 11, TEAL)
				center_text(Vector2(x, y + 48), str(tick), 22, MUTED)
			draw_line(Vector2(right, y - 65), Vector2(right, y + 65), RED, 4)
			center_text(Vector2(right, y - 83), "命中", 25, RED)
			center_text(Vector2(right, y + 48), "2000ms", 23, RED)
		text(Vector2(48, 836), "青色区：命中前 600ms，Perfect 护盾完成后可形成精准格挡。", 27, TEAL)
		text(Vector2(48, 887), "防御训练中按左右键选择节奏，切换在下一小节生效。", 26, MUTED)


	func encounters() -> void:
		header("战斗模式 / Encounters", "标题左右选择，ENTER / J / K 开始 · Same beat, different encounters")
		shot("res://build/beatspell-title-prism-preview.png")
		text(Vector2(65, 720), "仪式 RITUAL：9 小节教学。决斗 DUEL：直接按生命阶段战斗。", 27, TEAL)
		text(Vector2(65, 767), "试炼 GAUNTLET：每 2 小节攻击，标准 → 切分 → 疾奏轮换。", 27)
		text(Vector2(65, 814), "棱镜 PRISM：第二位 Boss，护甲 / 核心开放与两种新预警。", 27)
		text(Vector2(65, 862), "First 3: Boss 60 HP. Prism: 72 HP. All: 5 player HP / 90s / 120 BPM.", 24, MUTED)
		text(Vector2(65, 903), "左右选模式 / ARROWS select · R 重开当前模式 / retry same encounter", 23, MUTED)


	func records() -> void:
		header("本地战绩 / Record book", "标题或结算按 V · V / ESC 返回 · Example statistics / 示例统计")
		for index in 2:
			var path := "res://build/beatspell-records%s-preview.png" % ("-zh" if index == 1 else "")
			if not screenshots.has(path):
				screenshots[path] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path)))
			draw_texture_rect(screenshots[path], Rect2(40 + index * 580, 150, 540, 304), false)
		text(Vector2(65, 525), "各模式分别保存：胜场 / 完整场次、最佳评级、最快通关、最高连击。", 27)
		text(Vector2(65, 572), "Per mode: wins / completed runs, best rank, fastest victory and best combo.", 24, MUTED)
		text(Vector2(65, 646), "通关时间只比较获胜局；评级和连击也统计失败局。", 27)
		text(Vector2(65, 693), "Clear times require a win. Rank and combo also include completed losses.", 24, MUTED)
		text(Vector2(65, 767), "三个勋章格：通关 → A 级通关 → S 级通关，只看胜局。", 27, TEAL)
		text(Vector2(65, 814), "Medals: clear / A victory / S victory. Loss ranks do not earn medals.", 24, MUTED)
		text(Vector2(65, 886), "本地保存，练习与中退不计 / Local save; practice and abandoned runs excluded.", 23, MUTED)


	func prism() -> void:
		header("棱镜守卫 / Prism Warden", "第二位 Boss · 72 HP · 两小节一击 / one strike every 2 bars")
		for index in 2:
			var path := "res://build/beatspell-prism-%s-preview.png" % ["armor", "open"][index]
			if not screenshots.has(path):
				screenshots[path] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path)))
			draw_texture_rect(screenshots[path], Rect2(40 + index * 580, 135, 540, 304), false)
		center_text(Vector2(310, 485), "护甲 ARMORED：FLARE -1", 27)
		center_text(Vector2(890, 485), "核心开放 OPEN：FLARE +1", 27, TEAL)
		text(Vector2(60, 540), "每四小节循环：护甲 → 护甲 → 开放 → 开放；完成施法时计算。", 26)
		text(Vector2(60, 581), "4-bar cycle: armor / armor / open / open. Damage uses the finishing bar.", 24, MUTED)
		for row in 2:
			var y := 670 + row * 100
			text(Vector2(60, y + 9), ["回声 ECHO", "反拍 OFFBEAT"][row], 26)
			draw_line(Vector2(315, y), Vector2(1100, y), MUTED, 2)
			var times: Array = [[0, 250, 1000, 1250], [250, 750, 1250, 1750]][row]
			for tick in times:
				var x := 315.0 + float(tick) / 2000.0 * 785
				draw_circle(Vector2(x, y), 8, TEAL)
				center_text(Vector2(x, y + 37), str(tick), 22, MUTED)
			draw_line(Vector2(1100, y - 25), Vector2(1100, y + 25), RED, 3)
			center_text(Vector2(1100, y + 37), "2000ms", 22, RED)
		text(Vector2(60, 878), "命中仍在小节末；增减伤在破防/共鸣之后计算，最低 1。", 25)
		text(Vector2(60, 915), "Impact at bar end. Modifier stacks with fracture/resonance; minimum damage 1.", 23, MUTED)


	func session_safety() -> void:
		header("中断与恢复 / Pause and resume", "实机截图 · 切出窗口自动暂停 / Losing focus pauses the battle")
		for index in 2:
			var path := "res://build/beatspell-resume%s-preview.png" % ("-zh" if index == 1 else "")
			if not screenshots.has(path):
				screenshots[path] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path)))
			draw_texture_rect(screenshots[path], Rect2(40 + index * 580, 150, 540, 304), false)
		text(Vector2(65, 536), "P：三拍准备（1500ms）后恢复；P / Esc 可取消，保持暂停。", 27)
		text(Vector2(65, 585), "P: 3-count preparation, then resume. P / Esc cancels and stays paused.", 24, MUTED)
		text(Vector2(65, 664), "准备期间音乐、指令和战斗时间冻结，恢复时接着原相位。", 27, TEAL)
		text(Vector2(65, 713), "Music, commands and battle time freeze; resume at the same beat phase.", 24, MUTED)
		text(Vector2(65, 792), "重新切回窗口不会自动继续；O / H 开菜单，R 重开。", 27)
		text(Vector2(65, 841), "Returning focus never resumes automatically. O / H menus, R restart.", 24, MUTED)


	func languages() -> void:
		header("中英文切换 / Language", "实机截图 · O → 语言 / LANGUAGE · 上下选择，左右切换")
		for index in 2:
			var path := "res://build/beatspell-options%s-preview.png" % ("-zh" if index == 1 else "")
			if not screenshots.has(path):
				screenshots[path] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path)))
			center_text(Vector2(310 + index * 580, 153), ["English", "中文"][index], 28, TEAL)
			draw_texture_rect(screenshots[path], Rect2(40 + index * 580, 180, 540, 304), false)
		text(Vector2(65, 550), "自动 / AUTO：跟随系统语言；中文系统显示中文，其余显示英文。", 27)
		text(Vector2(65, 598), "Follow the system language: Chinese for zh locales, English otherwise.", 24, MUTED)
		text(Vector2(65, 671), "中文 / English：即时切换并保存；战斗进度和训练记录保留。", 27)
		text(Vector2(65, 719), "Switch instantly and save locally; battle and training progress remain.", 24, MUTED)
		text(Vector2(65, 792), "炎击 FLARE  ·  护盾 AEGIS  ·  回春 MEND", 29, TEAL)
		text(Vector2(65, 857), "ESC 返回后仍暂停，按 P 继续。 / ESC back, then P to resume.", 25, MUTED)


	func poses() -> void:
		header("角色动作如何配合节奏", "实际姿态 PNG · 上排施法者，下排共鸣守卫")
		for index in 3:
			center_text(Vector2(280 + index * 320, 155), ["待机", "蓄力", "施法 / 出击"][index], 29)
		for row in 2:
			var names := ["caster_idle", "caster_charge", "caster_cast"] if row == 0 else ["warden_idle", "warden_windup", "warden_strike"]
			for index in 3:
				var path: String = "res://assets/art/beatspell/pixel/poses/" + names[index] + ".png"
				if not screenshots.has(path):
					var raw := Image.load_from_file(ProjectSettings.globalize_path(path))
					screenshots[path] = ImageTexture.create_from_image(raw)
				var texture: Texture2D = screenshots[path]
				var rect := Rect2(160 + index * 320, 190 + row * 290, 240, 260)
				draw_rect(rect, Color("10272d"))
				var target := texture.get_size() * 3
				draw_texture_rect(texture, Rect2(rect.get_center() - target / 2, target), false)
		center_text(Vector2(600, 845), "动作变化用于表现状态，实际判定仍以音乐节拍与输入时间为准。", 27, MUTED)


func _init() -> void:
	call_deferred("_build")


func _build() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1200, 940)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var figure := Figure.new()
	figure.size = Vector2(1200, 940)
	viewport.add_child(figure)
	var names := ["battle-overview", "timing-ring", "spell-patterns", "guard-and-bonuses", "boss-cues", "practice", "results", "character-poses", "defense-report", "languages", "encounters", "records", "prism-boss", "session-safety"]
	var selected := OS.get_cmdline_user_args()
	for index in names.size():
		if not selected.is_empty() and names[index] not in selected:
			continue
		figure.kind = index
		figure.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var output := viewport.get_texture().get_image()
		var error := output.save_png(OUT + names[index] + ".png")
		if error != OK:
			push_error("Unable to save figure: " + names[index])
			quit(1)
			return
	print("Saved selected illustrated gameplay figures.")
	viewport.queue_free()
	await process_frame
	quit(0)
