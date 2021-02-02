# Indulgence Guild Helper

## Version History

#### v1.0.9
##### Added check mod - /ind check - queries all online players for addon version.

#### v1.0.8
##### Added several time records to try and find out a reliable timestamp.
##### Added logs to materials tabs. As usual, wipe all data after install - There will be a warning message after update

#### v1.0.6
##### Changed log display - texture and fonts - /ind logs.
##### Reversed display order on money logs - from newer to older
##### Added variable to saved variables to warn users when addon is updated

### This addon was created to help Officers of the Indulgence guild, on Aggra/Grim-Batol(EU), to keep track of guild contributions to guild bank, either materials/consumables or gold.

A log of transactions is stored in a couple auxiliary tables, stored in Saved Variables. This operation is required since Blizzard's API has a log size limit - only last 25 actions are stored.

Each time a player opens the guild bank, this addon will scan transactions in all tabs, and also money log transaction logs.
It will then perform data sync between live guild transation log and values stored in saved variables.
In case a continuous log is not possible (none of the guild bank transactions is present in saved variables), a sync request is sent to all online guild members, with the addon installed. Each players saved variables tables are sent to the requester, and data consolidation will occur. If a viable match exists (last five log entries on requester tables match 5 continous entries on other guild member saved variables table), remaining entries are added to requesters saved variables table. This process is repeated for every online guild member.
If no viable match exists, all current guild bank transactions are added to the saved variables table of the player who opened the guild bank.
This data is then sent to all online guild members.

Every time a player deposits gold and deposits or withdraws materials from the guild bank an addon broadcast message is sent, to all online guild members, to keep everyone's saved variables tables up to date.

### This addon is still a work in progress, in it's early stages.

## Done:
- Money transaction logs collected and stored, when opening guild bank
- Materials transaction logs collected and stored, when opening guild bank

## Todo:
- Sync between guild members

## Commands
- /ind logs -> Opens up a panel withh gold and materials logs
- /ind wipe -> Wipes all data in saved variables
- /ind check -> Checks addon version in all online Guild members
