/* IMPORTANT:
You need to add -BattlEyeLauncher to your launch options (in uPlay/Epic Games/shortcut) so the memory can be read.
This disables BattlEye (and online MP).
See README.d for more information.
*/

state("WatchDogsLegion")
{
    // unknown/default version
}

state("WatchDogsLegion", "v1.2.40")
{
    int loading1 : "DuniaDemo_clang_64_dx11.dll", 0xB0664D4;
    int loading2 : "DuniaDemo_clang_64_dx12.dll", 0xB0F4524;
    long missionId1 : "DuniaDemo_clang_64_dx11.dll", 0x0B0AF8D8, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90;
    long missionId2 : "DuniaDemo_clang_64_dx12.dll", 0x0B21F420, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90;
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

    Func<long, byte[], bool> beginsWithBytes = (l, prefix) => {
        byte[] longBytes = BitConverter.GetBytes(l);
        Array.Reverse(longBytes); // Weird endian stuff
        // vars.logDebug("longBytes: " + BitConverter.ToString(longBytes));
        int i = 0;
        foreach (byte b in prefix) {
            if ( b != longBytes[i] ) return false;
            i++;
        }
        return true;
    };
    vars.beginsWithBytes = beginsWithBytes;

    settings.Add("RecruitmentSplit", false, "Split for recruitment missions");
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
            vars.recruitPrefix = new byte[] {0xC8, 0xA1, 0x7D}; // The first 3 bytes of a recruitment mission ID converted to hex
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
    if (version != "") {
        // Collapse DX11/DX12 variables to one variable
        long oldMissionId, currentMissionId;
        oldMissionId = old.missionId1 != 0  ? old.missionId1 : old.missionId2;
        currentMissionId = current.missionId1 != 0 ? current.missionId1 : current.missionId2;

        // vars.logDebug("oldMissionId: " + oldMissionId);
        // vars.logDebug("currentMissionId: " + currentMissionId);
        
        // If the settings disabled splits on recruitment, check if the old or current ID is a recruitment ID and short circuit
        if (!settings["RecruitmentSplit"] && (vars.beginsWithBytes(currentMissionId, vars.recruitPrefix) || vars.beginsWithBytes(oldMissionId, vars.recruitPrefix))) {
            // vars.logDebug("This is a recruitment mission, skipping...");
            return;
        }
         // Don't split coming from a null mission
        if (oldMissionId != -1)
            return oldMissionId != currentMissionId;
    }
}