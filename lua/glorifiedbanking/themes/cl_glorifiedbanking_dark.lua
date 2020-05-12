
GlorifiedBanking.Themes.Register( "Dark", i18n.GetPhrase("gbDarkTheme"), {
    Colors = {
        backgroundCol = Color( 69, 69, 69 ),


        titleTextCol = Color( 255, 255, 255 ),
        titleBarCol = Color( 37, 161, 214 ),

        logoCol = Color( 255, 255, 255 ),
        logoBackgroundCol = Color( 46, 162, 212 ),

        backCol = Color( 255, 255, 255 ),
        backBackgroundCol = Color( 93, 93, 93 ),
        backBackgroundHoverCol = Color( 61, 61, 61 ),

        exitCol = Color( 255, 255, 255 ),
        exitBackgroundCol = Color( 208, 80, 84 ),
        exitBackgroundHoverCol = Color( 171, 64, 67 ),


        innerBoxBackgroundCol = Color( 55, 55, 55 ),
        innerBoxBorderCol = Color( 255, 255, 255 ),


        idleScreenMessageBackgroundCol = Color( 69, 69, 69 ),
        idleScreenSeperatorCol = Color( 255, 255, 255 ),
        idleScreenTextCol = Color( 255, 255, 255 ),


        lockdownIconCol = Color( 200, 62, 67 ),
        lockdownMessageLineCol = Color( 46, 162, 212 ),
        lockdownMessageBackgroundCol = Color( 69, 69, 69 ),
        lockdownWarningIconCol = Color( 255, 255, 255 ),
        lockdownTextCol = Color( 255, 255, 255 ),


        menuUserIconCol = Color( 255, 255, 255 ),
        menuUserTextCol = Color( 255, 255, 255 ),
        menuUserUnderlineCol = Color( 255, 255, 255 ),
        menuButtonBackgroundCol = Color( 65, 65, 65 ),
        menuButtonTextCol = Color( 255, 255, 255 ),
        menuButtonHoverCol = Color( 75, 75, 75 ),
        menuButtonUnderlineCol = Color( 37, 160, 213 ),


        loadingScreenBackgroundCol = Color( 49, 49, 49 ),
        loadingScreenBorderCol = Color( 46, 162, 212 ),
        loadingScreenTextCol = Color( 255, 255, 255 ),
        loadingScreenSpinnerCol = Color( 46, 162, 212 ),


        keyHoverCol = Color(0, 0, 0, 100),
        keyPressedCol = Color(0, 0, 0, 200)
    },
    Fonts = {
        ["ATMEntity.Title"] = {
            font = "Orbitron",
            size = 54,
            weight = 1000,
            antialias = true
        },
        ["ATMEntity.Loading"] = {
            font = "Montserrat",
            size = 70,
            weight = 500,
            antialias = true
        },
        ["ATMEntity.EnterCard"] = {
            font = "Montserrat",
            size = 50,
            weight = 700,
            antialias = true
        },
        ["ATMEntity.EnterCardSmall"] = {
            font = "Montserrat",
            size = 40,
            weight = 700,
            antialias = true
        },
        ["ATMEntity.Lockdown"] = {
            font = "Montserrat",
            size = 40,
            weight = 600,
            antialias = true
        },
        ["ATMEntity.LockdownSmall"] = {
            font = "Montserrat",
            size = 36,
            weight = 500,
            antialias = true
        },
        ["ATMEntity.WelcomeBack"] = {
            font = "Montserrat",
            size = 44,
            weight = 600,
            antialias = true
        },
        ["ATMEntity.MenuButton"] = {
            font = "Montserrat",
            size = 56,
            weight = 600,
            antialias = true
        },
        ["ATMEntity.WithdrawHint"] = {
            font = "Montserrat",
            size = 40,
            weight = 600,
            antialias = true
        },
        ["ATMEntity.WithdrawFee"] = {
            font = "Montserrat",
            size = 34,
            weight = 500,
            antialias = true
        }
    },
    Materials = {
        logoSmall = Material( "glorified_banking/logo_small.png", "noclamp smooth" ),
        back = Material( "glorified_banking/back.png", "noclamp smooth" ),
        exit = Material( "glorified_banking/exit.png", "noclamp smooth" ),
        lockdown = Material( "glorified_banking/lockdown.png", "noclamp smooth" ),
        warning = Material( "glorified_banking/warning.png", "noclamp smooth" ),
        user = Material( "glorified_banking/user.png", "noclamp smooth" ),
        circle = Material( "glorified_banking/circle.png", "noclamp smooth" ),
        cursor = Material( "glorified_banking/cursor.png", "noclamp smooth" ),
        cursorHover = Material( "glorified_banking/cursor_hover.png", "noclamp smooth" ),
        bankCard = Material( "shitcardlol.png", "noclamp smooth" )
    }
} )

GlorifiedBanking.Themes.GenerateFonts() //Regenerate fonts on theme save for fast development, remove on release
