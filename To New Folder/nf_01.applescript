on run argv
	set ptm to (((path to me as text) & "::") as alias) as string
	set ptm to POSIX path of ptm
	set wf to load script POSIX file (POSIX path of (POSIX path of (ptm) & "workflow.scpt") as text)
	-- from here - original code
	--set wf to load script POSIX file (POSIX path of ((POSIX file ((POSIX path of (path to me)) & "/..") as text) & "workflow.scpt" as text) as text)
	set wf to wf's new_workflow_with_bundle("com.sztoltz.newfolder")
	
	set sArgv to argv as text
	set someSource to {}
	
	if sArgv contains tab then
		set {TID, text item delimiters} to {text item delimiters, tab}
		repeat with i from 1 to the number of text items of sArgv
			set end of someSource to text item i of sArgv
		end repeat
		set AppleScript's text item delimiters to TID
	else
		set end of someSource to sArgv
	end if
	
	wf's set_value("alf_files", someSource, "settings.plist")
	tell application "Alfred 4" to search "❊ new folder "
	
end run