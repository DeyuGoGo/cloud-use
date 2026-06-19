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
			"title": "01 ／ 一般般的禮拜三", "loc": "office", "sprite": "",
			"beats": [
				{"say": "公司的事你大概弄到一半就想收工——不是做不完，是「明天再說也不會怎樣」。六點半，你關電腦，跟旁邊的人點個頭。"},
				{"say": "不上不下、薪水照領、就是個普通工程師——你也覺得這樣沒什麼不好。"},
				{"say": "回家路上手機亮一下，是常送你宵夜的阿坤：「大哥今天滷味要加辣嗎？」你回「微辣謝謝」。\n今天跟你來回最多句的，是他。"},
			],
		},
		{
			"title": "02 ／ 為了健康", "loc": "embankment", "sprite": "",
			"beats": [
				{"say": "你不是什麼跑者。上次體檢紅字有點多，醫生叫你動一動，你買了雙鞋，偶爾下班去堤防跑個兩三公里。"},
				{"say": "基隆河堤，晚上、風大、路燈隔很遠，沒什麼人。跑的時候不用想事情，也沒什麼事好想。這樣就夠了。"},
			],
		},
		{
			"title": "03 ／ 喵過一兩眼的那個人", "loc": "embankment", "sprite": "yijun_embankment",
			"beats": [
				{"say": "堤防上會遇到一些固定的面孔。其中有個女生，瘦瘦的、跑姿很穩，每禮拜總會錯身兩三次。"},
				{"say": "你喵過一兩眼——就一兩眼，沒搭話，她大概也沒注意到你。跑步的人各跑各的，這很正常。"},
			],
		},
		{
			"title": "04 ／ IG 上那個很潮的東西", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "睡前躺床上滑手機。演算法推了一則限動：一群人在信義夜跑，自備音響、邊跑邊笑，剪得很熱血，配字「跑步也可以很潮」。"},
				{"say": "鏡頭中間那個男的特別會喬角度——團長，叫 Ray。你看了三秒，心裡一句：想紅的網紅仔。"},
				{"say": "人其實沒很多，看起來十幾個，但拍得像一場運動。"},
				{"choice": {"left": "滑掉，睡了", "right": "點進去看他們是誰"}},
			],
		},
		{
			"title": "05 ／ 茶水間，Jason", "loc": "pantry", "sprite": "jason",
			"beats": [
				{"say": "隔天茶水間，你提了一句那個跑團。Jason 鼻子哼一聲：「信義那個喔？一群想紅的，邊跑邊直播，是在跑健康的還是跑流量的。」"},
				{"say": "你笑笑，「對啊有夠尬。」Jason 是你同梯的，升得比你快——你一邊覺得他很會演，一邊半夜會偷研究他怎麼辦到的。"},
			],
		},
		{
			"title": "06 ／ 已不存在的使用者", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "那天晚上，你又滑了一下交友軟體。配對到一個還不錯的，你想了三分鐘，只敢打一個字：「hi」。"},
				{"say": "十分鐘後，對話框最上面那行變成「使用者已不存在」。封鎖了，或刪帳號了，反正一樣。"},
				{"say": "你把手機蓋在臉上，笑了一下。也沒怎樣，就是有點好笑——一個「hi」是能多嚇人。"},
				{"choice": {"left": "算了，睡", "right": "鬼使神差，又點開那個跑團"}},
			],
		},
		{
			"title": "07 ／ 緊張，但還是換了鞋", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "你又看了一次那則限動。下面寫：週三晚上七點半，市府站二號出口集合，新手歡迎。"},
				{"say": "那個工程師先跳出來：信義那種地方紅綠燈一堆根本不能跑。而且你昨天才說人家尬。"},
				{"say": "但你已經把鞋換好了。手心有點汗。你跟自己說，就去看看，不行就回家，反正沒人認得你。"},
				{"choice": {"left": "算了，太蠢了", "right": "出門"}},
			],
		},
		{
			"title": "08 ／ 第一個看到的，是 Jason", "loc": "xinyi", "sprite": "jason",
			"beats": [
				{"say": "市府站二號出口，比你想像的小一團，十幾個人，有人在拉筋、有人在喬音響。沒有 IG 上那麼潮，有點……普通。"},
				{"say": "然後你看到 Jason，穿著跑衣，正熟門熟路地跟人打招呼。他也看到你了。"},
				{"say": "兩個人都愣了半秒。「……你怎麼也在？」「啊就……朋友揪的，來看看。」你們都知道對方在唬爛。"},
			],
		},
		{
			"title": "09 ／ 那個網紅仔，居然叫得出你名字", "loc": "xinyi", "sprite": "ray",
			"beats": [
				{"say": "集合時 Ray 在前面講話，聲音不大但大家都聽。他掃過全場，停在你身上：「喔，新朋友？第一次來吼？」幾顆頭轉過來。"},
				{"say": "他走過來問你叫什麼、平常哪裡跑。你說堤防。「堤防硬底子喔！」他回頭跟人說「欸這個有練的」，拍拍你，「別站邊邊，跟著我們就對了。」"},
				{"say": "你本來是來看笑話的。但被他這樣一拉，你莫名其妙，站直了一點。"},
				{"choice": {"left": "「我隨便看看就好」", "right": "跟上他"}},
			],
		},
		{
			"title": "10 ／ 全場只有你重要的那種感覺", "loc": "xinyi", "sprite": "kevin",
			"beats": [
				{"say": "跑到一半在路口等紅燈，一個男生湊過來跟你並排，很自然地聊起來。他叫凱文。"},
				{"say": "他問的問題剛好都是你想講的，你說的他都「真的有在聽」，還記得你三分鐘前隨口提的堤防。短短一個紅燈，你覺得這個人也太好聊了。"},
				{"say": "綠燈，他笑著拍你一下就往前去了，又跟下一個人聊起來——一樣的湊近、一樣的好聊。"},
			],
		},
		{
			"title": "11 ／ 欸，是堤防那個", "loc": "xinyi", "sprite": "yijun_embankment",
			"beats": [
				{"say": "半路你和一個女生並到一起，她瞄你一眼，你也瞄她一眼——兩個人同時「啊」了一聲。是堤防那張熟面孔。"},
				{"say": "「你不是都在河堤跑？」「對啊，你也是。」她有點不好意思地笑，「我也是被同事拉來的……結果有夠吵，根本不能跑。」"},
				{"say": "她叫怡君。你們兩個堤防來的人，就這樣在一堆音響和自拍中間，並排慢慢跑著，誰也沒比誰熟門熟路。"},
			],
		},
		{
			"title": "12 ／ 結果，比你以為的好", "loc": "store", "sprite": "ann",
			"beats": [
				{"say": "跑完，大家在便利商店前面席地坐著喝水、亂聊。沒人問你做什麼、賺多少，就是很普通地把你算進去。Ann 多買了一罐運動飲料塞給你，「新來的，補一下。」"},
				{"say": "旁邊一個四十幾歲的大叔喝完水就先走，經過你丟下一句：「堤防練的喔？這裡跑不了啦，真想跑，回河邊。」說完人就走了。"},
				{"say": "你本來是抱著看笑話的心情來的。結果這群人，吵是吵，但意外地不難相處。你已經很久沒有，在一個地方，這麼自然地待著了。"},
			],
		},
		{
			"title": "13 ／ 回到家，那盞燈", "loc": "apartment", "sprite": "",
			"beats": [
				{"say": "你出門前忘了關的那盞燈還亮著。十二點多，你躺在床上，身上是跑完的痠，還有便利商店那罐飲料的甜。"},
				{"say": "你點開 IG。Ray 追蹤了你，還在限動 tag 了今晚的合照，一群人裡有個邊邊的你。"},
				{"say": "底下跳出一個你昨天還沒在意過的東西：「分享到你的限動」——按鈕亮著。你從來沒 po 過自己跑步。而且就昨天，你還叫人家想紅的網紅仔。"},
				{"choice": {"left": "滑掉，睡了", "right": "按下去"}},
			],
		},
	]

# Display names for placeholder sprites (when art is missing) = the 缺圖清單.
const NAMES := {
	"yijun_embankment": "怡君（堤防）",
	"yijun_xinyi": "怡君（信義）",
	"ray": "Ray",
	"jason": "Jason",
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
