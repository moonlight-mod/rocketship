#!/usr/bin/env bash
# rocketship.sh v1.0.0 https://github.com/moonlight-mod/rocketship

set -eu

discord_branch="stable"
discord_exe="Discord"
discord_exe_kebab="discord"

force_yes=false

print_usage() {
  set +x
  echo "rocketship.sh v1.0.0 https://github.com/moonlight-mod/rocketship"
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -b, --branch <branch>  The branch of Discord to install (stable, ptb, canary)"
  echo "  -y, --yes              Automatically answer yes to all prompts"
  echo "  -h, --help             Display this help message"
  set -x
}

set_branch() {
  case $discord_branch in
    "stable" | "Discord" | "discord")
      discord_branch="stable"
      discord_exe="Discord"
      discord_exe_kebab="discord"
      ;;
    "ptb" | "DiscordPTB" | "discord-ptb")
      discord_branch="ptb"
      discord_exe="DiscordPTB"
      discord_exe_kebab="discord-ptb"
      ;;
    "canary" | "DiscordCanary" | "discord-canary")
      discord_branch="canary"
      discord_exe="DiscordCanary"
      discord_exe_kebab="discord-canary"
      ;;
    *)
      echo "Invalid branch: $input_branch"
      print_usage
      exit 1
      ;;
  esac
}

# https://stackoverflow.com/a/9271406
while [ "${1:-}" != "" ]; do
  case $1 in
    "-b" | "--branch")
      shift
      discord_branch=$1
      set_branch
      ;;

    "-y" | "--yes")
      force_yes=true
      ;;

    "-h" | "--help")
      print_usage
      exit 0
      ;;
  esac
  shift
done

download_url="https://discordapp.com/api/download/$discord_branch?platform=linux&format=tar.gz"
electron_url="https://github.com/moonlight-mod/discord-electron/releases/latest/download/electron.tar.gz"
venmic_url="https://raw.githubusercontent.com/moonlight-mod/rocketship/main/venmic.node"

work_dir="/tmp/moonlight-rocketship"
# TODO we should use XDG environment variables
discord_dir="$HOME/.local/share/$discord_exe"
applications_dir="$HOME/.local/share/applications"
icons_dir="$HOME/.local/share/icons/hicolor/256x256"

set +x
echo "rocketship will do the following:"
echo "- Download Discord from $download_url"
echo "- Download modified Electron from $electron_url"
echo "- Download venmic from $venmic_url"
echo "- Install Discord to $discord_dir"
echo "- Add a desktop entry and icon"
set -x
if [ $force_yes = false ]; then
  read -p "Do you want to continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting."
    exit 0
  fi
fi

if [ -d $work_dir ]; then
  echo "Cleaning up previous run of rocketship in $work_dir..."
  rm -rf $work_dir
fi
mkdir -p $work_dir

if [ -d $discord_dir ]; then
  if [ $force_yes = false ]; then
    read -p "Discord is already installed at $discord_dir. Do you want to delete it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Exiting."
      exit 0
    fi
  fi

  echo "Deleting existing Discord installation in $discord_dir..."
  rm -rf $discord_dir
fi


echo "Downloading Discord..."
wget -O "$work_dir/discord.tar.gz" "$download_url"
tar -xf "$work_dir/discord.tar.gz" -C "$work_dir"
discord_extracted_dir="$work_dir/$discord_exe"

echo "Downloading modified Electron..."
wget -O "$work_dir/electron.tar.gz" "$electron_url"
mkdir -p "$work_dir/electron"
tar -xf "$work_dir/electron.tar.gz" -C "$work_dir/electron"

echo "Installing modified Electron..."
mv "$work_dir/electron" "$discord_dir"

echo "Downloading venmic..."
wget -O "$discord_dir/venmic.node" "$venmic_url"

echo "Installing Discord..."
cp "$discord_extracted_dir/$discord_exe_kebab.desktop" "$discord_dir"
cp "$discord_extracted_dir/discord.png" "$discord_dir"
cp "$discord_extracted_dir/postinst.sh" "$discord_dir"
cp -r "$discord_extracted_dir/resources" "$discord_dir"

echo "Renaming executable..."
mv $discord_dir/electron $discord_dir/$discord_exe

echo "Installing desktop entry..."
mkdir -p "$applications_dir"
cp "$discord_dir/$discord_exe_kebab.desktop" "$applications_dir"
sed -i "s|/usr/share/$discord_exe_kebab|$discord_dir|" "$applications_dir/$discord_exe_kebab.desktop"

mkdir -p $icons_dir
cp "$discord_dir/discord.png" "$icons_dir/$discord_exe_kebab.png"
sed -i "s|Icon=$discord_exe_kebab|Icon=$icons_dir/$discord_exe_kebab.png|" "$applications_dir/$discord_exe_kebab.desktop"

echo "Cleaning up $work_dir..."
rm -rf $work_dir

echo "Done! Run $discord_exe in $discord_dir to start Discord directly."
