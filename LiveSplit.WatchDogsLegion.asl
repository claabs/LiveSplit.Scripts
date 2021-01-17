/* Inspired by zoton2: https://github.com/zoton2/LiveSplit.Scripts */

/* IMPORTANT:
You need to add -BattlEyeLayncher to your launch options (in uPlay/Epic Games/shortcut) so the memory can be read.
This disables BattlEye (and online MP). If this doesn't seem to work, try restarting your PC.
(I know this sounds crazy but it actually worked for me and others online.)
See LiveSplit.WatchDogsLegion-README for more information.
*/

state("WatchDogsLegion")
{
	// unknown/default version
}

state("WatchDogsLegion", "v1.2.40")
{
	int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB0664D4;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB0F4524;
}

init
{
    int moduleMemorySize = modules.FirstOrDefault(m => m.ModuleName == "WatchDogsLegion.exe").ModuleMemorySize;
    switch (moduleMemorySize)
    {
        case 163840:
            version = "v1.2.40";
            break;
    }
}

isLoading
{
	if (version != "")
		return current.loading1 > 0 || current.loading2 > 0;
}