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
    int deedCount1 : "DuniaDemo_clang_64_dx11.dll", 0x0AFA8940, 0x30, 0x198;
    int deedCount2 : "DuniaDemo_clang_64_dx12.dll", 0x0B036950, 0x30, 0x198;
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

    Func<int, int, bool> isMiddleLightASpark = (oldCount, currentCount) => {
        // Each objective in Light a Spark increments the deed count, so we need to ignore it
        return oldCount == 3 && currentCount == 4;
    };
    vars.isMiddleLightASpark = isMiddleLightASpark;

    Func<int, int, bool> isValidDeedIncrement = (oldCount, currentCount) => {
        return oldCount + 1 == currentCount && !vars.isMiddleLightASpark(oldCount, currentCount);
    };
    vars.isValidDeedIncrement = isValidDeedIncrement;
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
        int oldDeedCount, currentDeedCount;
        oldDeedCount = old.deedCount1 != 0  ? old.deedCount1 : old.deedCount2;
        currentDeedCount = current.deedCount1 != 0 ? current.deedCount1 : current.deedCount2;

        long oldMissionId, currentMissionId;
        oldMissionId = old.missionId1 != 0  ? old.missionId1 : old.missionId2;
        currentMissionId = current.missionId1 != 0 ? current.missionId1 : current.missionId2;

        // vars.logDebug("oldDeedCount: " + oldDeedCount);
        // vars.logDebug("currentDeedCount: " + currentDeedCount);
        
        if (vars.isValidDeedIncrement(oldDeedCount, currentDeedCount) || vars.isClarionCall(oldMissionId, currentMissionId))
            return true;
    }
}