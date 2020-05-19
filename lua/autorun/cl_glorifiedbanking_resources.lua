
resource.AddWorkshop( "2101502704" )

local soundLevel = 60

sound.Add({
	name = "GlorifiedBanking.Key_Press",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/key_press.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Beep_Normal",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/beep_normal.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Beep_Attention",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/beep_attention.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Beep_Error",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/beep_error.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Card_Insert",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/card_insert.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Card_Remove",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/card_remove.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Money_In_Start",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/money_in_start.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Money_In_Loop",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/money_in_loop.wav"
})

sound.Add({
	name = "GlorifiedBanking.Money_In_Finish",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/money_in_finish.mp3"
})

sound.Add({
	name = "GlorifiedBanking.Money_Out",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = soundLevel,
	pitch = 100,
	sound = "glorified_banking/money_out.mp3"
})
