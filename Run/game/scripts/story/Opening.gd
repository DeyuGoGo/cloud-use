class_name Opening
## First chapter 〈那盞燈〉— from 05-腳本-01開場.md.
##
## Rhythm (拍定版): narration plays as tap-through VN beats; only the 5 "on-ramp"
## turning points are ←/→ swipe events. Everything else (incl. witness scenes 03/12)
## is narration you tap through.
##
## A scene = { title, loc, sprite, beats[] }. A beat is either:
##   {"say": "..."}                       → tap to advance
##   {"choice": {"left": "...", "right": "..."}}  → swipe event (always last beat)
## `loc`    → res://art/bg/<loc>.png   (placeholder w/ label if missing)
## `sprite` → res://art/char/<sprite>.png (named placeholder if missing); "" = none

const CHAPTER := "第一章 〈那盞燈〉"

static func scenes() -> Array:
	return [
		{
			"title": "01 ／ 一般般的禮拜二", "loc": "office", "sprite": "",
			"beats": [
				{"say": "禮拜二，六點半。手上的東西做到一半，你存檔、關機——不是做不完，是「明天再說也不會怎樣」。"},
				{"say": "起身，跟旁邊的同事點個頭，他盯著螢幕沒抬頭。你走出辦公室，一路上沒跟誰說到話。"},
				{"say": "手機震了幾下，你還以為有人找你。點開——群組啦：家族群組的早安圖、公司群組在喬明天的會、一個三年沒人講話的大學群組。99+，沒一則是你的。"},
				{"choice": {"left": "鎖屏，懶得回", "right": "在群組補個「收到」"}},
			],
		},
		{
			"title": "02 ／ 為了健康", "loc": "embankment", "sprite": "",
			"beats": [
				{"say": "這種晚上，你會去堤防跑一下。你又不是什麼跑者，就上次體檢紅字有點多，醫生叫你動一動，你買了雙鞋，跑個兩三公里這樣。"},
				{"say": "基隆河堤，晚上，風很大，路燈隔超遠，沒什麼人。"},
				{"say": "工程師的毛病改不掉，手錶還是記了距離、配速。跑完滑一下那幾個數字——也沒給誰看，就自己看。"},
				{"choice": {"left": "跑兩圈就回家", "right": "再繞遠一點，沿著河多跑一段"}},
			],
		},
		{
			"title": "03 ／ 老是超過你的那個人", "loc": "embankment", "sprite": "yijun_embankment",
			"beats": [
				{"say": "又是她。瘦瘦的，每次都在這段遇到。"},
				{"say": "然後每次都輕鬆從你旁邊超過去，越跑越遠。你們沒講過話，她大概也沒注意到你。"},
			],
		},
		{
			"title": "04 ／ IG 上那個很潮的東西", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "睡前躺床上滑手機。演算法大概抓到你常在信義那帶跑，塞了一則限動給你：一群人在信義夜跑，自己帶音響、邊跑邊笑，剪得有夠熱血，配字「跑步也可以很潮」。"},
				{"say": "鏡頭一直繞著中間那個男的轉——團長，叫 Ray。那種很習慣被拍、很愛鏡頭的人。你看了三秒，心裡一句：想紅的網紅仔喔。"},
				{"say": "其實人也沒幾個啦，十幾個吧，但剪得有夠浮誇。你滑掉了。"},
				{"choice": {"left": "滑掉，睡了", "right": "點進去看他們是誰"}},
			],
		},
		{
			"title": "05 ／ 茶水間，Jason", "loc": "pantry", "sprite": "jason_office",
			"beats": [
				{"say": "隔天茶水間，你順口跟 Jason 提了一句那個跑團。"},
				{"say": "Jason 鼻子哼一聲：「信義那個喔？我知道啊，一群想紅的，邊跑邊直播，是在跑健康的還是跑流量的？」你笑笑，「對啊，就一群想紅的網紅仔嘛。」"},
				{"say": "Jason 跟你同梯，升得比你快。你嘴上覺得他超會演。結果半夜還不是會偷滑他限動，研究他到底怎麼辦到的。他講完繼續滑手機，沒再多說。"},
				{"choice": {"left": "附和兩句就走", "right": "多問一句「你去過喔？」"}},
			],
		},
		{
			"title": "06 ／ 已不存在的使用者", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "那天晚上，你又滑了一下交友軟體。配對到一個還不錯的，你想了三分鐘，只敢打一個字：「hi」。"},
				{"say": "十分鐘後，那行字變成「使用者已不存在」。你把手機蓋在臉上，笑了一下——一個 hi 是能多嚇人。"},
				{"choice": {"left": "算了，睡", "right": "鬼使神差，又點開那個跑團的限動"}},
			],
		},
		{
			"title": "07 ／ 緊張，但還是換了鞋", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "你又看了一次那則限動。下面寫：今晚七點半，市府站二號出口集合，新手歡迎。"},
				{"say": "你馬上開始找理由：信義那種地方紅綠燈一堆，根本不能跑啦。而且你昨天才嫌過人家。"},
				{"say": "但你已經把鞋換好了。手心有點汗。你跟自己說，就去看看嘛，不行就回家——反正也沒人認得你。"},
				{"say": "出門前那盞燈你沒關。反正回來也沒人。"},
				{"choice": {"left": "算了，太蠢了", "right": "出門"}},
			],
		},
		{
			"title": "08 ／ 第一個看到的，是 Jason", "loc": "xinyi", "sprite": "jason",
			"beats": [
				{"say": "市府站二號出口，比你想的小一團，十幾個人，有人在拉筋、有人在喬音響。沒有 IG 上那麼潮，有點……普通欸。你正不知道手要往哪擺——"},
				{"say": "然後你看到 Jason。穿著跑衣，正像個老鳥一樣到處跟人打招呼。他也看到你了。"},
				{"say": "兩個人都愣了半秒。「……你怎麼也在？」你問。「啊就……朋友硬揪的，給個面子嘛。」他說。"},
				{"say": "你們都知道對方在唬爛——然後很有默契地都沒再問。"},
				{"choice": {"left": "「你不是說一群想紅的？」——把話抽回來", "right": "「我也朋友揪的」——一起裝，混進去"}},
			],
		},
		{
			"title": "09 ／ 那個網紅仔，居然叫得出你名字", "loc": "xinyi", "sprite": "ray",
			"beats": [
				{"say": "你是來看他們出糗的。集合時 Ray 在前面講話，聲音不大，但大家都在聽。他掃過全場，停在你身上：「喔，新朋友？第一次來吼？」幾顆頭轉過來，你下意識想退半步。"},
				{"say": "他已經走過來了，問你叫什麼、平常都在哪跑。你說堤防。「堤防硬底子喔！」他回頭跟旁邊的人說：「欸這個有練的。」然後拍拍你，「別客氣啦，往前面來。」"},
				{"say": "你站直了一點。"},
				{"choice": {"left": "「我隨便看看就好」", "right": "跟上他"}},
			],
		},
		{
			"title": "10 ／ 全場只有你重要的那種感覺", "loc": "xinyi", "sprite": "kevin",
			"beats": [
				{"say": "跑到一半在路口等紅燈，一個男生湊過來跟你並排，很自然地就聊起來。他叫凱文。"},
				{"say": "「欸你剛說堤防喔？」他湊過來，「那邊晚上是不是都沒人？我也想找個沒人的地方跑欸。」就一個紅燈，你講的話大概比今天一整天加起來還多。"},
				{"say": "綠燈，他笑著拍你一下，「下次見啦堤防。」就往前去了。你回頭，他已經貼到另一個人旁邊，講得正起勁。"},
				{"choice": {"left": "沒多想，繼續跑", "right": "多看了那個背影一眼"}},
			],
		},
		{
			"title": "11 ／ 欸，是堤防那個", "loc": "xinyi", "sprite": "yijun_embankment",
			"beats": [
				{"say": "半路你跟一個女生並到一起，她瞄你一眼，你也瞄她一眼。你認得——就是堤防上老是超過你的那個。兩個人同時「啊」了一聲。"},
				{"say": "「你不是都在河堤跑？」她問。「對啊，你也是喔。」你說。她瞄一眼那排音響，「同事硬拉的。」頓了一下，「這也叫跑步喔。」"},
				{"say": "她叫怡君。兩個堤防來的，就跟在這群音響後面慢慢跑，誰也沒多講話。跑了一段，她忽然說：「等等記得喔，跑完先閃，不要被拉去拍照。」講得跟在交代逃生路線一樣。"},
				{"choice": {"left": "「對啊我也覺得跑不了」——一起吐槽", "right": "「那你還來？」——虧她"}},
			],
		},
		{
			"title": "12 ／ 結果，比你以為的好", "loc": "store", "sprite": "ann",
			"beats": [
				{"say": "跑完，大家就坐在超商前面地上喝水、亂聊。沒人問你做什麼、賺多少，就很自然地把你算進去。Ann——一個姊姊——多買一罐運動飲料塞給你，「新來的齁，來，這個補一下，不然你明天鐵腿。」她順手又開一罐自己的，喝了一口，看著這群人鬧，沒說話。"},
				{"say": "旁邊一個看起來有點年紀的大叔喝完水就先走，經過你丟下一句：「這裡跑不了啦。真想跑，回河邊。」人就走了。"},
				{"say": "你本來只想站邊邊看一眼就走。你坐著沒動，水也還沒喝完。"},
			],
		},
		{
			"title": "13 ／ 回到家，那盞燈", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "那盞燈還亮著——你出門前沒關。十二點多了，你躺在床上，腿還在痠。"},
				{"say": "手機震一下。群組，早安圖、轉發、99+，老樣子，沒一則是找你的。"},
				{"say": "但你點開 IG——Ray 追蹤了你，還在限動 tag 了今晚的合照，一群人裡，邊邊有個你。底下跳出一個你昨天還完全沒在意的東西：「分享到你的限動」，按鈕亮著。"},
				{"say": "你從來沒 po 過自己跑步。而且今天早上你才在茶水間，當著 Jason 的面叫人家想紅的網紅仔欸。"},
				{"choice": {"left": "滑掉，睡了", "right": "按下去"}},
			],
		},
	]

# Choice consequences, keyed by scene id ("01".."13") then side ("left"/"right").
# `fx`    → hidden parameter deltas applied to RunState (總體參數 / 關係).
# `route` → sets the run's trajectory flag (序章收束的路線).
# `end`   → ends the prologue right here on a branch (路線真的分岔), value = end kind.
# A side with no entry just advances linearly with no effect (早期「沒差」由此體現).
const FLOW := {
	"01": {"left": {"fx": {"clean": 1}}, "right": {"fx": {"seen": 1}}},
	"02": {"right": {"fx": {"clean": 1, "nerve": 1}}},
	"04": {"left": {"fx": {"clean": 1}}, "right": {"fx": {"seen": 1}}},
	"05": {"right": {"fx": {"bond": {"jason": 1}}}},
	"06": {"left": {"fx": {"clean": 1}}, "right": {"fx": {"seen": 1, "nerve": 1}}},
	# 07 = 真正的路線分岔：不去＝乾淨路線，序章就此安靜收束；出門＝主線。
	"07": {"left": {"fx": {"clean": 2}, "route": "home", "end": "home"}, "right": {"fx": {"seen": 2, "nerve": 2}}},
	"08": {"left": {"fx": {"clean": 1, "bond": {"jason": -1}}}, "right": {"fx": {"seen": 1, "bond": {"jason": 1}}}},
	"09": {"left": {"fx": {"clean": 1}}, "right": {"fx": {"seen": 1, "bond": {"ray": 1}}}},
	"10": {"right": {"fx": {"seen": 1, "bond": {"kevin": 1}}}},
	"11": {"left": {"fx": {"bond": {"yijun": 1}}}, "right": {"fx": {"bond": {"yijun": 1}, "nerve": 1}}},
	# 13 = 決定性的一拍：按下分享＝往「被看見」傾、引擎上膛；滑掉＝乾淨。兩邊都收束序章。
	"13": {"left": {"fx": {"clean": 2}, "route": "lurk"}, "right": {"fx": {"seen": 3, "self_first": 1}, "route": "post"}},
}

# Display names for placeholder sprites (when art is missing) = the 缺圖清單.
const NAMES := {
	"yijun_embankment": "怡君（堤防）",
	"yijun_xinyi": "怡君（信義）",
	"ray": "Ray",
	"jason": "Jason",
	"jason_office": "Jason",
	"kevin": "凱文",
	"ann": "Ann",
	"laowu": "老吳",
}

# Placeholder tint per location (used only when the bg art is missing).
const LOC := {
	"office": {"label": "公司辦公室", "tint": Color("141518")},
	"apartment": {"label": "主角租屋", "tint": Color("171019")},
	"embankment": {"label": "基隆河堤（堤防）", "tint": Color("0f1822")},
	"xinyi": {"label": "信義夜跑", "tint": Color("1a1426")},
	"pantry": {"label": "公司茶水間", "tint": Color("16181a")},
	"store": {"label": "便利商店前", "tint": Color("1a1d16")},
}
