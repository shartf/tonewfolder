on run argv
	set ptm to (((path to me as text) & "::") as alias) as string
	set ptm to POSIX path of ptm
	set wf to load script POSIX file (POSIX path of (POSIX path of (ptm) & "workflow.scpt") as text)
	--set wf to load script POSIX file (POSIX path of ((POSIX file ((POSIX path of (path to me)) & "/..") as text) & "workflow.scpt" as text) as text)
	set wf to wf's new_workflow_with_bundle("com.sztoltz.newfolder")
	
	set sArgv to argv as text
	
	set {TID, text item delimiters} to {text item delimiters, ".|."}
	set sDest to text item 1 of sArgv & "/" & text item 2 of sArgv
	set sLoc to POSIX file (text item 1 of sArgv)
	set sNew to text item 2 of sArgv as text
	set sParam to text item 3 of sArgv as text
	set AppleScript's text item delimiters to TID
	set someSource to wf's get_value("alf_files", "settings.plist")
	
	if wf's q_path_exists(sDest) then
		set isNew to false
	else
		tell application "Finder" to make new folder at sLoc with properties {name:sNew}
		set isNew to true
	end if
	
	set sDest to POSIX file (sDest)
	
	if sParam = "new" then
		if isNew then
			return sNew & " folder created"
		else
			return "Folder " & sNew & " already exists"
		end if
	else if sParam = "copy" then
		repeat with sCur in someSource
			set sCur to POSIX file (sCur)
			tell application "Finder" to duplicate sCur to sDest with replacing
		end repeat
		return "Copied " & (count someSource) & " item(s) to " & sNew
	else if sParam = "move" then
		repeat with sCur in someSource
			set sCur to POSIX file (sCur)
			tell application "Finder" to move sCur to sDest with replacing
		end repeat
		return "Moved " & (count someSource) & " item(s) to " & sNew
	end if
	
end run