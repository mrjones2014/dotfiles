# Discord & OpenAsar

I use [OpenAsar](https://github.com/GooseMod/OpenAsar) which is essentially a patch for Discord's `app.asar`
(basically an [Electron](https://www.electronjs.org/) app bundle) to make it spy on you less
and add a few extra features like theming.

On NixOS you can easily install OpenAsar by simply using a package override:

```nix
{ pkgs, ... }: {
  # if using home-manager
  home.packages = [ (pkgs.discord.override { withOpenASAR = true; }) ]
  # if not using home-manager, install globally
  environment.systemPackages = [ (pkgs.discord.override { withOpenASAR = true; }) ];
}
```

Now, when you go to Settings in the Discord app, you should have a new item in the sidebar
called "OpenAsar". Clicking that opens the OpenAsar configuration window. From here, I use
the following CSS to block as many of the Discord Nitro elements as possible:

```css
/* Hide all things Discord Nitro */
div[aria-label="Add Super Reaction"],
div[class*="premiumTab"],
div[class*="premiumFeatureBorder"],
div[class*="birthdayFeatureBorder"],
div[class*="reactionInner"][aria-label*="super"],
div[aria-label*="Buy Boosts to help unlock"] {
  display: none;
}
```
