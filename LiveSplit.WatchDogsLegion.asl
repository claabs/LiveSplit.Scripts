/* IMPORTANT:
You need to add -BattlEyeLauncher to your launch options (in Ubisoft Connect/Epic Games/Steam shortcut) so the memory can be read.
This disables BattlEye anti-cheat.
See Readme.md for more information.
*/

state("WatchDogsLegion")
{
    // unknown/default version
}

state("WatchDogsLegion", "v1.2.40")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB0664D4;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB0F4524;
    int etoOnIncrease1 : "DuniaDemo_clang_64_dx11.dll", 0x0B078530, 0x638;
    int etoOnIncrease2 : "DuniaDemo_clang_64_dx12.dll", 0x0B106580, 0x638;
    long missionId1 : "DuniaDemo_clang_64_dx11.dll", 0x0B0AF8D8, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90;
    long missionId2 : "DuniaDemo_clang_64_dx12.dll", 0x0B21F420, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90;
    int missionIncrementer1 : "DuniaDemo_clang_64_dx11.dll", 0x0B004370, 0x50;
    int missionIncrementer2 : "DuniaDemo_clang_64_dx12.dll", 0x0B092380, 0x50;
}

state("WatchDogsLegion", "v1.3.0")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xAE2FE10;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xAEC0E10;
}

state("WatchDogsLegion", "v1.4.5")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB424144;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB4B8154;
}

state("WatchDogsLegion", "v1.5.0")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB3C25F4;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB458614;
}

state("WatchDogsLegion", "v1.5.6")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB465164;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB4F91F4;
}

state("WatchDogsLegion", "v1.5.6-steam")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB274020;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB309020;
}

// For 1.6.3, uplay and steam have the same memory addresses
state("WatchDogsLegion", "v1.6.3")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB46C234;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB501274;
}

startup
{
    Action<string> logDebug = (text) => {
        print("[WatchDogsLegion Autosplitter | DEBUG] "+ text);
    };
    vars.logDebug = logDebug;

    Func<ProcessModuleWow64Safe, string> calcModuleHash = (module) => {
        vars.logDebug("Calcuating hash of " + module.FileName);
        byte[] exeHashBytes = new byte[0];
        using (System.Security.Cryptography.MD5 sha = System.Security.Cryptography.MD5.Create())
        {
            using (FileStream s = File.Open(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            {
                exeHashBytes = sha.ComputeHash(s);
            }
        }
        string hash = exeHashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
        vars.logDebug("Hash: " + hash);
        return hash;
    };
    vars.calcModuleHash = calcModuleHash;
    
    Func<int, int, bool> isValidETOIncrease = (oldETO, currentETO) => {
        int increase = currentETO - oldETO;
        bool isValid = increase >= 300 // Random hacks and Connie fight reward 
            && increase != 2000 // Not sure??
            && increase % 25 == 0;
        if (isValid) vars.logDebug("Valid ETO increase of: " + increase);
        return isValid;
    };
    vars.isValidETOIncrease = isValidETOIncrease;

    Func<long, long, bool> isValidMissionChange = (oldMissionId, currentMissionId) => {
        bool isValid = (oldMissionId == -387354043842124764 && currentMissionId == -1) // Operation Westminster
            || (oldMissionId == -2314395300743091072 && currentMissionId == -1); // Clarion Call
        if (isValid) vars.logDebug("Valid mission change. Old mission: " + oldMissionId + " Current mission: " + currentMissionId);
        return isValid;
    };
    vars.isValidMissionChange = isValidMissionChange;

    vars.lastSplitTime = null;
	Func<bool> isNotDoubleSplit = () => {
		bool isDoubleSplit = false;
		if (vars.lastSplitTime != null) {
			System.TimeSpan ts = System.DateTime.Now - vars.lastSplitTime;
			if (ts.TotalSeconds < 20) {
				isDoubleSplit = true;
				vars.logDebug("Double split detected!");
			}
		}
		vars.lastSplitTime = System.DateTime.Now;
		return !isDoubleSplit;
	};
	vars.isNotDoubleSplit = isNotDoubleSplit;
}

init
{
    // vars.logDebug("modules: " + String.Join(", ", modules.Select(m=> m.ModuleName + " : " + m.BaseAddress.ToString() + " : " + m.EntryPointAddress.ToString())));
    ProcessModuleWow64Safe exeModule = modules.Single(x => String.Equals(x.ModuleName, "WatchDogsLegion.exe", StringComparison.OrdinalIgnoreCase));
    string exeHash = vars.calcModuleHash(exeModule);
    switch (exeHash)
    {
        case "5048291D38DAC9E5988DC4572AE8717A":
            version = "v1.2.40";
            vars.canSplit = true;
            break;
        case "84C62FF86AD4656665C3FE6AC48440C2":
            version = "v1.3.0";
            vars.canSplit = false;
            break;
        case "038A5206E1ED75474323064FE7BF403F":
            version = "v1.4.5";
            vars.canSplit = false;
            break;
        case "21295E34CFFC0085843003E039C6FCE3":
            version = "v1.5.0";
            vars.canSplit = false;
            break;
        case "028ABAE67F2725010F9D7CE0296FA63C":
            // uplay 1.5.6 and 1.6.3 use the same exe, so we use dunia DLL size to pick the right version
            ProcessModuleWow64Safe duniaModule = modules.Single(x => x.ModuleName.StartsWith("DuniaDemo_clang_64_dx", StringComparison.OrdinalIgnoreCase));
            int duniaModuleSize = duniaModule.ModuleMemorySize;
            vars.logDebug("duniaModuleSize: " + duniaModuleSize);
            switch(duniaModuleSize)
            {
                case 583057408:
                    // dx11
                    vars.canSplit = false;
                    version = "v1.5.6";
                    break;
                case 618889216:
                    // dx12
                    vars.canSplit = false;
                    version = "v1.5.6";
                    break;
                case 592404480:
                    vars.canSplit = false;
                    version = "v1.6.3"; // dx11
                    break;
                case 555307008:
                    vars.canSplit = false;
                    version = "v1.6.3"; // dx12
                    break;
                default:
                    throw new NotImplementedException("Unrecognized duniaModuleSize: " + duniaModuleSize);
                    break;
            }
            break;
        case "5A08AC162D338BC128CAF96A2F2FEE34":
            version = "v1.5.6-steam";
            vars.canSplit = false;
            break;
        case "5DAB2D2F973BA4C35BEA0769F8BD7913":
            // steam 1.6.3 exe
            version = "v1.6.3";
            vars.canSplit = false;
            break;
        default:
            throw new NotImplementedException("Unrecognized hash: " + exeHash);
            break;
    }
}

isLoading
{
    if (version != "")
        return current.loading1 > 0 || current.loading2 > 0;
}

split {
    if (version != "" && vars.canSplit) {
        // Collapse DX11/DX12 variables to one variable
        // int oldETO, currentETO;
        int oldMissionIncrementer, currentMissionIncrementer;
        // long oldMissionId, currentMissionId;
        // oldETO = old.etoOnIncrease1 != 0  ? old.etoOnIncrease1 : old.etoOnIncrease2;
        // currentETO = current.etoOnIncrease1 != 0 ? current.etoOnIncrease1 : current.etoOnIncrease2;
        // oldMissionId = old.missionId1 != 0  ? old.missionId1 : old.missionId2;
        // currentMissionId = current.missionId1 != 0 ? current.missionId1 : current.missionId2;
        oldMissionIncrementer = old.missionIncrementer1 != 0 ? old.missionIncrementer1 : old.missionIncrementer2;
        currentMissionIncrementer = current.missionIncrementer1 != 0 ? current.missionIncrementer1 : current.missionIncrementer2;

        // vars.logDebug("oldMissionCount: " + oldMissionCount);
        // vars.logDebug("currentMissionCount: " + currentMissionCount);
        
        if (oldMissionIncrementer != currentMissionIncrementer && vars.isNotDoubleSplit())
            return true;
    }
}
