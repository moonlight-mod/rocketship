# rocketship

rocketship is a shell script for Linux users to download and install a modified Discord client. This client contains a forked Electron build which re-enables some disabled features. rocketship can be used with [moonlight](https://github.com/moonlight-mod/moonlight) for features like screensharing with audio.

## Usage

Download rocketship.sh and run it:

```shell
curl https://raw.githubusercontent.com/moonlight-mod/rocketship/main/rocketship.sh -o ./rocketship.sh
# Always review scripts before running them
cat ./rocketship.sh
chmod +x ./rocketship.sh
./rocketship.sh -b canary
```

rocketship can be re-ran again to reinstall Discord if an update happens, so consider keeping the script around.

## FAQ

### How does it work?

rocketship downloads the official Discord client's .asar file, but replaces the executable with a custom build of Electron. This build of Electron is a fork of Discord's fork. It simply re-enables removed features from the Discord client.

For screensharing, rocketship re-enables the `getUserMedia` APIs to allow for screensharing through Electron (compared to screensharing through Discord native modules).

### Is it safe?

From the words of [NotNite](https://github.com/NotNite):

> In terms of "your Discord account" safe - probably. We don't fully understand how screensharing interactions work. Use at your own risk, as with any client mod.
>
> In terms of "your computer" safe - yes, but you have to believe me on that. The copy of Electron that rocketship uses is available [here](https://github.com/moonlight-mod/discord-electron) and I built it on my own computer. While I would love to build it with a chain of trust, Electron is simply too intensive (on space/memory/time) to compile in GitHub Actions, so that's not an option. If you're really worried about it, you can build your own Electron from source or simply not use it at all.

## Notes

This repository contains a compiled version of [venmic](https://github.com/Vencord/venmic), licensed MPL-2.0.
