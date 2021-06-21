/* IMPORTANT:
You need to add -BattlEyeLauncher to your launch options (in uPlay/Epic Games/shortcut) so the memory can be read.
This disables BattlEye (and online MP).
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
    int etoOnIncrease1 : "DuniaDemo_clang_64_dx11.dll", 0x0B21CE60, 0x638;
    int etoOnIncrease2 : "DuniaDemo_clang_64_dx12.dll", 0x0B2ADED0, 0x638;
    long missionId1 : "DuniaDemo_clang_64_dx11.dll", 0x0B0AF8D8, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90; // TODO
    long missionId2 : "DuniaDemo_clang_64_dx12.dll", 0x0B21F420, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90; // TODO
}

state("WatchDogsLegion", "v1.4.5")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB424144;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB4B8154;
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
    ProcessModuleWow64Safe module = modules.Single(x => String.Equals(x.ModuleName, "WatchDogsLegion.exe", StringComparison.OrdinalIgnoreCase));
    string hash = vars.calcModuleHash(module);
    switch (hash)
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
        default:
            throw new NotImplementedException("Unrecognized hash: " + hash);
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
