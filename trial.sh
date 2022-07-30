#!/bin/bash

clear 

READ="Read"; THINK="Think"; DISCARD="Discard"
ACTIONS=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓] " --no-limit "$READ" "$THINK" "$DISCARD")

clear; echo "One moment, please."

grep -q "$FISH" <<< "$ACTIONS" && gum spin -s line --title "Reading the secret..." -- sleep 1
grep -q "$GH" <<< "$ACTIONS" && gum spin -s pulse --title "Thinking about your secret..." -- sleep 1
grep -q "$EXA" <<< "$ACTIONS" && gum spin -s monkey --title " Discarding your secret..." -- sleep 1



fish

sleep 1; clear

echo "And now we are in fish."