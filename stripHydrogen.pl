#!/usr/bin/perl
#perl script to get rid of hydrogens from a pdb file
#
#
#
#to run:$ perl -w script.prl
#josh.

##############################################
# Parameters:
#accept if passed in as arguments.
if( scalar ( @ARGV ) == 1 )
{
	$inPDBName       = shift;
}
else
{
	print "stripHydrogen.prl: requires single argument, an input pdb file\n";

	die;
}



##############################################
#
#open the file
open( my $inPDB,  $inPDBName )    or die "Couldn't read $inPDBName: $!";


#read through the pdb by lines.
while ( $pdbLine = <$inPDB> ) 
{
    #match a pattern to check we have an atom entry
    if ( $pdbLine =~ /ATOM\s+\S+\s+(\S+).+/ )
    {

	    #the regexp ought to dump the atom and residue names into these.
	    $atomName = $1;

	    #if we have one of the funny-named hydrogens 
	    #that leap doesn't like
	    if(( $atomName eq "HB1" )
             ||( $atomName eq "HG1" )
             ||( $atomName eq "HD1" )
             ||( $atomName eq "H1" )
             ||( $atomName eq "H2" )
             ||( $atomName eq "H" )
             ||( $atomName =~ /H.+/ )
             ||( $atomName eq "H3" ))
	    {
		#just skip this line and don't print it out
		
		next;
	    }

	    #catch this non-standard code for an amide cap
	    if( $atomName eq "NH2")
	    {
		#replace NH2 with NHE in string $pdbline
		$pdbLine =~ s/NH2/NHE/g;

		#change the atom names as well
		$pdbLine =~ s/1H\s/1HN/g ;
		$pdbLine =~ s/2H\s/2HN/g ;

	    }




	}

    print $pdbLine;
}

