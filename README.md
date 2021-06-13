# pcgpolicecode
## Description 
A resource for MTASA that plays the police radio reports for wanted players, made for Prime Freeroam.

The only known missing zones are Jefferson and Creek.

## Exported functions

```lua
playCrimeReport(player, id [, volume = 0.4 ])
```
Plays the initial report that contains a ten-code and the location of the player. Eg. "We got a 10-21 in Los Santos".

#### Arguments
* player = Player element the report is about.
* id = Valid crime ID is 1-8 and 10.
* volume = Optional argument.

Returns the total duration of the audio in milliseconds if successful, false otherwise. 

-----------------------------------------------------------------------------

```lua
playLastSeenDescription(player [, volume = 0.4 ])
```
Plays the description of the player, eg. "Suspect last seen in a white 4-door".

#### Arguments
* player = Player element the description is about.
* volume = Optional argument.

Returns the total duration of the audio in milliseconds if successful, false otherwise. 

-----------------------------------------------------------------------------

```lua
playLastSeenLocation(player [, volume = 0.4 ])
```
Plays the last seen location of the player, eg. "Suspect last seen in Los Santos".

#### Arguments
* player = Player element the location is about.
* volume = Optional argument.

Returns the total duration of the audio in milliseconds if successful, false otherwise. 

## Example usage
This example plays a crime report and suspect description as heard in police vehicles in GTASA.
```lua
local resource = getResourceFromName("pcgpolicecode")
local crimeReportDuration = call(resource, "playCrimeReport", localPlayer, 1)
if crimeReportDuration then
	setTimer(call, crimeReportDuration, 1, resource, "playLastSeenDescription", localPlayer)
end
```
