
How to use the lib:

- GCCAsyncSocket uses ARC so the -fobjc-arc is needed in the "Other linker flags"
- Becauses an Objective-C categorie is used, the -all_load flag is needed (also in the "Other linker flags")
- add Security and CFNetwork framework

TODO (developper)
- manage errors (with NSError, error domain name ...)
- advertise client when the set map change (new device, device disappear ...)
- allow client to decide on which criteria the election is based (maybe use blocks or stuff, need more thought)

- add state replica connected / non connected
- disable push data and stuff while arbiter or elector

- crash of the wining elector before it becomes master !!