#!/usr/bin/env ksh

typeset -a checks=( $(<./errorprone.buglist) ) 


print ${checks[@]}


for i in ${!checks[@]}; do
	print "Creating patch for ${checks[i]}..."
	mkdir -v "ep/${checks[i]}"
	print "Generating pom.xml..."
	sed "s/#|CHECK|#/${checks[$i]}/g" pom_tmpl.xml > pom.xml && wait
	print "Cleaning project..."
	{ mvn clean && wait; } > /dev/null 2>&1
	print "Compiling source to generate patch..."	
	{ mvn -P fixerrors compile && wait; } > /dev/null 2>&1
	
	ls -a
	if [[ -e error-prone.patch ]]; then
		print "moving path for ${checks[i]}..."
		mv -v ./error-prone.patch "./ep/${checks[$i]}/"
	else
		print "No patch generated, deleting ./ep/${checks[i]} ..."
		rm -vfr "./ep/${checks[$i]}"
	fi
done

ls ep


	
