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

    int lineIdIdx0: "DuniaDemo_clang_64_dx11.dll", 0xB3D1450, 0x38;
    int lineIdIdx1: "DuniaDemo_clang_64_dx12.dll", 0xB467470, 0x38;

    int LineID1: "DuniaDemo_clang_64_dx11.dll", 0xB3D1450, 0x90, 0x10, 0x48;
    int LineID2: "DuniaDemo_clang_64_dx12.dll", 0xB3DC190, 0x8, 0x68, 0x88, 0x8, 0x48, 0x48;

    int etoOnIncrease1 : "DuniaDemo_clang_64_dx11.dll", 0xB3E36A0, 0x638;
    int etoOnIncrease2 : "DuniaDemo_clang_64_dx12.dll", 0xB4796D8, 0x638;
    
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

    int lineIdIdx0: "DuniaDemo_clang_64_dx11.dll", 0xB47B0A0, 0x38;
    int lineIdIdx1: "DuniaDemo_clang_64_dx12.dll", 0xB5100E0, 0x38;

    int etoOnIncrease1 : "DuniaDemo_clang_64_dx11.dll", 0xB48D380, 0x638;
    int etoOnIncrease2 : "DuniaDemo_clang_64_dx12.dll", 0xB5223C0, 0x638;
    
    int LineID1: "DuniaDemo_clang_64_dx11.dll", 0xB47B0A0, 0x90, 0x10, 0x48;
    int LineID2: "DuniaDemo_clang_64_dx12.dll", 0xB5100E0, 0x90, 0x10, 0x48;
}

startup
{
    vars.stopwatch = new Stopwatch();
    vars.line0Stopwatch = new Stopwatch();
    vars.line1Stopwatch = new Stopwatch();

    settings.Add("Log Dialog", false, "Log Dialog");
    settings.SetToolTip("Log Dialog", "Log line IDs and their duration in milliseconds as they occurred in the run to LineLog.txt next to your LiveSplit.exe");

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

    vars.lastSplitTime = null;
	Func<bool> isNotDoubleSplit = () => {
		bool isDoubleSplit = false;
		if (vars.lastSplitTime != null) {
			System.TimeSpan ts = System.DateTime.Now - vars.lastSplitTime;
			if (ts.TotalSeconds < 30) {
				isDoubleSplit = true;
				vars.logDebug("Double split detected!");
			}
		}
		vars.lastSplitTime = System.DateTime.Now;
		return !isDoubleSplit;
	};
	vars.isNotDoubleSplit = isNotDoubleSplit;
    
    Action<string> logLine = (text) => {
		vars.logDebug("Writing line: " + text);
		if (vars.lineLogFile == null) {
			vars.lineLogFile = File.Open("LineLog.txt", FileMode.Append, FileAccess.Write, FileShare.ReadWrite);
		}
		byte[] line = new UTF8Encoding(true).GetBytes(text + "\r\n");
		vars.lineLogFile.Write(line, 0, line.Length);
		vars.lineLogFile.Flush(true);
	};
	vars.lineLogFile = null;
	vars.logLine = logLine;

    	Action<int, int, Stopwatch> detectLineChange = (oldLineId, newLineId, stopwatch) => {
		// if (oldLineId != newLineId) {
		// 	vars.logDebug("oldLineId:" + oldLineId + " newLineId:" + newLineId);
		// }

		if (oldLineId <= 0 && newLineId > 0) {
			// no dialog -> dialog
			stopwatch.Restart();
		} else if (oldLineId > 0 && newLineId == -1) {
			// dialog -> no dialog
			vars.logLine(oldLineId + "\t" + stopwatch.ElapsedMilliseconds);
		} else if (oldLineId != newLineId && oldLineId > 0 && newLineId > 0) {
			// Dialog -> different dialog
			vars.logLine(oldLineId + "\t" + stopwatch.ElapsedMilliseconds);
			stopwatch.Restart();
		}	
	};
	vars.detectLineChange = detectLineChange;

}

shutdown
{
	if (vars.lineLogFile != null) {
		vars.lineLogFile.Dispose();
		vars.lineLogFile = null;
	}
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
            vars.canSplit = true;
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
                    vars.canSplit = true;
                    version = "v1.6.3"; // dx11
                    break;
                case 555307008:
                    vars.canSplit = true;
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
            vars.canSplit = true;
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


update
{
    vars.lineID1 = current.LineID1;
    vars.lineID2 = current.LineID2;
  

    if (vars.stopwatch.ElapsedMilliseconds > 20000)
		vars.stopwatch.Reset();

    
    if (settings["Log Dialog"]) {
			vars.detectLineChange(old.lineIdIdx0, current.lineIdIdx0, vars.line0Stopwatch);
			vars.detectLineChange(old.lineIdIdx1, current.lineIdIdx1, vars.line1Stopwatch);
		}
    
     if (old.LineID1 != current.LineID1)
		print("LineID: " + vars.lineID1);	
    if (old.LineID2 != current.LineID2)
		print("LineID: " + vars.lineID2);
    

}


start
{
    return current.LineID1 == 1136464 || current.LineID2 == 1136464;    //Legion Main Story Start
   
    return current.LineID1 == 1176641 || current.LineID2 == 1176641; 	//Add 7.150 seconds to starting timer for Bloodline
    
}


split {
    if (version != "" && vars.canSplit) {
        
        	if(current.lineIdIdx0 == 1068605 || current.lineIdIdx1 == 1068605)       //Operation Westminster
			{
				vars.splitTimeOffset = 3.33;
				vars.stopwatch.Restart();
			}

		if(current.LineID1 == 1193809 && current.loading1 > 0 || current.LineID2 == 1193809 && current.loading2 > 0)       //Restart Dedsec
			        return vars.isNotDoubleSplit();

		if(current.etoOnIncrease1 > old.etoOnIncrease1 + 400 || current.etoOnIncrease2 > old.etoOnIncrease2 + 400)  
				return vars.isNotDoubleSplit();

		if(current.lineIdIdx0 == 1195578 || current.lineIdIdx1 == 1195578)       //Acquisition Target
			{
				vars.splitTimeOffset = 2.317;
				vars.stopwatch.Restart();
			}

		if(current.lineIdIdx0 == 1174592 || current.lineIdIdx1 == 1174592)       //Red King
				return vars.isNotDoubleSplit();   

		if(current.lineIdIdx1 == 1174652 || current.lineIdIdx1 == 1174652)       //Jacks
			{		
				vars.splitTimeOffset = 3.1;
				vars.stopwatch.Restart();
			}
		
		if(current.lineIdIdx0 == 1175030 || current.lineIdIdx1 == 1175030)       //Friends in Low Places
			{		
				vars.splitTimeOffset = 12;
				vars.stopwatch.Restart();
			}

		if(current.lineIdIdx0 == 1186507 || current.lineIdIdx1 == 1186507)       //Shoeleather
				return vars.isNotDoubleSplit();   

		if(current.lineIdIdx0 == 1179051 || current.lineIdIdx1 == 1179051)       //Spanner in the Works
			{		
				vars.splitTimeOffset = 5.767;
				vars.stopwatch.Restart();
			} 

		if(current.lineIdIdx0 == 1195605 || current.lineIdIdx0 == 1195606 || current.lineIdIdx1 == 1195605 || current.lineIdIdx1 == 1195606)    //Dark Pattern
			 {   
				vars.splitTimeOffset = 6.117;
				vars.stopwatch.Restart();
		         }

		if(current.LineID1 == 1192403 && current.loading1 > 0 || current.LineID2 == 1192403 && current.loading2 > 0)       //Fox Hunt
			        return vars.isNotDoubleSplit();

        	if(current.LineID1 == 1192451 && current.loading1 > 0 || current.LineID2 == 1192451 && current.loading2 > 0)       //Red Queen
			        return vars.isNotDoubleSplit();

        	if(current.lineIdIdx0 == 1195622 || current.lineIdIdx1 == 1195622)       //Bury Your Dead
			     
			{
				vars.splitTimeOffset = 4.217;
				vars.stopwatch.Restart();
			} 
      
        	if(current.lineIdIdx0 == 1207040 || current.lineIdIdx1 == 1207040)       //Face 2 Face
				return vars.isNotDoubleSplit(); 

		if(vars.stopwatch.IsRunning && vars.stopwatch.Elapsed.TotalSeconds >= vars.splitTimeOffset)
			{
				vars.stopwatch.Reset();
			 	return vars.isNotDoubleSplit();                    //Delayed Split Timing
    			}

	}			
}
