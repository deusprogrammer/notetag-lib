# RPG Maker NoteTagBlocks and Mods

## Overview

### NoteTagBlock

An RPG Maker NoteTagBlock takes in correctly formatted XML, and produces a document tree based on the data placed into the notes field of an RPGMaker object.

A NoteTagBlock contains NoteTag objects.  Each NoteTag can contain either a String or another NoteTagBlock.  A NoteTag can also be a specialized NoteTag called a Module.

A module (also called a mod) is a container for data for specialized add ons for RPG Maker which will build on these libraries.

### Mod

An RPG Maker Mod is a specialized NoteTag which based on the data contained in its child NoteTagBlock objects, injects itself into a target class and modifies it.

The target class is by default, itself.  The target class can also be other classes (such as a piece of equipment that acts as an MP source for a actor).  The changes the module makes are coded into the module itself, rather than the target class.