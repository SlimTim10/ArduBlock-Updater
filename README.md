# ArduBlock Updater

## Description

A GUI tool for updating to the latest version of Icewire Makerspace's ArduBlock fork.
- [Latest version](http://make.icewire.ca/wp-content/uploads/ardublock/ardublock.zip)
- [Source](https://github.com/Icewire-Makerspace/ardublock)

## Run

```
racket ardublock_updater.rkt
```

## Compile (Windows)

```
raco exe -o ardublock_updtr.exe ardublock_updater.rkt
raco distribute ardublock_updater ardublock_updtr.exe
```

## Compile (Mac OS X)

```
raco exe -o ardublock_updtr ardublock_updater.rkt
raco distribute ardublock_updater ardublock_updtr
```