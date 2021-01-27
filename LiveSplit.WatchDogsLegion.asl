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
    long missionId1 : "DuniaDemo_clang_64_dx11.dll", 0x0B0AF8D8, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90;
    long missionId2 : "DuniaDemo_clang_64_dx12.dll", 0x0B21F420, 0x410, 0x3D8, 0x3F8, 0x3D8, 0x3E0, 0x3D8, 0xF90;
    int missionCount1: "DuniaDemo_clang_64_dx11.dll", 0x0AFD9CA8, 0xE4;
    int missionCount2: "DuniaDemo_clang_64_dx12.dll", 0x0AFD9CA8, 0xE4; // TODO
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

    Func<long, long, bool> isClarionCall = (oldId, currentId) => {
        // Clarion Call doesn't increment the deed count, so we have this special case
        return oldId == vars.clarionCallId && currentId == -1;
    };
    vars.isClarionCall = isClarionCall;

    Func<int, int, bool> isValidCountIncrement = (oldCount, currentCount) => {
        // The mission count increments to 1 when loading a save, so ignore that
        return oldCount + 1 == currentCount && currentCount != 1;
    };
    vars.isValidCountIncrement = isValidCountIncrement;
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
            vars.clarionCallId = -2314395300743091072l;
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
        int oldMissionCount, currentMissionCount;
        oldMissionCount = old.missionCount1 != 0  ? old.missionCount1 : old.missionCount2;
        currentMissionCount = current.missionCount1 != 0 ? current.missionCount1 : current.missionCount2;

        long oldMissionId, currentMissionId;
        oldMissionId = old.missionId1 != 0  ? old.missionId1 : old.missionId2;
        currentMissionId = current.missionId1 != 0 ? current.missionId1 : current.missionId2;

        // vars.logDebug("oldMissionCount: " + oldMissionCount);
        // vars.logDebug("currentMissionCount: " + currentMissionCount);
        
        if (vars.isValidCountIncrement(oldMissionCount, currentMissionCount))
            return true;
    }
}