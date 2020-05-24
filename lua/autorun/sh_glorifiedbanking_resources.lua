
local atmSoundLevel = 50

sound.Add({
    name = "GlorifiedBanking.Key_Press",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/key_press.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Beep_Normal",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/beep_normal.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Beep_Attention",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/beep_attention.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Beep_Error",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/beep_error.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Card_Insert",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/card_insert.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Card_Remove",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/card_remove.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Money_In_Start",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/money_in_start.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Money_In_Loop",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/money_in_loop.wav"
})

sound.Add({
    name = "GlorifiedBanking.Money_In_Finish",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/money_in_finish.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Money_Out",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = atmSoundLevel,
    pitch = 100,
    sound = "glorified_banking/money_out.mp3"
})

local readerSoundlevel = 40

sound.Add({
    name = "GlorifiedBanking.Beep_Reader_Normal",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = readerSoundlevel,
    pitch = 60,
    sound = "glorified_banking/beep_normal.mp3"
})

sound.Add({
    name = "GlorifiedBanking.Beep_Reader_Error",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = readerSoundlevel,
    pitch = 60,
    sound = "glorified_banking/beep_error.mp3"
})

if SERVER then
    AddCSLuaFile()

    if not GlorifiedBanking.Config.USE_FASTDL then
        resource.AddWorkshop( "2101502704" )
        return
    end

    --Sounds
    resource.AddFile("sound/glorified_banking/beep_attention.mp3")
    resource.AddFile("sound/glorified_banking/beep_error.mp3")
    resource.AddFile("sound/glorified_banking/beep_normal.mp3")
    resource.AddFile("sound/glorified_banking/beep_reader_normal.mp3")
    resource.AddFile("sound/glorified_banking/beep_reader_error.mp3")
    resource.AddFile("sound/glorified_banking/card_insert.mp3")
    resource.AddFile("sound/glorified_banking/card_remove.mp3")
    resource.AddFile("sound/glorified_banking/key_press.mp3")
    resource.AddFile("sound/glorified_banking/money_in_finish.mp3")
    resource.AddFile("sound/glorified_banking/money_in_loop.mp3")
    resource.AddFile("sound/glorified_banking/money_in_start.mp3")
    resource.AddFile("sound/glorified_banking/money_out.mp3")

    --Models
    resource.AddFile("models/ogl/ogl_main_atm.mdl")
    resource.AddFile("models/ogl/ogl_chip.mdl")

    --Model Materials
    resource.AddFile("materials/models/ogl/ogl_main_atm.vmt")
    resource.AddFile("materials/models/ogl/ogl_main_atm_nrm.vmt")
    resource.AddFile("materials/models/ogl/ogl_msic_atm.vmt")
    resource.AddFile("materials/models/ogl/ogl_main_atm_nrm.vmt")
    resource.AddFile("materials/models/ogl/ogl_rgb_atm.vmt")
    resource.AddFile("materials/models/ogl/ogl_rgb_atm_color.vmt")
    resource.AddFile("materials/models/ogl/ogl_rgb_atm_nrm.vmt")
    resource.AddFile("materials/models/ogl/ogl_sign_atm.vmt")
    resource.AddFile("materials/models/ogl/ogl_sign_atm_nrm.vmt")
    resource.AddFile("materials/models/ogl/ogl_chip.vmt")
    resource.AddFile("materials/models/ogl/ogl_chip_nrm.vmt")

    --UI Materials
    resource.AddFile("materials/glorified_banking/back.png")
    resource.AddFile("materials/glorified_banking/bank_card.png")
    resource.AddFile("materials/glorified_banking/check.png")
    resource.AddFile("materials/glorified_banking/chevron.png")
    resource.AddFile("materials/glorified_banking/circle.png")
    resource.AddFile("materials/glorified_banking/close.png")
    resource.AddFile("materials/glorified_banking/cursor.png")
    resource.AddFile("materials/glorified_banking/cursor_hover.png")
    resource.AddFile("materials/glorified_banking/exit.png")
    resource.AddFile("materials/glorified_banking/lockdown.png")
    resource.AddFile("materials/glorified_banking/logo_small.png")
    resource.AddFile("materials/glorified_banking/money.png")
    resource.AddFile("materials/glorified_banking/player.png")
    resource.AddFile("materials/glorified_banking/transaction.png")
    resource.AddFile("materials/glorified_banking/transfer.png")
    resource.AddFile("materials/glorified_banking/user.png")
    resource.AddFile("materials/glorified_banking/warning.png")
    resource.AddFile("materials/glorified_banking/loading_spinner.png")

    --Slideshow Materials
    resource.AddFile("materials/glorified_banking/slideshow/bank.png")
    resource.AddFile("materials/glorified_banking/slideshow/robbery.png")
    resource.AddFile("materials/glorified_banking/slideshow/transaction.png")

    --Fonts
    resource.AddFile("resource/fonts/montserratregular.ttf")
    resource.AddFile("resource/fonts/orbitronregular.ttf")
    resource.AddFile("resource/fonts/subwayticker.ttf")
end
