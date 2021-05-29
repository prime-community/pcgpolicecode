# pcgpolicecode
## Description 
A resource that plays the police radio reports for wanted players, made for Prime Freeroam.

There are three main functions that are used:

playLocationCode(player, id) - The initial report that contains a ten-code and the location of the player. The id is an int between 0 - 10 and the associated crimes can be seen here https://sampwiki.blast.hk/wiki/Crime_List

playLastSeenLocationCode(player) - Plays "Suspect last in [location]" where [location] is the current zone of the player.
    
playLastSeenVehicleCode(player) - Plays "Suspect last in a [vehicle color] [vehicle type]" or "Suspect last seen on foot" where [vehicle color] and [vehicle type] is the color and vehicle type of the player

## Exported functions:

exports.pcgpolicecode:playLocationCode(player, id)

exports.pcgpolicecode:playLastSeenLocationCode(player)

exports.pcgpolicecode:playLastSeenVehicleCode(player)
