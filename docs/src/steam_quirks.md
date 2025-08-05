# Steam on Linux Quirks

## Vulkan Shader Processing

On NixOS it seems to default to using only 1 core; you can speed it up by editing `~/.steam/steam/steam_dev.cfg`:

```bash
unShaderBackgroundProcessingThreads 8 # or however many threads you have
```

Source: [https://steamcommunity.com/discussions/forum/1/4423184732111747107/](https://steamcommunity.com/discussions/forum/1/4423184732111747107/)
