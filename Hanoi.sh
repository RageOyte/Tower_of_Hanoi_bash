#!/bin/bash

# ============================================================
#                VISUAL TOWER OF HANOI (BASH)
# ============================================================
# FEATURES
# Fully animated terminal visualization
# Recursive solution algorithm
# Move logging to external file
#
# AUTHOR NOTES
# This project demonstrates:
#   Recursion in shell scripting
#   Dynamic array manipulation
#   Terminal graphics using printf
#   Algorithm visualization
#
# OUTPUT
# Live terminal animation
# Move history saved in: hanoi_moves.log
# ============================================================

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------
disks=4                     #Number of disks to solve
sleep_delay=0.1             #Sleep delay between iterations for visualisation

# Counter for total moves performed
move_count=0

# ------------------------------------------------------------
# LOG FILE SETUP
# ------------------------------------------------------------
log_file="hanoi_moves.log"  #File where all moves will be stored
> "$log_file"               #Clear previous log content

# Write initial data into the log
echo "Tower Of Hanoi" >> "$log_file"
echo "Disks: $disks" >> "$log_file"
echo "-------------------" >> "$log_file"

# ------------------------------------------------------------
# INITIALIZE TOWERS
# ------------------------------------------------------------
# Towers are represented using Bash arrays:
#   A = Source Tower
#   B = Auxiliary Tower
#   C = Destination Tower
#
# Largest disk is stored first,
# smallest disk becomes the 'top'.
# ------------------------------------------------------------

A=()
B=()
C=()

# Populate tower A      #Eg. disks=4: A=(4 3 2 1)
for ((i=disks; i>=1; i--))
do
    A+=($i)
done

# ============================================================
# FUNCTION: draw_disk
# ============================================================
# Draws a single disk (or empty peg section).
# PARAMETERS
# $1 → Disk size
#
# EXAMPLES
# draw_disk 3
# draw_disk ""
#
# VISUAL
# size=3  => =====
# empty   =>   |
# ============================================================

draw_disk(){
    local size=$1

    # Maximum width of a tower column
    # Example:
    # disks=4 → width=7
    local max_width=$((disks * 2 - 1))

    # --------------------------------------------------------
    # DRAW EMPTY PEG SECTION
    # --------------------------------------------------------
    if [ -z "$size" ]; then 
        local pad=$(((max_width - 1) / 2))      #Padding required for center alignment
        printf "%*s|%*s" "$pad" "" "$pad" ""    #Draw centered vertical peg
        return
    fi

    # --------------------------------------------------------
    # DRAW DISK
    # --------------------------------------------------------
    # Disk width formula:
    # size=1 → 1      =
    # size=2 → 3     ===
    # size=3 → 5    =====
    local width=$((size * 2 - 1))

    local pad=$(((max_width - width) / 2))      #Calculate center padding
    printf "%*s" "$pad" ""                      #Left padding
    printf "%${width}s" "" | tr ' ' '='         #Draw disk using "="
    printf "%*s" "$pad" ""                      #Right padding
}

# ============================================================
# FUNCTION: draw_towers
# ============================================================
# Renders all towers to the terminal
#
# Clear terminal
# Display move count
# Draws each tower level
# Draws base and labels
# ============================================================

draw_towers(){
    # Clear terminal for animation effect
    clear
    echo "Tower Of Hanoi"
    echo "Moves: $move_count"
    echo
    # DRAW ALL LEVELS (TOP TO BOTTOM)
    # We iterate backwards because highest array index = top disk
    for((level=disks-1; level>=0; level--))
    do
        # Draw Tower A
        draw_disk "${A[$level]}"
        echo -n "   "
        # Draw Tower B
        draw_disk "${B[$level]}"
        echo -n "   "
        # Draw Tower C
        draw_disk "${C[$level]}"
        echo
    done
    echo

    # --------------------------------------------------------
    # DRAW BASE PLATFORM
    # --------------------------------------------------------
    local col_width=$((disks * 2 - 1))
    for ((i=0; i<3; i++))
    do
        printf "%${col_width}s" "" | tr ' ' '-'
        echo -n "   "
    done
    echo

    # --------------------------------------------------------
    # DRAW TOWER LABELS
    # --------------------------------------------------------
    printf "%*sA%*s" \
        $((col_width/2)) "" \
        $((col_width - col_width/2)) ""

    echo -n "   "
    printf "%*sB%*s" \
        $((col_width/2)) "" \
        $((col_width - col_width/2)) ""
    echo -n "   "
    printf "%*sC%*s" \
        $((col_width/2)) "" \
        $((col_width - col_width/2)) ""

    echo
    echo
}

# ============================================================
# FUNCTION: move_disk
# ============================================================
# Moves the top disk from one tower to another.
# PARAMETERS
# $1 → Source tower name
# $2 → Destination tower name
# Eg: move_disk A C
#
# INTERNAL PROCESS
# 1. Load source/destination arrays
# 2. Remove top disk from source
# 3. Push disk to destination
# 4. Save arrays back
# 5. Update move counter
# 6. Redraw towers
# ============================================================

move_disk(){
    local from=$1
    local to=$2
    # --------------------------------------------------------
    # LOAD ARRAY CONTENTS DYNAMICALLY
    # --------------------------------------------------------
    # Using eval because tower names are passed as strings.
    # Example:
    # from="A"
    # expands to:
    # from_peg=("${A[@]}")
    # --------------------------------------------------------
    eval "from_peg=(\"\${${from}[@]}\")"
    eval "to_peg=(\"\${${to}[@]}\")"

    disk=${from_peg[-1]}                            #REMOVE TOP DISK
    unset from_peg[-1]

    to_peg+=($disk)                                 #PLACE DISK ON DESTINATION
    eval "$from=(\"\${from_peg[@]}\")"              #SAVE UPDATED ARRAYS
    eval "$to=(\"\${to_peg[@]}\")"

    move_count=$((move_count + 1))                  #UPDATE MOVE COUNT
    echo "$move_count: $from->$to" >> "$log_file"   #LOG MOVE
    draw_towers                                     #REDRAW TERMINAL

    sleep "$sleep_delay"
}

# ============================================================
# FUNCTION: hanoi
# ============================================================
# Recursive Tower of Hanoi solver
# PARAMETERS
# $1 → Number of disks
# $2 → Source tower
# $3 → Destination tower
# $4 → Auxiliary tower
# RECURSIVE STRATEGY for N discs
# 1. Move N-1 disks to auxiliary tower
# 2. Move largest disk to destination
# 3. Move N-1 disks onto largest disk
# TIME COMPLEXITY: O(2^N)
# TOTAL MOVES: (2^N) - 1
# ============================================================
hanoi(){
    local n=$1
    local from=$2
    local to=$3
    local aux=$4

    # BASE CASE: If only one disk remains, move it directly.
    if [ "$n" -eq 1 ]; then
        move_disk "$from" "$to"
        return
    fi

    # STEP 1: Move top N-1 disks to auxiliary tower
    hanoi $((n-1)) "$from" "$aux" "$to"

    # STEP 2: Move largest disk to destination
    move_disk "$from" "$to"

    # STEP 3: Move N-1 disks from auxiliary to destination
    hanoi $((n-1)) "$aux" "$to" "$from"
}

# ============================================================
# PROGRAM START
# ============================================================
draw_towers                             #Initial tower render
hanoi $disks A C B                      #Solve puzzle
echo "Completed in $move_count moves."  #Final completion message
# ============================================================
