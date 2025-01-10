# Runner

## VBA
### Local Process Injection
ProcessWriteMemory invokes AMSI, therefore the shellcode will be scanned

### Remote Process Injetion
32 bit process cannot open 64 bit process handle. 
It is difficult to find a right process when the office is 32 bit. 