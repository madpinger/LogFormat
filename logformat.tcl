#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}
puts "Beginning execution chat log formatter for MediaWiki"

#settings
set devs [list "Blorfy" "Richard_"];

proc FormatFile {x y} {
    #open infile for read
    if {[file exists $x]} {
	set infile [open $x r]
    } else {
	puts "File open error.  Unable to locate $x"
	return
    }
    #open outfile write
    if {![file exists $y]} {
	set outfile [open $y w]
    } else {
	puts "File exists error.  File $y all ready exists, please specify a different file name or rename $y."
	return
    }
    #read infile into memory
    set file_data [read $infile]
    #close infile
    close $infile
    #init vars/lists
    set nicklist "";set nick "";set comment "";set match "";set nc "000000";set c 0;set l 0;set m 0;set row "C0C0C0"
    #format data phase 1
    set file_data [split $file_data "\n"]
    #Beginning of file
    puts $outfile "<div style=\"background:#CCCCCC;\">";
    #iterate data
    foreach line $file_data {
	#puts $line
	#regex hell starts here. :D
	if {[regexp -nocase -all {\w\w\w\s\d\d\s\d\d:\d\d:\d\d\s(\*).*?\Z} $line]} {
	    #^\w\s\d\s\d:\d:\d\s(\*)\s(.*?)\Z
	    regexp -nocase -all {\w\w\w\s\d\d\s\d\d:\d\d:\d\d\s\*\s(.*?)\Z} $line junk match
	    puts $outfile "<I class=\"message\" style=\"color:#FFCC33;background:#181818;\"><FONT class=\"mode\">$match</FONT></I>";
	    incr m
	} else {
	    if {[regexp -nocase -all {\w\w\w\s\d\d\s\d\d:\d\d:\d\d\s<(.*?)>.*?\Z} $line]} {
		regexp -all {\w\w\w\s\d\d\s\d\d:\d\d:\d\d\s<(.*?)>(.*?)\Z} $line junk nick comment
		set nc "000000"
		foreach d $::devs {
		    if {[string tolower [string trim $d]] == [string tolower [string trim $nick]]} {
			set nc "FF0000"
		    }
		}
		if {[expr {$c % 2}] == 0} {
		    set row "C0C0C0"
		} else {
		    set row "FFFFFF"
		}
		puts $outfile "<P class=\"message\ style=\"background:#$row;\"><FONT class=\"chat\" style=\"color:#$nc;\">$nick :</FONT><FONT class=\"chat\"> $comment</FONT></P>"
		incr c
	    }
	}
	incr l
    }
    #close up file
    puts $outfile "</div>";
    close $outfile
    puts "Process finished.  Generated outfile $y from $x"
    puts "Proccessed $l lines, $m channel modes, and $c comments."
return
}
##############################################################################
# main loop
##############################################################################
#argc argv argv0
#    $argc - number items of arguments passed to a script.
#    $argv - list of the arguments.
#    $argv0 - name of the script.
# add switch for log format in future, expand project to other uses ?
if {$argc != 0} {
    if {[string tolower $argv] == "help" || \
	    [string tolower $argv] == "-help" || \
	    [string tolower $argv] == "--help" || \
	    [string tolower $argv] == "/help"} {
		puts "$argv0 infile outfile"
		puts "Where infile is a compatible chatlog file (Currently xchat2 logs only)."
		puts "Where outfile is the name of the file to store the reformatted output."
		return
    } else {
	if {[string length [lindex $argv 0]] && [string length [lindex $argv 1]]} {
	    if {[catch [FormatFile [lindex $argv 0] [lindex $argv 1]] errmsg]} {
		puts "Exception! $errmsg"
	    }
	}
    }
} else {
    puts "Usage:$argv0 infile outfile | --help"
}
