#########################################################################
##          BlackTools - The Ultimate Channel Control Script           ##
##                    One TCL. One smart Eggdrop                       ##
#########################################################################
#############################   QUOTE TCL   #############################
#########################################################################
##						                       ##
##     BlackTools  : http://blacktools.tclscripts.net	               ##
##     Bugs report : http://www.tclscripts.net/	                       ##
##     Online Help : irc://irc.undernet.org/tcl-help 	               ##
##                   #TCL-HELP / UnderNet                              ##
##                   You can ask in english or romanian                ##
##					                               ##
#########################################################################

proc quote:announce {} {
	global black
	set return_time [time_return_minute $black(quote:msgtime)]
	set channels ""
foreach chan [channels] {
if {[validchan $chan]} {
if {[setting:get $chan quoteofday]} {
	lappend channels $chan
		}
	}
}
if {$channels != ""} {
		quote:time $channels 0
		timer $return_time quote:announce
	}	 
}

proc quote:time {channels counter} {
	global black
	set chan [lindex $channels $counter]
	set cc [expr $counter + 1]
if {$chan != ""} {
	quoteofday:show $chan
} 
if {[lindex $channels $cc] == ""} {
	return
} else {
	quote:time $channels $cc
	}
}

proc quoteofday:show {chan} {
	global black  botnick
	set getlang [string tolower [setting:get $chan lang]]
if {$getlang == ""} { set getlang "[string tolower $black(default_lang)]" }
	set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
	set temp_dir "$black(tempdir)/quote_temp.$timestamp"
	set day [clock format [clock seconds] -format {%d}]
	set file [open $black(quote_file) "r"]
	set temp [open $temp_dir "a"]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
if {[string match -nocase $enc_chan $chan]} {
	set quote [join [lrange [split $line] 6 end]]
	set gettime [lindex [split $line] 4]
	set getday [clock format $gettime -format %d]
if {$getday == $day} {
	puts $temp $quote
		}
	}
}
	close $temp
	close $file
	set file [open $temp_dir "r"]
	set data [read -nonewline $file]
	close $file
if {$data != ""} {
if {![info exists black(quoteshow:$chan)]} {
	set black(quoteshow:$chan) 0
}
	set lines [split $data "\n"]
	set line [lindex $lines $black(quoteshow:$chan)]
	
if {$line == ""} {
	set black(quoteshow:$chan) 0
	set line [lindex $lines $black(quoteshow:$chan)]
}
	set black(quoteshow:$chan) [expr $black(quoteshow:$chan) + 1]
	set encoded [encoding convertfrom utf-8 $line]
	set replace(%msg%) $encoded
	set message [join [string map [array get replace] $black(say.$getlang.quote.16)]]
	set split_message [split $message "~"]
if {[onchan $botnick $chan]} {
if {$black(quote:outtype) == "1"} {
	putserv "PRIVMSG $chan :\001ACTION $black(say.$getlang.quote.12)\001"
} else {
	putserv "PRIVMSG $chan :$black(say.$getlang.quote.12)"
}
foreach mes $split_message {
if {$black(quote:outtype) == "1"} {
	putserv "PRIVMSG $chan :\001ACTION \"$mes\"\001"
} else { 
	putserv "PRIVMSG $chan :\"$mes\""
			}
		}
	}
}
	file delete $temp_dir
}

proc quotepublic {nick host hand chan arg} {
	global black lastbind
	set otherchan 0
	set return [blacktools:mychar $lastbind $hand]
if {$return == "0"} {
		return
}
	set who [lindex [split $arg] 0]
	set next [lindex [split $arg] 1]
	set quote [join [lrange [split $arg] 0 end]]
if {$who == "*"} {
	set who [lindex [split $arg] 1]
	set quote [join [lrange [split $arg] 0 end]]
}
if {[regexp {^[\[]} $who]} {
	set who [lindex [split $arg] 1]
	set quote [join [lrange [split $arg] 0 end]]
if {$who == "*"} {
	set who [lindex [split $arg] 2]
	set quote [join [lrange [split $arg] 0 end]]
	}
}
	set type 0
	set chan1 $chan
if {[regexp {^[&#]} $who] && [matchattr $hand nmo|AOMV $who]} {
	set otherchan 1
	set chan "$who"
	set who [lindex [split $arg] 1]
	set next [lindex [split $arg] 2]
	set quote [join [lrange [split $arg] 1 end]]
if {$who == "*"} {
	set who [lindex [split $arg] 2]
	set quote [join [lrange [split $arg] 1 end]]
}
if {[regexp {^[\[]} $who]} {
	set who [lindex [split $arg] 2]
	set quote [join [lrange [split $arg] 1 end]]
if {$who == "*"} {
	set who [lindex [split $arg] 3]
	set quote [join [lrange [split $arg] 1 end]]
		}
	}
}
if {$otherchan == "1"} {
	quote:process $nick $host $hand $chan $chan1 $type $who $quote [lrange [split $arg] 1 end] $next
	} else {
	quote:process $nick $host $hand $chan $chan1 $type $who $quote [lrange [split $arg] 0 end] $next
	}
}

proc quote:process {nick host hand chan chan1 type who quote arg next} {
	global black
	set cmd_status [btcmd:status $chan $hand "q" 0]
if {$cmd_status == "1"} { 
	return 
}
if {[setting:get $chan quote]} {
	set show_who $who
if {[matchattr $hand q]} { blacktools:tell $nick $host $hand $chan $chan1 gl.glsuspend none
	return
}
if {[matchattr $hand -|q $chan]} { blacktools:tell $nick $host $hand $chan $chan1 gl.suspend none
	return
}
switch $who {
	list {
if {[matchattr $hand nmo|M $chan]} {
	array set nicklist [list]
	set getlang [string tolower [getuser $hand XTRA OUTPUT_LANG]]
if {$getlang == ""} { set getlang "[string tolower $black(default_lang)]" }
	set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
	set temp "$black(tempdir)/quote_temp.$timestamp"
	set file [open $black(quote_file) "r"]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
	set read_type [lindex [split $line] 1]
if {[string match -nocase $enc_chan $chan]} {
	set msg_num [lindex [split $line] 2]
	set by_who [lindex [split $line] 3]
	set quote [join [lrange [split $line] 6 end]]
lappend nicklist($msg_num) "$quote :: $black(say.$getlang.quote.15) $by_who"
		}
	}
	close $file
	set tempwrite [open $temp w]
foreach msg [lsort -integer -increasing [array names nicklist]] {
	puts $tempwrite "$msg [join $nicklist($msg)]"
}
	close $tempwrite
	set file [open $temp "r"]
	set w [read -nonewline $file]
	close $file
	set data [split $w "\n"]
	file delete $temp
	module:getinfo $nick $host $hand $chan $chan1 $type $data "quote" "0" $next
	}
}

del {
if {[matchattr $hand nmo|M $chan]} {
if {![regexp {^[0-9]} $next]} {
switch $type {
	0 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr "quote"
	}
	1 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr_nick "quote"
	}
	2 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr_priv "quote"
		}
	}
	return
}
	set ret [find:q:num $next $chan]
if {$ret == 0} { 
	blacktools:tell $nick $host $hand $chan $chan1 quote.13 $next
	return
}
	set file [open $black(quote_file) "r"]
	set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
	set temp "$black(tempdir)/quote_temp.$timestamp"
	set tempwrite [open $temp w]
while {[gets $file line] != -1} {
	set read_num [lindex [split $line] 2]
	set read_chan [lindex [split $line] 0]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
if {[string equal $next $read_num] && [string equal -nocase $enc_chan $chan]} { 
	continue
} else {
	puts $tempwrite $line
		}	 
    }
	close $tempwrite
	close $file
    file rename -force $temp $black(quote_file)
	blacktools:tell $nick $host $hand $chan $chan1 quote.10 $next
	}
}
	default {
	if {[llength [split $arg]] > 1} {
	set ret_num [quote:add $nick $host $chan $who $quote]
	blacktools:tell $nick $host $hand $chan $chan1 quote.1 $ret_num
}
if {[llength [split $arg]] == 1} {
	quote:show $nick $host $hand $chan $chan1 $type $show_who
}
if {[llength [split $arg]] == 0} {
	quote:rand $nick $host $hand $chan $chan1 $type $show_who 
				}
			}
		}
	}
}

proc quote:rand {nick host hand chan chan1 type who} {
	global black
	set total [quote:total $chan]
	set length [llength $total]
if {$length > 0} {
	set random [expr int(rand()*$length)] 
    set quote [lindex $total $random]
	set file [open $black(quote_file) "r"]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set num [lindex [split $line] 2]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
if {[string equal -nocase $chan $enc_chan] && [string equal -nocase $quote $num]} {
	set time [lindex [split $line] 4]
	set time [clock format $time -format %D]
	set readquote [join [lrange [split $line] 6 end]]
	set encoded [encoding convertfrom utf-8 $readquote]
	continue
			}			
		}
	}
	close $file
	blacktools:tell $nick $host $hand $chan $chan1 quote.3 "$quote $time"
	set split_encoded [split $encoded "~"]
	foreach enc $split_encoded {
	blacktools:tell $nick $host $hand $chan $chan1 quote.19 $enc
	}
}

proc quote:show {nick host hand chan chan1 type who} {
	global black
	set quote_numbers ""
	set find_num 0
	set found_quote 0
	set show_who $who
if {[regexp {^[0-9]} $who]} {
	set quote_num $who
	set find_num 1
} else {
	set quote_list [quote:count $who $chan]
	set length [llength $quote_list]
if {$length > 0} {
	set found_quote 1
}
	set random [expr int(rand()*$length)] 
    set quote [lindex $quote_list $random]
	set split_quote [split $quote ":"]
	set quote_num [lindex $split_quote 0]
	set quote_show [lindex $split_quote 1]
foreach q $quote_list {
	set q_split [split $q ":"]
	set q_num [lindex $q_split 0]
if {$quote_num != $q_num} {
	lappend quote_numbers \#$q_num
			}
		}
if {$found_quote == "0"} {
	blacktools:tell $nick $host $hand $chan $chan1 quote.11 none
	return
	}
}
	set file [open $black(quote_file) "r"]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set num [lindex [split $line] 2]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
if {[string equal -nocase $chan $enc_chan] && [string equal -nocase $quote_num $num]} {
	set found_quote 1
	set time [lindex [split $line] 4]
	set time [clock format $time -format %D]
	set readquote [join [lrange [split $line] 6 end]]
	set encoded [encoding convertfrom utf-8 $readquote]
	continue
			}			
		}
	close $file
if {$found_quote == "0"} {
	blacktools:tell $nick $host $hand $chan $chan1 quote.11 none
	return
}
if {$find_num == "0"} {
	blacktools:tell:h $nick $host $hand $chan $chan1 quote.4 "$quote_show/$length $show_who $time"
}
	set split_encoded [split $encoded "~"]
foreach enc $split_encoded {
	blacktools:tell $nick $host $hand $chan $chan1 quote.17 "$quote_num $enc"
	}
if {$quote_numbers != ""} {
	blacktools:tell $nick $host $hand $chan $chan1 quote.18 $quote_numbers
	}
}

proc quote:total {chan} {
	global black
	set nums ""
	set file [open $black(quote_file) "r"]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
if {[string equal -nocase $chan $enc_chan]} {
	set read_num [lindex [split $line] 2]
	lappend nums $read_num
		}	
	}
	close $file
	return $nums
}

proc quote:count {who chan} {
	global black
	set q_count 0
	set return ""
	set found_nick 0
	set found_quote 0
	set file [open $black(quote_file) "r"]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set read_who [lindex [split $line] 5]
	set read_who [string map { "<" ""
								">" ""
								"@" ""
								"+" ""
										} $read_who]
										
	set enc_chan [encoding convertfrom utf-8 $read_chan]
	set read_who [string map [list \[ {\[} \] {\]} \? {\?} \\ {\\}] $read_who]
if {[string equal -nocase $chan $enc_chan] && [string match -nocase $read_who $who]} { 
	set found_nick 1
	set q_count [expr $q_count + 1]
	set num [lindex [split $line] 2]
	set return "$return $num:$q_count"
		}
	}
	close $file
if {$found_nick == "0"} {
	set file [open $black(quote_file) "r"]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set readquote [lrange [split $line] 6 end]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
if {[string equal -nocase $chan $enc_chan] && ([lsearch -exact $readquote $who] > -1)} { 
	set found_quote 1
	set q_count [expr $q_count + 1]
	set num [lindex [split $line] 2]
	set return "$return $num:$q_count"
		}
	}
		close $file
}
	return $return
}
	
proc quote:add {nick host chan who quote} {
	global black
	set temp_num 0
	set num 0
	set time [unixtime]
	
	while {$temp_num == 0} {
	set get [find:q:num $num $chan]
if {$get == "$num"} {
	set num [expr $num + 1]
	} else { set temp_num 1 }
}
	set file [open $black(quote_file) a]
	set enc_chan [encoding convertto utf-8 $chan]
	set encoded [encoding convertto utf-8 $quote]
	puts $file "$enc_chan QUOTE $num $nick $time $who $encoded"
	close $file
	return $num
}

##############
#########################################################################
##   END                                                               ##
#########################################################################