#########################################################################
##          BlackTools - The Ultimate Channel Control Script           ##
##                    One TCL. One smart Eggdrop                       ##
#########################################################################
#############################   GAG TCL   ###############################
#########################################################################
##						                       ##
##     BlackTools  : http://blacktools.tclscripts.net	               ##
##     Bugs report : http://www.tclscripts.net/	                       ##
##     Online Help : irc://irc.undernet.org/tcl-help 	               ##
##                   #TCL-HELP / UnderNet                              ##
##                   You can ask in english or romanian                ##
##					                               ##
#########################################################################

proc gag:process {gagger time reason nick hand host chan chan1 type} {
global botnick black
	set cmd_status [btcmd:status $chan $hand "gag" 0]
if {$cmd_status == "1"} { 
	return 
}	
	set split_hand [split $hand ":"]
	set gethand [lindex $split_hand 0]
	set getlang [string tolower [setting:get $chan lang]]
	set return_time [time_return_minute $time]
	set counter 0
	set num 0
	set temp_num 0
	set cmd "gag"
	set show_gagger $gagger
	set show_reason $reason
if {$getlang == ""} { set getlang "[string tolower $black(default_lang)]" }
	set handle [nick2hand $gagger]
if {[matchattr $hand q]} { blacktools:tell $nick $host $hand $chan $chan1 gl.glsuspend none
	return
}
if {[matchattr $hand -|q $chan]} { blacktools:tell $nick $host $hand $chan $chan1 gl.suspend none
	return
}
if {$gagger == ""} {
switch $type {
	0 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr $cmd
	}
	1 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr_nick $cmd
	}
	2 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr_priv $cmd
		}
	}
	return 0
}
if {![validchan $chan]} {
	blacktools:tell $nick $host $hand $chan $chan1 gl.novalidchan none
	return
}
if {![onchan $botnick $chan]} {
	blacktools:tell $nick $host $hand $chan $chan1 gl.notonchan none
	return
}

if {[matchattr $handle $black(exceptflags) $chan]} {
	blacktools:tell $nick $host $hand $chan $chan1 gl.noban none
	return
}

if {[isbotnick $gagger]} {
	return
}

if {![botisop $chan]} {
	blacktools:tell $nick $host $hand $chan $chan1 gl.noop none
	return
}

if {[isop $gagger $chan]} {
	blacktools:tell $nick $host $hand $chan $chan1 gl.hasop none
	return
}
if {[onchan $gagger $chan]} {
    set mask [return_mask [return_host_num $cmd $chan] [getchanhost $gagger $chan] $gagger] 
} else { 
	set mask ""
}

if {[blacktools:isban $mask $chan] == "1"} {
	blacktools:tell $nick $host $hand $chan $chan1 gag.4 $show_gagger
	return
}
if {[blacktools:isgag $mask $chan] == "1"} {
	blacktools:tell $nick $host $hand $chan $chan1 gag.3 $show_gagger
	return
}

if {[string equal -nocase $gagger "-list"]} {
foreach b [blacktools:gaglist $chan] {
	set bhost [lindex [split $b] 2]
	set counter [expr $counter + 1]
	set mask [lindex [split $b] 2]
	set expire [lindex [split $b] 4]
	set created [lindex [split $b] 5]
	set created [clock format $created -format %D-%H:%M:%S]
	set breason [lrange [split $b] 8 end]
	set bywho [lindex [split $b] 3]
	set split_bywho [split $bywho ":"]
	set handle [lindex [split $split_bywho] 0]
	set type [lindex [split $split_bywho] 1]
	set bywho "$handle\([string toupper $type]\)"
if {$type != ""} {
	set bywho "$handle\([string toupper $type]\)"
} else { set bywho $handle }
	set expire [return_time_2 $getlang [expr $expire - [unixtime]]]
	blacktools:tell $nick $host $hand $chan $chan1 sb.4 "$mask $bywho $created $expire $breason"
	}
	blacktools:tell $nick $host $hand $chan $chan1 gag.2 none
	return
}
	set split_hand [split $hand ":"]
	set handle [lindex $split_hand 0]
	set type [lindex $split_hand 1]
if {($return_time > "20160" || $return_time == "0")  && [matchattr $handle -|OS $chan]} {
	blacktools:tell $nick $host $hand $chan $chan1 gag.7 none
	return
}

if {$return_time == "-1"} {
	set return_time $black(gag_time)
}
	set return_time [time_return_minute $return_time]
	
if {$mask == ""} {
	blacktools:tell $nick $host $hand $chan $chan1 gl.usernotonchan $show_gagger
	return
}

if {$show_reason == ""} {
	set getreason [setting:get $chan gag-reason]
if {$getreason == ""} {
	set show_reason $black(say.$getlang.gag.6)
	} else {
	set show_reason $getreason
	}
}

if {[isvoice $gagger $chan]} {
	pushmode $chan -v $gagger
}
	set getlang [string tolower [setting:get $chan lang]]
if {$getlang == ""} { set getlang "[string tolower $black(default_lang)]" }
	set replace(%chan%) $chan
	set replace(%time%) [return_time $getlang [expr [expr [unixtime] + [expr $return_time * 60]] - [unixtime]]]
	set replace(%gagger%) $gagger
	set gag_user_message [string map [array get replace] $black(say.$getlang.gag.10)]
	set gag_chan_message [string map [array get replace] $black(say.$getlang.gag.11)]
	putserv "PRIVMSG $chan :$gag_chan_message"
	putserv "PRIVMSG $gagger :$gag_user_message"
	pushmode $chan +b $mask
while {$temp_num == 0} {
	set get [blacktools:ban:find_id $num]
if {$get == "$num"} {
	set num [expr $num + 1]
	} else { set temp_num 1 }
}
	blacktools:addban $nick $mask $hand $chan $chan1 $return_time "GAG" "0" "0" $show_reason "0" "" "" "" 0 $num

	set backchan [join [setting:get $chan backchan]]
if {$backchan == ""} { 
	return
}
if {!([validchan $backchan]) || !([onchan $botnick $backchan])} {
	return
}
	set bantime [time_return_minute $return_time]
	set bantime [expr $bantime * 60]
	set expire [return_time_2 $getlang $bantime]
	
	set replace(%banmask%) $mask
	set replace(%bantime%) $expire
	set replace(%reason%) $reason
	set replace(%chan%) $chan
	set replace(%nick%) $gethand
	puthelp "PRIVMSG $backchan :[string map [array get replace] $black(say.$getlang.reportchan.2)]"
}

proc gagpublic {nick host hand chan arg} {
global black lastbind
	set return [blacktools:mychar $lastbind $hand]
if {$return == "0"} {
		return
}
	set gagger [lindex [split $arg] 0]
	set time [lindex [split $arg] 1]
	set reason [join [lrange [split $arg] 2 end]]
	set type 0
	set handle [nick2hand $gagger]
	set chan1 "$chan"
	set return_time [time_return_minute $time]
if {$return_time == "-1"} {
	set reason [join [lrange [split $arg] 1 end]]
	set time [setting:get $chan gag-bantime]
if {$time == ""} {
	set time $black(gag:bantime)
	}
}
if {[regexp {^[&#]} $gagger] && [matchattr $hand nmo|MASO $gagger]} {
	set chan "$gagger"
	set gagger [lindex [split $arg] 1]
	set time [lindex [split $arg] 2]
	set reason [join [lrange [split $arg] 3 end]]
	set return_time [time_return_minute $time]
if {$return_time == "-1"} {
	set reason [join [lrange [split $arg] 2 end]]
	set time [setting:get $chan gag-bantime]
if {$time == ""} {
	set time $black(gag:bantime)
		}
	}
}
foreach c [channels] {
	set backchan [join [setting:get $c backchan]]
if {[string match -nocase $chan $backchan]} {
	set chan "$c"
	}
}

if {$gagger != ""} {
	gag:process $gagger $time $reason $nick "$hand:GAG" $host $chan $chan1 $type
	} else { gag:process $gagger $time $reason $nick $hand $host $chan $chan1 $type }
}


proc gag:part {nick host hand chan arg} {
	global black
if {![validchan $chan]} {
	return
}
	set uhost "$nick![getchanhost $nick $chan]"
	gag:leave $nick $uhost $chan
}

proc gag:split {nick host hand chan args} {
	global black
if {![validchan $chan]} {
	return
}
	set uhost "$nick![getchanhost $nick $chan]"
	gag:leave $nick $uhost $chan
}

proc gag:kick {nick host hand chan kicked reason} {
	global black
if {![validchan $chan]} {
	return
}
	set uhost "$kicked![getchanhost $kicked $chan]"
	gag:leave $kicked $uhost $chan
}

proc gag:leave {nick host chan} {
	global black
if {![validchan $chan]} {
	return
}
	foreach g [blacktools:gaglist $chan] {
	set read_host [lindex [split $g] 3]
if {[string match -nocase $read_host $host]} {
		pushmode $chan -b $read_host
		}
	}
}

################################# ungag ###############################

proc ungagpublic {nick host hand chan arg} {
global black
	set gagger [lindex [split $arg] 0]
	set type 0
	set chan1 "$chan"
if {[regexp {^[&#]} $gagger] && [matchattr $hand nmo|MASO $chan]} {
	set chan "$gagger"
	set gagger [lindex [split $arg] 1]
}
foreach c [channels] {
	set backchan [join [setting:get $c backchan]]
if {[string match -nocase $chan $backchan]} {
	set chan "$c"
	}
}
if {$gagger != ""} {
	ungag:process $gagger $nick $hand $host $chan $chan1 $type
	} else { ungag:process $gagger $nick $hand $host $chan $chan1 $type }
}

proc ungag:process {gagger nick hand host chan chan1 type} {
	global black
	set cmd_status [btcmd:status $chan $hand "ungag" 0]
if {$cmd_status == "1"} { 
	return 
}
if {[matchattr $hand q]} { blacktools:tell $nick $host $hand $chan $chan1 gl.glsuspend none
	return
}
if {[matchattr $hand -|q $chan]} { blacktools:tell $nick $host $hand $chan $chan1 gl.suspend none
	return
}
	set show_gagger $gagger
	set getlang [string tolower [setting:get $chan lang]]
if {$getlang == ""} { set getlang "[string tolower $black(default_lang)]" }
if {$gagger == ""} {
switch $type {
	0 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr "ungag"
	}
	1 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr_nick "ungag"
	}
	2 {
	blacktools:tell $nick $host $hand $chan $chan1 gl.instr_priv "ungag"
		}
	}
	return 0
}

if {![validchan $chan]} {
	return
}
if {[onchan $gagger $chan]} {
	 set mask [return_mask [return_host_num "gag" $chan] [getchanhost $gagger $chan] $gagger] 
} else {
	blacktools:tell $nick $host $hand $chan $chan1 gl.usernotonchan $show_gagger
	return
}

if {[blacktools:isgag $mask $chan] == "0"} {
	blacktools:tell $nick $host $hand $chan $chan1 ungag.5 $show_gagger
	return
} else {
	blacktools:delban $mask $chan "0" "1"
if {[ischanban $mask $chan]} {
	pushmode $chan -b $mask
}
	set replace(%chan%) $chan
	set replace(%gagger%) $gagger
	set ungag_user_message [string map [array get replace] $black(say.$getlang.ungag.7)]
	set ungag_chan_message [string map [array get replace] $black(say.$getlang.ungag.8)]

	putserv "PRIVMSG $gagger :$ungag_user_message"
	putserv "PRIVMSG $chan :$ungag_chan_message"
	}
}

proc gag:reban {nick host hand chan args} {
global black
	set bans [lindex $args 1]
if {![botisop $chan]} { return }
foreach user [chanlist $chan] {
	set gethost "$user![getchanhost $user $chan]"
if {[string match -nocase $bans $gethost]} {
if {[blacktools:isgag $bans $chan] == "1"} {
	pushmode $chan +b $bans
			}
		}
	}
}

##############
#########################################################################
##   END                                                               ##
#########################################################################