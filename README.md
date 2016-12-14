# HeatingPi
Set of scripts and pages for a Raspberry Pi to allow it to control central heating via relays.

It uses <b>MySQL</b> to manage the timing schedule, pulling the days times and creating jobs in <b>at</b> (https://linux.die.net/man/1/at)
to turn the relays controlling the boiler and/or water heater.
Jobs are created from files in <i>/scripts/</i>, however custom timers can be set from the webUI, that will override the main schedule.
The Central Heating or Hot Water can be set <b>on</b> or <b>off</b> and will stay in that state until a scheduled time to switch to the
opposite setting.
The webUI is written in php and <i>shell_exec</i>'s the scripts to perform the required task. The UI is currently set to asks for 
a password set by the user, it can be set to check whether the connection is local or remote and not ask for the password locally.

The simple is currently very simple, but it works and is very customisable. It is being used and is "<i>upgraded</i>" as and when one of
the two users think of an upgrade to the system.
