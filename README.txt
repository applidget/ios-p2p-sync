
How to use the lib:

- GCCAsyncSocket uses ARC so the -fobjc-arc is needed in the "Other linker flags"
- Becauses an Objective-C categorie is used, the -all_load flag is needed (also in the "Other linker flags")
- add Security and CFNetwork framework

#warning: sessionId can't be longer than 15 char sor for client must be 12 + _ maximum (otherwise crash !!) => check it with an assertion

TODO (developper)
- manage errors (with NSError, error domain name ...)
- advertise client when the set map change (new device, device disappear ...)
- allow client to decide on which criteria the election is based (maybe use blocks or stuff, need more thought)


- crash of the wining elector before it becomes master !!