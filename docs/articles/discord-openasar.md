# Fixing Discord With OpenAsar

Like many (arguably _most_) pieces of free, proprietary software today, Discord is
[really bad for your privacy](https://tosdr.org/en/service/536). Your "private" messages and even voice chats on Discord
are collected and stored, readable by Discord staff, according to their own privacy policy.
Discord's primary source of revenue is selling your data. These are just a few of many issues.

By default, Discord also collects data on applications you open and run on your computer and build a statistical model
of what software you are likely to buy/license in the future. You can turn this off under Settings → Privacy & Safety
by turning off "Use data to improve Discord", but they try to scare you out of disabling it.

![Discord trying to scare you into not turning off spyware](https://user-images.githubusercontent.com/8648891/246507023-6f16bcaa-f19a-409c-970c-cb85cfb6d548.png)

You also have to disable it twice before it actually does anything, at least in my own personal experience. I recommend turning off every
setting under the "HOW WE USE YOUR DATA" heading.

# What is OpenAsar

The Discord desktop app is built with [Electron](https://www.electronjs.org/), which basically means its a web view
running in Chromium as a desktop app. Electron bundles application scripts in an `app.asar` archive file, and `OpenAsar`
is an open source reimplementation of Discord's `app.asar`.

[`OpenAsar`](https://openasar.dev/) is a much, much smaller file size than Discord's own `app.asar`, and it adds some
really nice additional features.

![OpenAsar file size](https://user-images.githubusercontent.com/8648891/246508384-111cc63b-0243-44d5-85aa-9dc5dda8884a.png)

If you have a GitHub account, give the [OpenAsar repository](https://github.com/GooseMod/OpenAsar) a star!

## What Does OpenAsar Do?

Once `OpenAsar` is installed (see [Installing OpenAsar](#installing-openasar)), if you go to Settings in the Discord app,
you should see a new section in the sidebar under "App Settings" called "OpenAsar". Clicking this will open the OpenAsar
settings window.

From this window, you can turn off a lot (but most likely not all) of Discord's spyware by completely blocking the `/api/science` Discord
API endpoint, disable showing others when you're typing in Discord, and apply custom CSS from the "Theming" tab.

![OpenAsar settings page](https://user-images.githubusercontent.com/8648891/246509701-d0978e27-f549-40b3-9a05-a9b8f50bc086.png)

One of the things that annoys me the most about Discord is how aggressively they push Discord Nitro subscriptions on you everywhere
throughout the app, and how arbitrary the set of features that are put behind the Nitro paywall is. Sorry, Discord, but I will never,
ever pay money for Discord Nitro, ever. I would try convincing my friends to switch to Matrix before paying for Nitro.

With OpenAsar, I can use the "Theming" tab to inject custom CSS and remove a lot of the Discord Nitro ads from the Discord app.

```css
/* Hide all things Discord Nitro */
/* "Add Super Reaction" button */
div[aria-label="Add Super Reaction"],
/* Super Reactions others have added */
div[class*="reactionInner"][aria-label*="super"],
/* "Nitro" section in sidebar of settings page */
div[class*="premiumTab"],
/* The huge Nitro ads on the profile customization page */
div[class*="premiumFeatureBorder"],
/* Discord's Birthday stuff on the profile customization page */
div[class*="birthdayFeatureBorder"],
/* The "boost" status on Discord server sidebars */
div[aria-label*="Buy Boosts to help unlock"],
/* The "Nitro" item in the direct messages list */
ul[aria-label="Direct Messages"] a[href="/store"],
/* The "Discord's Birthday" item in the direct messages list */
ul[aria-label="Direct Messages"] a[href="/activities"]
/* The "Start an Activity" button */
button[aria-label="Start an Activity"] {
  display: none;
}
```

## Installing OpenAsar

If you're on NixOS (or use Nix package manager on another OS) like me, you're in luck, it's incredibly easy to install `OpenAsar`
via Nix, just by setting a package override:

```nix
{ pkgs, ... }: {
  # if using home-manager
  home.packages = [ (pkgs.discord.override { withOpenASAR = true; }) ]
  # if not using home-manager, install globally
  environment.systemPackages = [ (pkgs.discord.override { withOpenASAR = true; }) ];
}
```

Otherwise, you will have to replace Discord's `app.asar` manually. On Linux, Discord's `app.asar` is most likely
in one of the following locations:

```bash
# native Discord installation
/opt/discord/resources/app.asar
/usr/lib/discord/resources/app.asar
/usr/lib64/discord/resources/app.asar
/usr/share/discord/resources/app.asar

# Flatpak Discord installation
/var/lib/flatpak/app/com.discordapp.Discord/current/active/files/discord/resources/app.asar
~/.local/share/flatpak/app/com.discordapp.Discord/current/active/files/discord/resources/app.asar
```

For Windows, it should be in the directory `%localappdata%\Discord\app-1.0.9013\resources` which you can get to
by typing that into the address bar in Windows file explorer.

Once you've located Discord's `app.asar`, fully quit Discord, then just replace the entire `app.asar` archive with
the version you download from [`OpenAsar`'s website](https://openasar.dev/).

### Updating OpenAsar

On NixOS, `OpenAsar` will update any time you apply updates via your Nix config. On Windows and generic Linux, `OpenAsar` can self-update,
but on Windows you will need to change the directory permissions for Discord's resources directory (which you located when installing)
for self-updates to work.
See [`OpenAsar`'s FAQ for more information](https://github.com/GooseMod/OpenAsar/blob/main/faq.md#does-openasar-update-itself).
