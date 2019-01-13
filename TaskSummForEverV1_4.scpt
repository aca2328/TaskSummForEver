# Applescript
# version 1.4 NOV214 by aca2328
set text item delimiters to "<" # used to match evernote's ENML
tell application id "com.evernote.Evernote"
	#**** preparation
	synchronize # init syn and wait
	repeat until isSynchronizing is false
	end repeat
	if notebook named "TaskSumm" exists then delete notebook "TaskSumm"
	synchronize # init syn and wait
	repeat until isSynchronizing is false
	end repeat
	create notebook "TaskSumm" # for security all notes will be created in this notebook
	#****notebook input
	set nb to name of notebooks
	(choose from list items of nb with title "Notebooks")
	set nbc to result as string
	#**** core extraction
	set note1 to create note title "TaskSumm" with text "Task summary generated " & (current date) notebook "TaskSumm"
	set foundNotes to find notes "todo:false" # select all note with at least one unchecked task
	#****browse notes
	repeat with aNote in foundNotes
		set nbn to name of notebook of aNote
		#****select note from one notebook (bug in find note notebook:[name] )
		if nbc = nbn then
			set atitle to (the title of aNote)
			set noteHTML to HTML content of aNote
			set NoteItems to text items of noteHTML
			set newURL to note link of aNote
			set ilink to "[url=" & newURL & "]" & newURL & "[/url]" as string
			set enTags to (the tags of aNote)
			tell note1 to append html "</div><div><br />"
			#			tell note1 to append html "<div><b>" & "<div>" & nbn & " - " & "</div>" & "<a href=\"" & newURL & "\">" & title of aNote & "</a>" & "</b></div>"
			tell note1 to append html "<div><b>" & nbn & " - " & "<a href=\"" & newURL & "\">" & title of aNote & "</a>" & "</b></div>"
			#****extract task
			repeat with i from 2 to count of NoteItems
				set iplot to item i of NoteItems
				if iplot = ("object class=\"en-todo\">") then # task created after 5.7
					set itxt to item (i + 1) of NoteItems
					tell note1 to append html "<div><" & itxt & "</div>"
				else if iplot contains ("object class=\"en-todo\"/>") then # task created before 5.7
					set itxt to text (offset of ">" in iplot) thru -1 of iplot
					tell note1 to append html "<div>" & itxt & "</div>"
				end if
			end repeat
		end if
	end repeat
end tell
