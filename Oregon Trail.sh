#!/bin/bash
# PortMaster launch script - The Oregon Trail (Apple II) native runtime
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/oregontrail"
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

msg() { if type pm_message >/dev/null 2>&1; then pm_message "$1"; fi; echo "$1"; sleep 6; }

# you must supply your own Apple II disk images (two 140 KB files) in ports/oregontrail/disks
echo "Disk folder contents:"; ls -la "$GAMEDIR/disks" 2>&1
# count candidate disk images: any file of exactly 143360 bytes (any extension, any letter case)
NDISKS=$(find "$GAMEDIR/disks" -maxdepth 1 -type f -size 143360c 2>/dev/null | wc -l)
echo "Candidate disk images found: $NDISKS"
if [ "$NDISKS" -lt 2 ]; then
  msg "Need TWO Oregon Trail Apple II disk images (140 KB each, .dsk) in ports/oregontrail/disks - found $NDISKS"
  type pm_finish >/dev/null 2>&1 && pm_finish
  exit 1
fi

PY="$(command -v python3 || command -v python)"
if [ -z "$PY" ]; then
  msg "Python 3 was not found on this system."
  type pm_finish >/dev/null 2>&1 && pm_finish
  exit 1
fi

export PYTHONPATH="$GAMEDIR:$controlfolder/pylibs:$PYTHONPATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PYTHONDONTWRITEBYTECODE=1

echo "Using $PY"; "$PY" --version
"$PY" "$GAMEDIR/oregon.py" --disks "$GAMEDIR/disks" --saves "$GAMEDIR/saves"

type pm_finish >/dev/null 2>&1 && pm_finish
