#!/bin/bash

currentName="$(ls *.gz)"
newName="${currentName/--/-}"
mv "$currentName" "$newName"
