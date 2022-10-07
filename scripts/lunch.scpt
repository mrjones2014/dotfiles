#!/usr/bin/env osascript

on slashCommand(cmd, msg)
	tell application "Slack"
		activate
		tell application "System Events"
			delay 0.5
			keystroke  "." using command down # close thread if one is open
			delay 0.5
			keystroke "/"
			delay 0.5
			keystroke cmd & " " & msg
		  delay 0.5
		  key code 36
		  delay 0.5
		  key code 36
		end tell
	end tell
end slashCommand

# set slack status to Lunch
slashCommand("status", ":fork_and_knife: Out for food")

# Lock screen
tell application "System Events" to keystroke "q" using {control down, command down}
