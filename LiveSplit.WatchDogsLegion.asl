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
    vars.version = "";
    vars.dx11_dll = "DuniaDemo_clang_64_dx11.dll";
    vars.dx12_dll = "DuniaDemo_clang_64_dx12.dll";

    vars.handleVersion = (Func<bool>) (() => {
        string moduleName = "";
        // print("modules: " + String.Join(", ", modules.Select(m=> m.ModuleName)));
        if (modules.Any(m => m.ModuleName == vars.dx11_dll)) {
            moduleName = vars.dx11_dll;
        }
        if (modules.Any(m => m.ModuleName == vars.dx12_dll)) {
            moduleName = vars.dx12_dll;
        }
        print("Using moduleName: " + moduleName);
        if (moduleName != "") {
            // print("Using moduleName: " + moduleName);
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
            vars.version = version;
            print("version set to: " + version);
            return true;
        }
        // If `init` is running due to game launch, the DLLs won't be available yet, so we call this function again in `update`
        return false;
    });

    print("Getting version in `init`");
    vars.handleVersion();
}

update
{
    // We check `vars.version`, since `version` is always "" here
    if (vars.version == "") {
        print("Getting version in `update`");
        // If we haven't found the version yet, try to get it
        // WARNING: This doesn't work, as the module list doesn't update after `init`. TODO: Get version from init modules?
        // We return the boolean result so the autosplitter doesn't act if a version isn't found
        return vars.handleVersion();
    }
}

// exit
// {
//     vars.version = "";
// }

isLoading
{
	if (version != "")
		return current.loading1 > 0;
}