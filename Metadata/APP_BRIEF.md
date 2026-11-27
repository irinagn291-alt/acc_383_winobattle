<!-- gf-brief source=7aa9b7caf015b57ddc4062db2596a77a262a56ac6989f75ed62849bfea9926a1 written=2026-11-27T14:55:36+03:00 -->
# Winobattle

## What it is

Winobattle helps organizers of neighborhood football tournaments schedule matches, record scores and goalscorers, and keep standings and player rosters. Organizers and participants can also exchange tournament copies, submit match reports for review, and vote for a player of the round.

## Launch and onboarding

1. A first launch opens the “Winobattle” welcome screen. The hero reads “Your pitch.” and “Your championship.” on separate lines, followed by “Bring the neighborhood together, one round at a time.”
2. Below “A whole league in your pocket” are three feature labels, “Smart brackets”, “Live tables”, and “Match reports”. The footer reads “Free, offline, made for your community”.
3. “Create tournament” opens “New tournament”. “Explore a sample tournament” adds and opens “Sample neighborhood cup” on “Overview”, with the banner “Sample data · not a real tournament”.
4. The icon labeled “Settings” opens settings. The icon labeled “Tournaments” opens a menu with “New tournament” and the names of any saved tournaments. There is no separate onboarding sequence or required profile setup. On a later launch with saved data, the app opens the selected tournament on “Overview”.

## Screens

The quoted app text below is from the English interface. In an open tournament, the navigation bar shows its name above the tabs “Overview”, “Fixtures”, “Standings”, and “Community”. The “Settings” and “Tournaments” icons stay available across those tabs. Selecting a different tournament returns to “Overview”.

### “New tournament”

- “Tournament details” contains “Tournament name” and the optional “Pitch or neighborhood” field. The “Format” control offers “Round robin” and “Knockout”. The default, “Round robin”, shows “Each team meets every other team once. A win earns 3 points; a draw earns 1.” “Knockout” shows “Single elimination. Byes advance automatically; tied matches require penalties.”
- “Teams, one per line” is a multiline editor with a live count such as “0 teams”. Its instructions read “2–32 unique teams, one per line. First-listed teams receive any byes. Team order fixes the draw.”
- “Schedule” contains the “First kickoff” date and time picker, initially set one day ahead, and a stepper initially labeled “7 days between rounds”, adjustable from 1 to 30 days. The screen says “Matches in the same round start 90 minutes apart. Kickoff times can be edited in each report.”
- “Cancel” closes the form and discards the draft. “Create” generates and saves the schedule and opens the new tournament on “Overview”.

### “Overview”

- The header shows “NEIGHBORHOOD LEAGUE” or “KNOCKOUT”, the tournament name, the pitch or neighborhood if entered, and counts labeled “Teams”, “Played”, and “Rounds”.
- “NEXT KICKOFF” shows the earliest scheduled match still awaiting a result with two known teams, including the date, time, and matchup separated by “×”. Once a champion is decided, “CHAMPIONS” shows the winner or joint winners. “Share winner certificate” opens the iOS share sheet for a PDF for that team. The certificate says “Champions of the neighborhood” and “Winobattle · Community football, together”, and includes the winner, tournament, venue if entered, and date.
- The “ROUND BY ROUND” card reads “Every result counts.” and “Record a match, update the table, celebrate your players.”
- “Teams and player rosters” opens “Player rosters”. “Share a copy” opens the iOS share sheet for a tournament copy or a participant’s return file. The sharing caption reads “Invitation-only. Shared edits are checked when the app opens or you sync. Offline changes are kept on this device.” In this build, exchanging changes requires manually sharing and opening files.
- “Delete tournament” appears on an organizer’s copy and “Leave shared tournament” appears on a participant’s copy. Both open “Remove this tournament?” with the message “Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again. This cannot be undone.” “Remove” removes the local copy, then shows another saved tournament if available or returns to “Winobattle”.
- If creating a certificate fails, “Please check” shows “The certificate could be created. Try again.” with “OK”.

### “Fixtures”

- A league shows “THE MATCH CALENDAR” and “Round fixtures”. A knockout tournament shows “THE ROAD TO THE CUP” and “Tournament bracket”, with the instructions “Swipe across the bracket. Results advance winners automatically. Changing an earlier winner clears dependent results.”
- The screen shows a completed-match count and groups matches under labels such as “Round 1”. League rounds get a checkmark when complete. Knockout rounds scroll horizontally.
- Each match card shows the kickoff, the two team names, and either their scores or “–” for each unrecorded score. A pencil marks an unrecorded match and a checkmark marks a completed one. Tied knockout results show penalties in a line such as “Penalties 4 : 3”. Missing teams appear as “To be decided”, and first-round knockout byes say “Bye · advances automatically”.
- Tapping a match with two known teams opens “Match report”. Cards with a missing team are disabled.

### “Match report”

- The round section, such as “Round 1”, has a score stepper for each team, labeled with its name and score, such as “Vila Verde: 0”. An unplayed match opens with both scores at zero. Scores range from 0 to 99. “Kickoff” edits the date and time.
- When a knockout score is tied, “Home penalties” and “Away penalties” steppers appear with their current values and the message “A tied knockout match needs a penalty winner.” Each penalty tally ranges from 0 to 99.
- “Goalscorers” shows optional goal steppers for rostered players on the two teams, labeled with player and count, such as “Alex · 1”. With no rostered players on either team it says “Add players in Teams and player rosters to record goalscorers.” The screen also says “Scorers are optional. Recorded goals cannot exceed the team score.”
- “Match notes” is a free-text editor with a live character count such as “0/500”. “Report author”, when present, shows a shortened author identifier.
- Participants see “Your report will wait for the tournament owner’s approval.” Knockout reports also say “Changing a winner clears results in later dependent matches.”
- “Close” dismisses the report without saving. “Save” applies an organizer’s result or queues a participant’s report for the next file exchange. Editing a completed knockout result first opens “Update this result?” with “Dependent results may be cleared if the winner changes.” “Save result” confirms. Saving closes the report and returns to “Fixtures”.

### “Standings”

- “THE NEIGHBORHOOD TABLE” and “Every team. Every goal.” appear above a horizontally scrollable table with “Team”, “P”, “W”, “D”, “L”, “GF”, “GA”, “GD”, and “PTS”. It shows rank, played, wins, draws, losses, goals for, goals against, goal difference, and points.
- The rules read “3 points for a win, 1 for a draw. Ties: goal difference, then goals scored. Exact ties share the championship. Penalties do not count as goals in the table. Knockout tables are statistical summaries; the final decides the champion.”
- “Goalscorers” ranks players with recorded goals and shows their team and total. Before any goals are attributed to players, it says “Record player goals in match reports to see the scoring chart.” The table and chart have no row actions.

### “Player rosters”

- Each team has a section named for the team, an existing player list, a “Player name” field, and “Add player”. A successful addition saves immediately and clears that team’s field. There are no player rename or removal controls.
- The footer reads “Up to 30 players per team. The owner maintains rosters; names already used in reports stay in the record.” On an imported copy, “Add player” is disabled. “Done” returns to “Overview”.

### “Community”

- “PEOPLE MAKE THE LEAGUE” and “Player of the round” head the voting card. “Round” selects a round from options such as “Round 1”. Once the round is complete and has eligible players, “Choose a player” lists names and teams, such as “Alex · Vila Verde”. “Save my vote” records or replaces the device’s vote for that round. The card says “One vote per device per round.” After saving it says “Your vote is saved. You may change it.” The tally shows player names and counts such as “1 votes”.
- “Reports awaiting review” can appear when there is report history. Pending reports show the matchup, proposed score, notes, and “Author” followed by a shortened identifier. For organizers, “Approve” applies a valid report to the tournament and “Reject” removes it from the pending list without applying it. “Flag author” opens “Flag participant”.
- “Fair play and access” shows “Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again.” It lists other participants by shortened identifiers when they appear in reports, results, or votes. “Flag” opens “Flag participant”. Organizers can tap “Block”, which becomes a disabled “Blocked”. Blocking suppresses that participant’s pending reports and votes from the relevant lists and prevents their return file from being accepted. Organizers can also see submitted reasons under “Flagged participant”.
- “Share a copy” opens the same iOS share sheet as on “Overview”.

### “Flag participant”

- “Reason for review” accepts a written reason. The form says “The tournament owner can review this flag. To remove access, the owner must also remove the person in Manage invitations.” There is no “Manage invitations” screen or control in this build.
- “Submit” saves the flag and closes the form. “Cancel” closes without submitting. A participant can send saved flags back to the organizer using “Share a copy”.

### “Settings”

- “Organizer profile” contains “Display name”. Edits save as they are typed.
- “Round reminders” contains the “Upcoming rounds and missing reports” switch, initially off. The explanation reads “A reminder one day before each round and a report reminder two hours after kickoff. Changes are checked when the app opens.” “Open notification settings” opens the app’s notification settings in iOS.
- The sharing section repeats “Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again.” “Open a shared file” opens the iOS file picker for a tournament copy or a participant’s return file previously exported by Winobattle.
- “Privacy and help” says “The owner of a shared tournament keeps its results when you leave. Ask the owner to remove personal information from their copy.” “Delete profile and all tournaments” opens “Delete profile and all tournaments?” with “Delete everything”. Confirming clears the local profile, tournaments, and reminders. “Done” returns to the prior screen.
- Errors appear under “Please check” with “OK”. App-written messages include “Saved data could not be opened. A recovery copy is kept on this device.”, “The device could not save changes. Free some storage and try again.”, “This report no longer matches the bracket.”, “Your invitation no longer allows changes. Ask the organizer to check access.”, “Check the score, penalties and scorers.”, “Reminders are off in Settings. The calendar still works in the app.”, and “Reminders are unavailable. Your schedule is saved locally.” File import and sharing errors can show iOS error text, which varies with the failure and device language.

### “Neighborhood rounds” widgets

The Home Screen and Lock Screen widgets open Winobattle when tapped. Their gallery description is “Fixtures, local standings and the next round, available offline.” Depending on size, they show the next kickoff or “Round complete”, up to six standings rows, and sections labeled “Bracket” or “Round fixtures”, “Round calendar”, and “Updated”. The kickoff can be labeled “Next round” or “Weekend round”. Without an active non-sample tournament, the widgets use prompts such as “Your neighborhood cup”, “Create a tournament in the app.”, or “Create tournament”, depending on size.

## Features

- “Round robin” schedules and single-elimination “Knockout” brackets for 2–32 teams, with automatic byes and winner advancement.
- “Round fixtures” and “Tournament bracket” with scheduled kickoffs, match scores, and round progress.
- “Match report” with scores, penalties, kickoff edits, optional “Goalscorers”, and “Match notes”.
- “Standings” with automatic points, tiebreaks, and a goalscorer chart.
- “Player rosters” with up to 30 players per team.
- “Player of the round” voting with one changeable vote per device per round and a running tally.
- “Share a copy” and “Open a shared file” for exchanging tournament copies and returning reports, votes, and flags.
- “Reports awaiting review” with “Approve” and “Reject”, plus “Flag” and “Block” under “Fair play and access”.
- “Share winner certificate” for each champion, including joint round-robin winners.
- “Round reminders” and the “Neighborhood rounds” widgets.
- “Display name”, a saved tournament switcher, and local tournament and profile deletion.

## Behaviours that can look like bugs

- “Create” stays disabled until “Tournament name” has non-whitespace text and is at most 80 characters, “Pitch or neighborhood” is at most 100 characters, and “Teams, one per line” contains 2–32 nonblank names of at most 50 characters each. Team names must be unique regardless of case.
- “To be decided” cards cannot open until both teams are known. “Bye · advances automatically” needs no score entry. Play or enter the earlier knockout results to fill later slots.
- “Save” stays disabled if a tied knockout match has equal penalty totals, either team’s credited player goals exceed its score, or “Match notes” exceeds 500 characters. Set unequal penalties, correct the goal totals or score, or shorten the notes. Changing a completed knockout winner can clear later dependent reports, which must then be entered again.
- “Add player” can appear tappable yet do nothing for a blank name, a name over 60 characters, a case-insensitive duplicate on that team, or a roster already at 30 players. Enter a valid new name on a team with room. On a shared copy, ask the organizer to add the player and send an updated copy.
- “Voting opens after every match in this round is complete.” Save all playable results for that round. If it then says “Add player rosters before opening the vote.”, roster players on the teams that played. Select an eligible player to enable “Save my vote”. Changing “Round” clears the current selection. Saving again for the same round replaces the vote. “Blocked” is disabled and there is no unblock control.
- “Reports awaiting review” can remain visible after all eligible pending cards disappear. “Approve” and “Reject” appear only for the organizer. A participant must send a return file, and the organizer must open it before there is a report to review. An outdated report can show “This report no longer matches the bracket.” Use the latest tournament copy to prepare a report for the current matchup.
- “Submit” in “Flag participant” requires a nonblank “Reason for review” and permission to edit the tournament. The saved reason is limited to 500 characters.
- “Share a copy” is disabled for “Sample neighborhood cup”. Create a tournament to try file exchange. Opening an already imported or older copy can do nothing. Ask the sender for a newly shared copy, then use “Open a shared file”.
- “Create tournament” from the empty screen and “New tournament” from the menu lead to the same form. Finishing or switching tournaments opens “Overview”. Removing the last tournament brings back the welcome screen. Selecting a sample also leaves widgets in their empty state until a non-sample tournament is active.
- If notification permission is declined, “Upcoming rounds and missing reports” returns to off. Use “Open notification settings” to allow notifications, then enable the switch. Sample tournaments never schedule reminders.

## Starter content and resume

“Explore a sample tournament” adds a saved, editable round robin named “Sample neighborhood cup” at “Community pitch”. It includes “Vila Verde” with “Alex”, “Estrela do Sul” with “Sam”, “União da Praça” with “Dani”, and “Jardim FC” with “Luca”. The schedule starts at the next Saturday at 10:00 local time with seven days between rounds. Two of its six matches already have results. “Vila Verde” beat “Jardim FC” 1–0 with a goal by “Alex”, and “Estrela do Sul” beat “União da Praça” 2–0 with both goals by “Sam”. The first round is ready for voting.

Saved tournaments, results, rosters, votes, pending reports, flags, and profile settings persist across launches. The app resumes the selected tournament on “Overview”. Unsubmitted tournament and match-report drafts are discarded when their forms are closed.

## Permissions

Notifications are the only permission requested. The standard iOS prompt appears when the user first enables “Upcoming rounds and missing reports”, with authorization requested for alerts, sounds, and badges. There is no app-supplied usage-description string. Notification titles use the tournament name. The bodies are “Your neighborhood round is coming up. Check the fixtures.” and “A match report is waiting. Open the round to record the result.” Reminders use the earliest still-unreported playable kickoff in a round and are scheduled only for times still in the future.

## Absent

Login or accounts, in-app purchases, ads, analytics, an account deletion flow, and an App Tracking Transparency prompt are absent. The app has a local organizer profile and a local data deletion flow under “Delete profile and all tournaments”. User-generated content exists as tournament and team names, player names, scores, match notes, votes, and flag reasons. There is no public feed or chat.

## Data and support

Tournament and profile data are kept on the device by default. “Share a copy” lets users send data through the iOS share sheet. The organizer sends a tournament copy, participants can send back pending reports, their votes, and flags, and the organizer imports those contributions using “Open a shared file”. Recipients can retain independent copies after the sender deletes theirs. The app has no automatic sync. The destination selected in the share sheet or file picker may use an external service.

“Privacy and help” gives guidance about contacting the tournament owner to remove personal information from their copy. There is no on-screen “Contact” or “Support” control.

## Scanning and health

None.

## Platform

iPhone and iPad, with a minimum of iOS or iPadOS 17.4. iPhone supports upright portrait and both landscape orientations. iPad also supports upside-down portrait. The app name is “Winobattle” across all six native interface languages: English, Brazilian Portuguese, Spanish, German, French, and Italian. Dates and times follow device settings. Tournament creation, scoring, and file exchange have no region-specific gate.

## Category

Sports
