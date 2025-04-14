# log_loop.tcl
set i 0
while {1} {
    puts "Tcl loop: $i"
    flush stdout
    incr i
    after 1000
}

