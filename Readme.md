# Watch Dogs: Legion Load Remover

## Installation

1. In the LiveSplit splits editor, make sure your game is set to `Watch Dogs: Legion` and then click the "Activate" button.
1. After activating, enter the "Settings" menu to enable or disable autosplitting.
    * See [below](#autosplitting) for how it works
1. Disable BattlEye for the game; this can be done by adding the `-BattlEyeLauncher` command line option. This is needed because it blocks the game's memory from being read.
1. In LiveSplit, set "Game Time" as your main timing method
   * Right-click the main window ➞ Compare Against ➞ Game Time. (Both real time and time without loads are stored in your splits regardless.)

## Autosplitting

Generally, progressing through the campaign missions should trigger the autosplitter on each mission change. However, due to the nature of the dual mission chapters, it may trigger pretty often in certain portions of the run.

A split is triggered whenever the selected mission ID changes, or is deselected. There are points in the run where you press "J" to quick swap missions, or open the mission menu to manually select a mission. You should expect a split to trigger there. Sometimes there are mission swaps that aren't routed in, so make sure you know your "Undo Split" hotkey to fix any unintended splits.

### Advanced Options

When the "Split for recruitment missions" option is disabled, a transition to or from a recruitment mission will be ignored.

This means if "Split for recruitment missions" is **enabled**, you should have 3 splits in *Reporting for Duty*:

* Reporting for Duty (1)
* Recruit a construction worker
* Reporting for Duty (2)

If "Split for recruitment missions" is **disabled**, you should have 1 split in *Reporting for Duty*.

This option doesn't apply for the EPC Albion recruit, as it doesn't force switch you to a recruitment mission.

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

#### Loading

1. Launch the game into DX11 mode
1. Attach to `WatchDogsLegion.exe`
1. Set "Memory Scan Options" to `DuniaDemo_clang_64_dx11.dll`
1. Load into a file and scan for a **4 Byte** value of `1`
1. Once the game loads, refine the search with a value of `0`
1. Add the address to the ASL scruot
1. Repeat for DX12.

#### Mission Count

| Active mission in route order | Mission Count |
|-------------------------------|---------------|
| Operation Westminster         | 1             |
| Restart DedSec                | 2             |
| Light a Spark                 | 3             |
| Clarion Call                  | 4             |
| Reporting for Duty (1)        | 5             |
| Recruit a construction worker | 6             |
| Reporting for Duty (2)        | 7             |
| Digging up the past           | 8             |

This is a mission count variable. It does not persist through savegame exits, so loading into a save will set it to 1.
To search for the variable, you must play through the intro up to *Clarion Call* multiple times.

1. Launch the game into DX11 mode
1. Attach to `WatchDogsLegion.exe`
1. Start a new game, once you gain control, search for a **4 byte** exact value of 1
1. Then search for unchanged value on repeat until the before end of *Operation Westminster*
1. In the Blume spiderbot portion search for an increased value of 1, then repeat on unchanged again until before you exit the safehouse
1. Once the *Light a Spark* objectives appear, search for an increased value of 1, then repeat on unchanged again until before you do the Camden objective
1. Once the *Clarion Call* objective appears, search for an increased value of 1, and select the **second** of the two remaining addresses
1. Generate a pointermap and save it
1. Pointerscan for the address and save it
1. Restart the game and repeat the process, comparing the pointerscan results with the previous
1. Sort the pointers by "Offset 1" and choose a pointer with only one offset and save it
1. Repeat for DX12.

#### Mission ID

Finding the mission ID values from scratch is a pain, so hopefull the following ones stick around through updates:

| Selected mission     | Mission ID           |
|----------------------|----------------------|
| None                 | -1                   |
| Clarion Call         | -2314395300743091072 |
| Initiate Sequence    | -1860909611898991633 |
| Inside Albion        | -1860909419468514552 |
| The Whistleblower    | -1860909604697338304 |
| Crashing the Auction | -1860909603611013565 |

1. Launch the game into DX11 mode
1. Attach to `WatchDogsLegion.exe`
1. Load into a dual mission chapter and scan for a **8 Byte** with the appropriate mission ID value from the above table
1. Select/deselect missions (right click) in the menu while searching for values until you get about 9 addresses
1. Generate a pointermap
1. Pointerscan each address until you get one that only returns one result; it's usually the last one
1. Add the result to the address list (double click the base address)
1. Repeat for DX12.

### Resources

* [LiveSplit Docs](https://github.com/LiveSplit/LiveSplit.AutoSplitters)
* [Alan Wake ASL](https://github.com/tduva/LiveSplit-ASL)
* [Watch_Dogs 2 ASL](https://github.com/zoton2/LiveSplit.Scripts)
