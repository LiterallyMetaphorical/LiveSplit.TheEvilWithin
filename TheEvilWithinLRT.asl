//Original Splitter by Mattmatt
//IGT by Mysterion_06_
//Startup Prompt, Text Components, & LRT Timing added by Meta

state("EvilWithin")
{
    int isPaused         : 0x88C4BB8; // 2 while paused, 1 in game
    int inGame           : 0x9A55EB0; // 0 on main menu and loading screen, 1 always when in game
    string150 chapterName: 0x9A55110; //see bottom of script for chapter list (prettified)
    int IGT            : 0x9ACE548, 0x82040, 0xB4;
    int chapterNumber  : 0x2133158; // 1 for ch1, 2 for ch2, etc.
}

init
{
//Helps catch errors when string pointers are null
    current.chapterName = "";
    current.chapterNamePretty = "";
}

startup
{
    //Checks if the current time method is Real Time, if it is then it spawns a popup asking to switch to Game Time
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | The Evil Within",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );

        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

    //creates text components for variable information
	vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
	        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
	        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
	        if (textSetting == null)
	        {
	        var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
	        var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
	        timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
	
	        textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
	        textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
	        }
	
	        if (textSetting != null)
	        textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
    });

    vars.DoLoad = false;

    //Parent setting
	settings.Add("Variable Information", true, "Variable Information");
	//Child settings that will sit beneath Parent setting
    settings.Add("Chapter Name", true, "Current Chapter Name", "Variable Information");
    settings.Add("In-Game Time", true, "Current IGT", "Variable Information");
}

update
{
//cutting the first 13 characters off the string value for a prettier name to work with
    current.chapterNamePretty = current.chapterName.Substring(13);

    //Prints current chapter
    if(settings["Chapter Name"]){vars.SetTextComponent("Chapter ",current.chapterNamePretty.ToString());}
    //Prints IGT
    if(settings["In-Game Time"]){vars.SetTextComponent("In-Game Time",(TimeSpan.FromSeconds(current.IGT)).ToString());}

    //Code written by Kuno / Meta
    //There is a small amount of time between pause menu and when loading starts, so we're checking if we're on an pause screen then setting doload to true until the load screen - removing the small time variation.
    if (vars.DoLoad == false && current.isPaused == 2)
    {
        print("Starting DoLoad");
        vars.DoLoad = true;
    }
    // After the above if is ran and do load is enabled, we check if we're currently loading (which doesn't equal 0 when loading) and disable it as the syncloadcount should be actively removing them anyway
    if (vars.DoLoad == true && current.inGame == 0 || vars.DoLoad == true && current.isPaused == 1)
    {
        print("Cancelling DoLoad");
        vars.DoLoad = false;
    }

//DEBUG CODE
//print("IGT: " + current.IGT.ToString());
//print("isLoading? " + current.loading.ToString());
//print(modules.First().ModuleMemorySize.ToString());
}

start
{
    return current.chapterNamePretty == "an_emergency_call" && current.IGT == 0;
}

split
{ 
    return
    (
        (old.chapterNumber == 1 && current.chapterNumber == 2) ||
        (old.chapterNumber == 2 && current.chapterNumber == 3) ||
        (old.chapterNumber == 3 && current.chapterNumber == 4) ||
        (old.chapterNumber == 4 && current.chapterNumber == 5) ||
        (old.chapterNumber == 5 && current.chapterNumber == 6) ||
        (old.chapterNumber == 6 && current.chapterNumber == 7) ||
        (old.chapterNumber == 7 && current.chapterNumber == 8) ||
        (old.chapterNumber == 8 && current.chapterNumber == 9) ||
        (old.chapterNumber == 9 && current.chapterNumber == 10) ||
        (old.chapterNumber == 10 && current.chapterNumber == 11) ||
        (old.chapterNumber == 11 && current.chapterNumber == 12) ||
        (old.chapterNumber == 12 && current.chapterNumber == 13) ||
        (old.chapterNumber == 13 && current.chapterNumber == 14) ||
        (old.chapterNumber == 14 && current.chapterNumber == 15)
    );
}

isLoading
{
    return current.inGame == 0 || current.isPaused == 2;
}

exit
{
	timer.IsGameTimePaused = true;
}

/*
Chapter names in memory (prettified versions, see "chapterNamePretty")
1. an_emergency_call
2. Remnants
3. Claws_of_the_Horde
4. Inner_Recesses
5. inner_recesses (wtf), lower case if entered by transitioning from ch4 - still uppercase like ch4 if loaded from chapter select (?!?!)
6. Losing_Grip_on_Ourselves
7. The_Keeper
8. a_planted_seed_will_grow
9. the_cruelest_intentions
10. the_craftsmans_tools
11. Reunion
12. The_Ride
13. casualties
14. Ulterior_Motives 
15. an_evil_within
*/
