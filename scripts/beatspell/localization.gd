extends RefCounted

## UI strings are translated at draw time; gameplay records retain stable identifiers.
const LANGUAGES := ["auto", "zh_CN", "en"]
const ZH := {
	"A RITUAL IN THREE MOVEMENTS": "三式成章，以拍施法",
	"LISTEN. WEAVE. SURVIVE.": "聆听节拍，结式求生",
	"BEGIN RITUAL": "开始仪式",
	"T PRACTICE / O OPTIONS / C CALIBRATE": "T 练习 / O 设置 / C 校准",
	"H SPELLBOOK / ESC LEAVE": "H 术式 / ESC 退出",
	"PAUSED": "已暂停", "P  RESUME": "P 继续",
	"O OPTIONS / ESC TITLE": "O 设置 / ESC 标题",
	"RUN COMPLETE": "仪式结束", "BEAST DISPELLED": "守卫已击破",
	"RITUAL BROKEN": "仪式失败", "RITUAL EXPIRED": "时间耗尽",
	"CAST %02d/%02d   P%02d G%02d X%02d": "施法 %02d/%02d  准%02d 良%02d 失%02d",
	"AVG %03dMS %s / RANK %s": "均差 %03d毫秒 %s / 评级 %s",
	"EARLY": "偏早", "LATE": "偏晚", "ON TIME": "准时",
	"MAX COMBO %02d / DAMAGE %02d": "最高连击 %02d / 伤害 %02d",
	"BLOCK %02d / PERFECT %02d / BREAK %02d": "格挡 %02d / 精准 %02d / 破防 %02d",
	"HEAL %02d / TIME %02dS / BOSS %02d": "治疗 %02d / 用时 %02d秒 / 敌血 %02d",
	"R AGAIN / H SPELLBOOK / ESC TITLE": "R 重开 / H 术式 / ESC 标题",
	"PHASE %d · %s": "阶段 %d / %s",
	"AWAKENING": "觉醒", "FRACTURE": "破防", "OVERDRIVE": "狂涌",
	"DEFENSE REPORT": "防御训练报告",
	"PATTERN": "节奏", "TRY": "次数", "BLK": "格挡", "PRF": "精准", "RUN": "连准",
	"STANDARD": "标准", "SYNCOPATED": "切分", "RUSH": "疾奏",
	"STD": "标准", "SYNC": "切分", "CLEAR": "通过",
	"%s OK": "%s 已通过", "%s %dMS": "%s %d毫秒",
	"NO ATTACKS YET": "尚无攻击记录", "PERFECT GUARD": "精准格挡",
	"EARLY SHIELD": "护盾过早", "GOOD SHIELD": "良好护盾",
	"NO SHIELD": "未有护盾", "CHECK TIMING": "检查时机",
	"TAB / ESC BACK . P RESUME": "TAB / ESC 返回 / P 继续",
	"OPTIONS": "设置", "MUSIC": "音乐音量", "SOUND FX": "音效音量",
	"SCREEN SHAKE": "画面震动", "FULLSCREEN": "全屏", "LANGUAGE": "语言",
	"ON": "开", "OFF": "关", "AUTO": "自动",
	"ARROWS ADJUST / ESC BACK": "方向键调整 / ESC 返回",
	"SPELLBOOK": "术式手册",
	"FLARE: STEP / CAST": "炎击：动作 / 施法",
	"MEND:  STEP / STEP / CAST": "回春：动作 / 动作 / 施法",
	"AEGIS: STEP / REST / CAST": "护盾：动作 / 空拍 / 施法",
	"ONE SYMBOL PER WHOLE BEAT": "每个整拍输入一个动作",
	"PERFECT AEGIS ON LAST BEAT: GUARD": "攻击前最后一拍精准护盾：精准格挡",
	"BLOCK 1 / GUARD 2 / BREAK AT 3": "格挡积1 / 精准积2 / 满3破防",
	"BREAK: NEXT FLARE +2 DAMAGE": "破防：下一次炎击伤害+2",
	"4 CAST COMBO: NEXT FLARE +1": "连续施法4次：下一次炎击+1",
	"DRILL: ARROWS MODE / TAB REPORT": "训练：方向键换节奏 / TAB 报告",
	"H / ESC BACK": "H / ESC 返回",
	"FLARE": "炎击", "MEND": "回春", "AEGIS": "护盾",
	"DAMAGE": "伤害", "BLOCK": "格挡", "RECOVER": "恢复",
	"LISTEN TO THE PULSE": "聆听节拍", "FORM A SPELL": "结成术式",
	"NEXT %s": "下轮 %s", "DEFENSE DRILL": "防御训练", "FREE PRACTICE": "自由练习",
	"%s DRILL": "%s训练", "LOST THE PHRASE": "术式超时", "RHYTHM BROKE": "节奏中断",
	"%s -%d%s": "%s -%d%s", " POWER": " 强化", "%s  +%d": "%s +%d",
	"BLOCKED": "已格挡", "WARDEN EXPOSED": "守卫破防",
	"BEAST STRIKE  -%d": "受到攻击 -%d", "%s CLEAR": "%s通过",
	"SETTINGS SAVE FAILED": "设置保存失败", "MISSING MUSIC: %s": "缺少音乐：%s",
	"THE CASTER": "施术者", "RESONANT WARDEN": "共鸣守卫",
	"AEGIS READY": "护盾就绪", "I  /  AWAKENING": "I / 觉醒",
	"II  /  FRACTURE": "II / 破防", "III  /  OVERDRIVE": "III / 狂涌",
	"DRILL / %s": "训练 / %s", "PRACTICE / NO DAMAGE": "练习 / 无伤",
	"COMBO %02d": "连击 %02d", "EXPOSED": "已破防",
	"D/F  STEP    J/K  CAST": "D/F 动作 J/K 施法",
	"%s P%d/%d": "%s 准%d/%d", "ARROWS %s TAB": "左右 %s TAB",
	"T DEFENSE / TAB REPORT": "T 防御 / TAB 报告",
	"%s %d/2 / ESC TITLE": "%s %d/2 / ESC 标题",
	"P PAUSE  O OPTIONS  R RETRY": "P 暂停 O 设置 R 重开",
	"PRACTICE %s / CAST %d": "引导 %s / 成功 %d",
	"AUDIO CALIBRATION": "音频延迟校准",
	"CALIBRATION  %+d ms": "校准偏移 %+d 毫秒",
	"ENTER  SAVE     R  RETRY": "ENTER 保存 / R 重试",
	"PRESS D WITH EACH CLICK": "跟随每次节拍声按 D",
	"%d / %d TAPS": "%d / %d 次采样", "ESC  BACK": "ESC 返回",
}

static var preference := "auto"
static var language := "en"


static func normalize(value: Variant) -> String:
	return value if value is String and value in LANGUAGES else "auto"


static func resolve(value: Variant, system_locale: String) -> String:
	var selected := normalize(value)
	if selected != "auto":
		return selected
	return "zh_CN" if system_locale.to_lower().replace("-", "_").get_slice("_", 0) == "zh" else "en"


static func set_language(value: Variant, system_locale: String = OS.get_locale()) -> void:
	preference = normalize(value)
	language = resolve(preference, system_locale)


static func text(source: String, args: Array = []) -> String:
	var translated: String = ZH.get(source, source) if language == "zh_CN" else source
	if args.is_empty():
		return translated
	var values: Array = []
	for value in args:
		values.append(text(value) if value is String else value)
	return translated % values


static func language_label(value: String) -> String:
	return {"auto": text("AUTO"), "zh_CN": "中文", "en": "English"}.get(value, text("AUTO"))
