# Disable Network Protection Service
Here's a quick guide about how to restore access to basically any site and use any web based software, such as Steam.
This has been only tested on Tredu enrolled devices with Intune.

> [!WARNING]
> You are responsible for whatever you do with "your" device. I'm not responsible for any damage, fines or any consequences regarding things you've made to the device.
> This is purely for educational purposes and to discover any loop holes with these kind of locking down systems.

### Quick info about how this works
If you know anything about Windows and how most settings are stored on Windows, then you should know about Registery Editor. This is a bundled software specifically to view and confgiure any registery value under Windows or any program that stores settings, user info, paths, etc. there.
Windows Defender also stores it's settings in Registery. Since we cannot access nor disable Defender settings from it's app, we have to go configure our setting via Registery Editor. 
Defender path is located here: `Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager`. 

Defender registery folder has this key: `EnableNetworkProtection`, which is by default set to `1` aka `true`. This is our jackpot, basically. 
Setting this DWORD value to `0` (`false`) will disable network protection, allowing us to freely access any website once again. This doesn't require restart, since I guess Defender listens to key changes internally and changes behavior on events.

But you'll soon notice that you can't access websites again and check on the key, and it's by miracle has turned back on. Well, there is a background task on Windows, which is managed by *Intune*. Intune is Microsoft's solution on managing a lot of Windows device from one interface for corporation, or in my case, schools.
Intune allows setting certain settings on/off, lock those settings, disallow executing apps and much more. Intune can also set Registery values. Intune has also a client application, which "checks in" to servers to request most up-to-date data, and configures the Windows as per data. Intune also works offline, so it must save those values somewhere. And what you know, it saves them in Registery.
Intune settings are saved in sneaky way on this path: `Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PolicyManager\current\device`, and Intune's settings about Defender here: `Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PolicyManager\current\device\Defender`.
Intune Defender path has following key burried: `EnableNetworkProtection_WinningProvider`, this is basically a cached version of the Intune server value. Setting this value to also `false` will extend our fixes "working time lenght", but not for forever, until Intune checks in and patches values again.

Doing this will become quite boring and repetetive after a while. Why not automate this? That is an excellent idea!

### How can this process be automated?
Task scheduler is the answer. Task scheduler as the name suggests, schedules tasks to be executed at certain times, after certain time or after some trigger. Task scheduler also allows us to create tasks via it's GUI interface.
I've made a quick .ps1 script, which when executed, will (should at least) turn off `EnableNetworkProtection` key. We will call this PowerShell script via our custom task in Task Scheduler.

### The Guide
After you've grabbed the .ps1 script, you can go ahead and type 'Task Scheduler' in search bar in Windows.
Once open, you'll have on the left task folder hierarchy, in centre tasks in selected folder and some settings for that task. On the right you have some quick actions.

For sake of clean "install", we'll create a new folder:
1. Right click on the 'Task Scheduler Library' and select 'New Folder...'
2. Give it a name you like, I'll call mine 'Custom'
3. Press Ok

Nice! We now have folder to play with, next we'll create a task:
1. Click on the folder to open it in centre of the Task Scheduler
2. Navigate to the right menu and click 'Create Task'
3. Give it a name, you can call this whatever you want. I'll call mine 'DisableNetworkProtectionTask'.
4. You can keep the 'Run only when user is logged on' as is, turn on 'Run with highest privileges'.
5. Open 'Triggers' at the top of the popup window.
6. Press 'New...' and set settings to following:
```
Daily
Repeat task every: 1 Hour
Enabled
```
7. After setting settings, press 'OK'.
8. Open 'Actions' at the top of the popup window.
9. Press 'New...'
10. In the 'Program/script' section type: `powershell.exe`
11. In the 'Add arguments (Optional)' type: `-ExecutionPolicy Bypass -NonInteractive -File "C:\PATH\TO\THE\POWERSHELL\SCRIPT"`, where you replace the 'C:\PATH\TO\THE\POWERSHELL\SCRIPT' with full path to your downloaded .ps1 script. You can move the script somewhere else, such as 'Documents', but make sure you save it locally and not in OneDrive.

Let's go over those few parameters we'll be passing to powershell.exe:
```
-ExecutionPolicy Bypass => We are telling powershell to ignore any execution policy and just run the script.
-NonInteractive => Disallow user from typing into terminal
-File "C:\PATH" => We are passing the full path to the powershell script
```

12. Press 'OK'. We can skip 'Contitions' tab and move to 'Settings'.
13. Set following settings to true:
```
Allow task to be run on demand
Run task as soon as possible after a scheduled start is missed
If the running task does not end when requested, force it to stop
```
Put everyhing else off.

14. Press 'OK' to return back to main Task Scheduler window.

Alright, that's now done. We should have a working task, which runs every 1 hour to disable network protection. We can test the task streight away, select the task by clicking it and navigating to the right menu and clicking 'Run'.
Powershell window will pop up and spit some text out after which it'll close by itself. If you didn't see any red text in that flash, then you should be good to go. You can verify if the script succeed by checking those Registery Editor paths I've previously mentioned or by going to Steam website.

There is still some issues with the script and this fix overall, it'll flash the powershell prompt every 1 hour from now on, which might get quite annoying after a while. I will update this guide if I find or somebody can suggest a fix to this :).
