# Run simulation until completion
run all

# Check if RUN_GUI is set; if not, exit simulation
if { [expr {$::env(RUN_GUI) == 0}] } {
    quit
}