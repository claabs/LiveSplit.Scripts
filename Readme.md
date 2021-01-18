# Watch Dogs: Legion Load Remover

## Installation

1. In the LiveSplit splits editor, make sure your game is set to `Watch Dogs: Legion` and then click the "Activate" button.
2. Disable BattlEye for the game; this can be done by adding the `-BattlEyeLauncher` command line option. This is needed because it blocks the game's memory from being read.
3. In LiveSplit, set "Game Time" as your main timing method
   * Right-click the main window ➞ Compare Against ➞ Game Time. (Both real time and time without loads are stored in your splits regardless.)

## Supported Versions

* 1.2.40

If you want to downgrade version, you can find a link to past patches in the Discord.

## Troubleshooting

If the load remover is not working, you may be on an unsupported version of the game. To help with development, do the following:

1. Right click the Windows icon ➞  Event Viewer ➞ Windows Logs ➞ Application ➞ Find the LiveSplit Errors
    * The error should say `Unrecognized hash: <LONG HASH>`.
1. Report the error in the Discord or in a Github issue with:
    * the hash
    * game version (e.g. 1.2.40)
    * launcher (UPlay, Epic Games, etc.)
    * DirectX video setting (DX11, DX12, Ultra textures)

## Development

### How to get memory addresses

1. Launch the game into DX11 mode
1. Attach to `WatchDogsLegion.exe`
1. Set "Memory Scan Options" to `DuniaDemo_clang_64_dx11.dll`
1. Load into a file and scan for a **4 Byte** value of `1`
1. Once the game loads, refine the search with a value of `0`
1. Add the address to the ASL scruot
1. Repeat for DX12.

### Resources

* [LiveSplit Docs](https://github.com/LiveSplit/LiveSplit.AutoSplitters)
* [Alan Wake ASL](https://github.com/tduva/LiveSplit-ASL)
* [Watch_Dogs 2 ASL](https://github.com/zoton2/LiveSplit.Scripts)