#!/usr/bin/env ksh

typeset -a checks=( $(<./errorprone.hitlist) ) 

(( $# > 0 )) && unset -v checks && typeset -a checks=( ${*} )

print ${checks[@]}

function mkpom
{

	print "Generating pom.xml..."
	sed "s/#|CHECK|#/${checks[i]}/g" pom_tmpl.xml > pom.xml && wait

	return
}
function mkpdir
{
	print "Creating patch dir ${checks[i]}/..."
	mkdir -v "ep/${checks[i]}"

	return
}
function clean
{

	print "Cleaning project..."
	{ mvn clean && wait; } > /dev/null 2>&1

	return
}
function comp
{

	print "Compiling source to generate patch..."
	{ mvn -P fixerrors compile && wait; } > /dev/null 2>&1

	return
}

function mp
{

	ls -a
	if [[ -e error-prone.patch ]]; then
		print "moving path for ${checks[i]}..."
		mv -v ./error-prone.patch "./ep/${checks[$i]}/"
	else
		print "No patch generated, deleting ./ep/${checks[i]} ..."
		rm -vfr "./ep/${checks[$i]}"
	fi

	return
}

for i in ${!checks[@]}; do
	print "Creating patch for ${checks[i]}..."
	mkpom
	mkpdir
	clean
	comp
	mp

done

ls ep


	
