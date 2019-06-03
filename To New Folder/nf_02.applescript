on run argv
	--set argv to ""
	set ptm to (((path to me as text) & "::") as alias) as string
	set ptm to POSIX path of ptm
	set wf to load script POSIX file (POSIX path of (POSIX path of (ptm) & "workflow.scpt") as text)
	--set wf to load script POSIX file (POSIX path of ((POSIX file ((POSIX path of (path to me)) & "/..") as text) & "workflow.scpt" as text) as text)
	set wf to wf's new_workflow_with_bundle("com.sztoltz.newfolder")
	
	set sArgv to argv as text
	set someSource to wf's get_value("alf_files", "settings.plist")
	set x to the last item of someSource
	
	tell application "Finder"
		set sFile to POSIX file x as alias
		set sExt to name extension of sFile
		set sName to name of sFile
	end tell
	if sExt = "" then
		set sSub to x
	else
		set sSub to rt(x, "/" & sName, "")
	end if
	if sArgv = "" then
		set sArgv to "New Folder"
		set sInfo to " (Type a folder name)"
	else
		set sInfo to ""
	end if
	
	get_result of wf with isvalid given theUID:"move", theArg:sSub & ".|." & sArgv & ".|.move", theTitle:"Move files to: " & sArgv & sInfo, theAutocomplete:"", theSubtitle:sSub & "/" & sArgv, theIcon:"icon.png", theType:""
	get_result of wf with isvalid given theUID:"copy", theArg:sSub & ".|." & sArgv & ".|.copy", theTitle:"Copy files to: " & sArgv & sInfo, theAutocomplete:"", theSubtitle:sSub & "/" & sArgv, theIcon:"icon.png", theType:""
	get_result of wf with isvalid given theUID:"new", theArg:sSub & ".|." & sArgv & ".|.new", theTitle:"New folder: " & sArgv & sInfo, theAutocomplete:"", theSubtitle:sSub & "/" & sArgv, theIcon:"icon.png", theType:""
	
	return wf's to_xml("")
	
end run

on rt(_txt, _del, _add)
	try
		set d to text item delimiters
		set text item delimiters to _del
		set _txt to _txt's text items
		set text item delimiters to _add
		tell _txt to set _txt to item 1 & ({""} & rest)
		set text item delimiters to d
		return _txt
	on error
		return _txt
	end try
end rt
