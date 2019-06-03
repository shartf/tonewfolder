(*
Author:				Ursan Razvan
Original Source: 	https://github.com/jdfwarrior/Workflows (written in PHP by David Ferguson)
Revised: 			18 March 2013
*)
on new_workflow()
	return my new_workflow_with_bundle(missing value)
end new_workflow
on new_workflow_with_bundle(bundleid)
	script Workflow
		property class : "workflow"
		property _cache : missing value
		property _data : missing value
		property _bundle : missing value
		property _path : missing value
		property _home : missing value
		property _results : missing value
		on run {bundleid}
			set my _path to do shell script "pwd"
			if my _path does not end with "/" then set my _path to my _path & "/"
			set my _home to do shell script "printf $HOME"
			set _infoPlist to my q_script_path(":") & "info.plist"
			if my q_file_exists(_infoPlist) then
				tell application "System Events"
					tell property list file _infoPlist
						set my _bundle to value of property list item "bundleid" as text
					end tell
				end tell
			end if
			if not my q_is_empty(bundleid) then
				set my _bundle to bundleid
			end if
			set my _cache to (my _home) & "/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data/" & (my _bundle) & "/"
			set my _data to (my _home) & "/Library/Application Support/Alfred/Workflow Data/" & (my _bundle) & "/"
			if not my q_folder_exists(my _cache) then
				do shell script "mkdir '" & (my _cache) & "'"
			end if
			if not my q_folder_exists(my _data) then
				do shell script "mkdir '" & (my _data) & "'"
			end if
			set my _results to {}
			return me
		end run
		on get_bundle()
			if my q_is_empty(my _bundle) then return missing value
			return my _bundle
		end get_bundle
		on get_cache()
			if my q_is_empty(my _bundle) then return missing value
			if my q_is_empty(my _cache) then return missing value
			return my _cache
		end get_cache
		on get_data()
			if my q_is_empty(my _bundle) then return missing value
			if my q_is_empty(my _data) then return missing value
			return my _data
		end get_data
		on get_path()
			if my q_is_empty(my _path) then return missing value
			return my _path
		end get_path
		on get_home()
			if my q_is_empty(my _home) then return missing value
			return my _home
		end get_home
		on get_results()
			return my _results
		end get_results
		on to_xml(a)
			if (my q_is_empty(a)) and (not my q_is_empty(my _results)) then
				set a to my _results
			else if (my q_is_empty(a)) and (my q_is_empty(my _results)) then
				return missing value
			end if
			set tab2 to tab & tab
			set xml to "<?xml version=\"1.0\"?>" & return & "<items>" & return
			repeat with itemRef in a
				set r to contents of itemRef
				set xml to xml & tab & "<item"
				set xml to xml & " uid=\"" & my q_encode(theUID of r) & "\""
				set xml to xml & " arg=\"" & my q_encode(theArg of r) & "\""
				if isvalid of r is false then
					set xml to xml & " valid=\"no\""
					if not my q_is_empty(theAutocomplete of r) then
						set xml to xml & " autocomplete=\"" & my q_encode(theAutocomplete of r) & "\""
					end if
				end if
				if not my q_is_empty(theType of r) then
					set xml to xml & " type=\"" & (theType of r) & "\""
				end if
				set xml to xml & ">" & return
				set xml to xml & tab2 & "<title>" & my q_encode(theTitle of r) & "</title>" & return
				set xml to xml & tab2 & "<subtitle>" & my q_encode(theSubtitle of r) & "</subtitle>" & return
				set ic to theIcon of r
				if not my q_is_empty(ic) then
					set xml to xml & tab2 & "<icon"
					if ic starts with "fileicon:" then
						set xml to xml & " type=\"fileicon\""
						set ic to (items 10 thru -1 of ic as text)
					else if ic starts with "filetype:" then
						set xml to xml & " type=\"filetype\""
						set ic to (items 10 thru -1 of ic as text)
					end if
					set xml to xml & ">" & my q_encode(ic) & "</icon>" & return
				end if
				set xml to xml & tab & "</item>" & return
			end repeat
			set xml to xml & "</items>"
			return xml
		end to_xml
		on set_value(a, b, c)
			tell application "System Events"
				if class of a is list then
					set lst to my q_clean_list(a)
					set b to property list file (_get_location of me at b with plist)
					repeat with recordRef in lst
						set r to contents of recordRef
						make new property list item at end of property list items of contents of b Â
							with properties {kind:(class of (theValue of r)), name:(theKey of r), value:(theValue of r)}
					end repeat
				else
					set c to property list file (_get_location of me at c with plist)
					if class of b is list then
						set x to my q_clean_list(b)
					else
						set x to b
					end if
					make new property list item at end of property list items of contents of c Â
						with properties {kind:(class of x), name:a, value:x}
				end if
			end tell
		end set_value
		on set_values(a, b)
			return my set_value(a, b, "")
		end set_values
		on get_value(a, b)
			tell application "System Events"
				set b to property list file (_get_location of me at b with plist)
				try
					return value of property list item a of contents of b
				end try
			end tell
			return missing value
		end get_value
		on request(website)
			set agent to "Mozilla/5.0 (compatible; MSIE 7.01; Windows NT 5.0)"
			try
				set theContent to do shell script "curl --silent --show-error --max-redirs 5 --connect-timeout 10 --max-time 10 -L -A '" & agent & "' '" & website & "'"
				return theContent
			end try
			return missing value
		end request
		on mdfind(query)
			set output to do shell script "mdfind \"" & query & "\""
			return my q_split(output, return)
		end mdfind
		on write_file(a, b)
			set b to _get_location of me at b without plist
			if class of a is list then
				try
					set a to my q_join(a, return)
				on error
					return false
				end try
			else
				try
					set a to a as text
				on error
					return false
				end try
			end if
			try
				set f to open for access b with write permission
				set eof f to 0
				write a to f as Çclass utf8È
				close access b
				return true
			on error
				close access b
				return false
			end try
		end write_file
		on read_file(a)
			set a to _get_location of me at a without plist
			try
				set f to open for access a
				set sz to get eof f
				close access a
				if sz = 0 then
					tell application "System Events" to delete file a
					return missing value
				else
					return read a as Çclass utf8È
				end if
			on error
				close access a
				return missing value
			end try
		end read_file
		on get_result given theUID:_uid, theArg:_arg, theTitle:_title, theSubtitle:_sub, theIcon:_icon, theAutocomplete:_auto, theType:_type, isvalid:_valid
			if _uid is missing value then set _uid to ""
			if _arg is missing value then set _arg to ""
			if _title is missing value then set _title to ""
			if _sub is missing value then set _sub to ""
			if _icon is missing value then set _icon to ""
			if _auto is missing value then set _auto to ""
			if _type is missing value then set _type to ""
			if _valid is missing value then set _valid to "yes"
			set temp to {theUID:_uid, theArg:_arg, theTitle:_title, theSubtitle:_sub, theIcon:_icon, isvalid:_valid, theAutocomplete:_auto, theType:_type}
			if my q_is_empty(_type) then
				set temp's theType to missing value
			end if
			set end of (my _results) to temp
			return temp
		end get_result
		on _make_plist(plistPath)
			tell application "System Events"
				set parentElement to make new property list item with properties {kind:record}
				set plistFile to Â
					make new property list file with properties {contents:parentElement, name:plistPath}
			end tell
			return plistFile
		end _make_plist
		on _get_location at pathOrName given plist:isPlist
			if pathOrName is missing value or my q_is_empty(pathOrName) then set pathOrName to "settings.plist"
			if my q_file_exists(pathOrName) then
			else if my q_file_exists(my _path & pathOrName) then
			else if my q_file_exists(my _data & pathOrName) then
				set location to my _data & pathOrName
			else if my q_file_exists(my _cache & pathOrName) then
				set location to my _cache & pathOrName
			else
				set location to my _data & pathOrName
				if isPlist then
					my _make_plist(location)
				else
					try
						set f to open for access location with write permission
						set eof of f to 0
						close access location
					on error
						do shell script "touch " & location
					end try
				end if
			end if
			return location
		end _get_location
	end script
	return run script Workflow with parameters {bundleid}
end new_workflow_with_bundle
on q_join(l, delim)
	if class of l is not list or l is missing value then return ""
	repeat with i from 1 to length of l
		if item i of l is missing value then
			set item i of l to ""
		end if
	end repeat
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set output to l as text
	set AppleScript's text item delimiters to oldDelims
	return output
end q_join
on q_split(s, delim)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set output to text items of s
	set AppleScript's text item delimiters to oldDelims
	return output
end q_split
on q_script_path(theType)
	set p to my q_split(path to me as text, ":")
	set p to my q_join(items 1 thru -2 of p, ":") & ":"
	if theType is "HFS" or theType is ":" then
		if p does not end with ":" then set p to p & ":"
	else
		set p to POSIX path of p
		if p does not end with "/" then set p to p & "/"
	end if
	return p
end q_script_path
on q_file_exists(theFile)
	if my q_path_exists(theFile) then
		tell application "System Events"
			return (class of (disk item theFile) is file)
		end tell
	end if
	return false
end q_file_exists
on q_folder_exists(theFolder)
	if my q_path_exists(theFolder) then
		tell application "System Events"
			return (class of (disk item theFolder) is folder)
		end tell
	end if
	return false
end q_folder_exists
on q_path_exists(thePath)
	if thePath is missing value or my q_is_empty(thePath) then return false
	try
		if class of thePath is alias then return true
		if thePath contains ":" then
			alias thePath
			return true
		else if thePath contains "/" then
			POSIX file thePath as alias
			return true
		else
			return false
		end if
	on error msg
		return false
	end try
end q_path_exists
on q_is_empty(str)
	if str is missing value then return true
	return length of (my q_trim(str)) is 0
end q_is_empty
on q_trim(str)
	if class of str is not text or class of str is not string or str is missing value then return str
	repeat while str begins with " "
		try
			set str to items 2 thru -1 of str as text
		on error msg
			return ""
		end try
	end repeat
	repeat while str ends with " "
		try
			set str to items 1 thru -2 of str as text
		on error
			return ""
		end try
	end repeat
	return str
end q_trim
on q_clean_list(lst)
	if lst is missing value or class of lst is not list then return lst
	set l to {}
	repeat with lRef in lst
		set i to contents of lRef
		if i is not missing value then
			if class of i is not list then
				set end of l to i
			else if class of i is list then
				set end of l to my q_clean_list(i)
			end if
		end if
	end repeat
	return l
end q_clean_list
on q_encode(str)
	if class of str is not text or my q_is_empty(str) then return str
	set s to ""
	repeat with sRef in str
		set c to contents of sRef
		if c is in {"&", "'", "\"", "<", ">"} then
			if c is "&" then
				set s to s & "&amp;"
			else if c is "'" then
				set s to s & "&apos;"
			else if c is "\"" then
				set s to s & "&quot;"
			else if c is "<" then
				set s to s & "&lt;"
			else if c is ">" then
				set s to s & "&gt;"
			end if
		else
			set s to s & c
		end if
	end repeat
	return s
end q_encode
