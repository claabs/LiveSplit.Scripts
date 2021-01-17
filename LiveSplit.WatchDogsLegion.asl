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

state("WatchDogsLegion", "v1.2.40_dx11")
{
	int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB0664D4;
}
state("WatchDogsLegion", "v1.2.40_dx12")
{
	int loading1 : "DuniaDemo_clang_64_dx12.dll", 0xB0F4524;
}

init
{
    string dx11_dll = "DuniaDemo_clang_64_dx11.dll";
    string dx12_dll = "DuniaDemo_clang_64_dx12.dll";

    string moduleName = "";
    if (modules.Any(m => m.ModuleName == dx11_dll)) {
        moduleName = dx11_dll;
    }
    if (modules.Any(m => m.ModuleName == dx12_dll)) {
        moduleName = dx12_dll;
    }
    print("Using moduleName: " + moduleName);

    /* 
    The ModuleMemorySize here can be retrieved from Cheat Engine by:
    1. Attach to Watch Dogs: Legion process
    2. Table > Show Cheat Table Lua Script
    3. Paste in `print(getModuleSize("DuniaDemo_clang_64_dx11.dll"))` or `print(getModuleSize("DuniaDemo_clang_64_dx12.dll"))`
    4. Click "Execute script"
    */

    if (moduleName != "") {
        int moduleMemorySize = modules.FirstOrDefault(m => m.ModuleName == moduleName).ModuleMemorySize;
        print("moduleMemorySize is: " + moduleMemorySize);
        switch (moduleMemorySize)
        {
            case 587149312:
                version = "v1.2.40_dx11";
                break;
            case 596590592:
                version = "v1.2.40_dx12";
                break;
        }
    }
    print("version is: " + version);
}

isLoading
{
	if (version != "")
		return current.loading1 > 0;
}