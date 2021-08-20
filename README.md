
<p align="center"><a href="https://www.youtube.com/watch?v=lhvtcBpmYhs"><img src="https://i.imgur.com/dtmjc3h.png"></a></p>

# GlorifiedBanking

<a href="https://discord.gg/glorifiedstudios"><img src="https://img.shields.io/discord/329643791063449600?label=discord"></a>

Please do not contact me for support. I will not assist you. This is open source with an issues section for a reason.

## Installation & Usage

### Guide

- Download the latest version.
- Open the zip file using WinRar or 7-Zip.
- Drag & drop the folder into your addon's folder.
- Configure at `lua/addons/glorifiedbanking/xx_config.lua`.
- Add `glorifiedbanking_card` to your DarkRP loadout.
- Add [this](https://steamcommunity.com/sharedfiles/filedetails/?id=2101502704) workshop link to your server's collection.

### Spawning ATMs

If you would like to spawn and configure ATMs, open the spawn menu and select the ATM Placer toolgun. You can configure everything on the right, such as the withdrawal, deposit and transfer fees. Left click to place an ATM, right click to remove one and reload to update an existing ATM's settings.

### Using the Admin Panel

Type `glorifiedbanking_admin` in your console if you would like to access the panel.

### Restoring Backups

- Go to your server's `data` folder.
- Open the `glorifiedbanking_backups` folder.
- Look for the timestamp you would like to restore to.
- Type `glorifiedbanking_restorebackup timestamp` in your server's console.
- Restart your server.

### Importing Blue's ATM Data

- Make sure your SQL config is set up in GlorifiedBanking.
- Make sure Blue's ATM is on your server and the SQL is set up correctly.
- Type `glorifiedbanking_importbluesdata` in console and make sure it prints that the transfer was successful.
- Restart your server.

## Description

GlorifiedBanking was built with optimization in mind. It is lightweight, efficient and should fit all your needs for a roleplay banking system. When the player logs in for the first time, a bank account is created for him and he will be able to access it through one of the placed ATMs around the map. Administrators are able to use our built-in administration and logging panels, which provide you features such as transaction history, modifying players' bank accounts and more.

The addon also comes with various other quality of life features, such as your paychecks automatically being converted to money in your bank. There is also an interest system which can be configured to work with certain usergroups to give your donators or admins an extra amount.

Things don't always go as planned, and we understand that. There are numerous different tools included for damage control in the event that something goes wrong. Examples of these tools include our completely configurable and in-depth backup system which allow you to backup your database safely, as well as a lockdown mode that prevents any ATM usage which can be activated from one of your defined usergroups/admins in the event of an emergency.

### Key Features

- Easy and powerful configuration
- MySQL and SQLite compatibility
- Blue's ATM data importer so your players don't lose out
- Lockdown mode in the event of an emergency
- Exploit prevention and validation checks
- A built-in logging system in our admin panel
- Custom card designer to let the cards fit your server's theme
- Card reader entity for your stores to have direct transactions
- Wiremod outputs for card readers

### Features

- Interest system, custom checks for certain use cases such as restricting to donators
- Lightweight with top tier optimisation
- In-depth backup system for damage control, fully configurable
- Integrated with numerous other addons due to our powerful API
- A built-in logging system in our admin panel
- System for your paychecks to go straight to your bank
- A custom model with animations and a 3D2D menu
- Transaction history, for individuals and admins
- ATM entities save per map and work through admin cleanups
- CAMI support for certain admin privileges
- Custom Immersive and responsive audio
- Withdrawals, deposits and transfers with the ability to set fees per ATM
- Administration panel to take full control of your server
- Easily customisation UI themes with our easy-to-understand theme library
- Add support for other gamemodes with our easy-to-use compatibility file
- Toolgun to consistently place ATMs at the same height, consistent distances and set appropriate fees
- Translate to your own language with ease using our localisation library
- DRM free and zero obfuscation
