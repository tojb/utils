#!/usr/bin/perl -w

# ellpov
# Takes an ellipsoid configuration and produces an input file
# for the ray-tracing program povray to visualise it.  This version
# takes options from the command line and does not use standard input
# and output.
#

$pi = atan2(1.0, 1.0) * 4.0;

$angle = 10.0;
$bright = 0;
$fade = 0.0;
$input = "config";
$length = 0.001;
$location = "";
$output = "";
$phong = 0.0;
$look_at = "1,0,0"; 
$forceCol = -99.0;
$append = 0;
$transmit = 0.0;
$scale    = 1.0;
$arg = 0;
while ($arg <= $#ARGV) {
   if ($ARGV[$arg] eq "-h") {
      print "\n";
      print "Usage: ellpov [-a angle] [-b] [-c location] [-f fade] [-i infile] [-l length]\n";
      print "                   [-m phong] [-o outfile] [-s spectral] [-S scale] [-t transparency] [-p]\n";
      print "\n";
      print "angle        povray view angle (default: 10.0)\n";
      print "fade         fade blue hues by a factor 0 to 1 to increase contrast (default: 0)\n";
      print "infile       configuration file to read (default: \"config\")\n";
      print "length       half symmetry axis (default: 0.001)\n";
      print "location     camera location (default: from positive z, e.g. \"0, 0, 100\")\n";
      print "outfile      name of povray file to write (default: \"<infile>.pov\")\n";
      print "phong        metallic lustre (default: no metallic effect)\n";
      print "spectral     force colour to spectral position on [0..1] (also -1.0=monochrome)\n";
      print "transparency set transparency to value on [0..1]\n";
      print "scale        multiply size by scaling factor\n";
      print "\n";
      print "-b        brighten colours by scaling RGB components to make the largest unity\n";
      print "-p        appending (postfixing) ellipse objects, so write no new header\n";
      print "\n";
      exit;
   } elsif ($ARGV[$arg] eq "-a") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No value supplied after -a\n" };
      $angle = abs($ARGV[$arg]);
   } elsif ($ARGV[$arg] eq "-b") {
      $bright = 1;
   } elsif ($ARGV[$arg] eq "-c") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No location supplied after -c\n" };
      $location = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-k") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No look_at supplied after -k\n" };
      $look_at = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-f") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No fade factor supplied after -f\n" };
      $fade = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-i") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No filename supplied after -i\n" };
      $input = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-l") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No value supplied after -l\n" };
      $length = abs($ARGV[$arg]);
   } elsif ($ARGV[$arg] eq "-m") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No value supplied after -m\n" };
      $phong = abs($ARGV[$arg]);
   } elsif ($ARGV[$arg] eq "-o") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No filename supplied after -o\n" };
      $output = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-s") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No spectrum position supplied after -s\n" };
      $forceCol = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-t") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No transparency supplied after -t\n" };
      $transmit = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-S") {
      $arg++;
      if ($arg > $#ARGV) { die "ERROR: No scale supplied after -S\n" };
      $scale = $ARGV[$arg];
   } elsif ($ARGV[$arg] eq "-p") {
      $arg++;
      $append = 1;
   } else {
      die "ERROR: Unrecognised command line option: $ARGV[$arg]\n";
   }
   $arg++;
}

if ($fade < 0.0 || $fade > 1.0) {
   die "\nERROR: Fade factor must lie in the range 0 to 1\n\n";
}

if ($output eq "") { $output = "$input.pov"; }

if ($phong > 0.0) {
   $phong = "finish {metallic phong $phong}";
} else {
   $phong = "";
}


@data = ();

open (FH, $input) || die "ERROR: Could not open \"$input\"\n";
while (<FH>) {
   next if /^#/;  
   chomp;
   push @data, $_;
}
close FH;

open (FH, ">$output");

# Write header
if( $append == 0 ) {

print FH "#include \"colors.inc\"\n";
print FH "background { color White }\n";

print FH "#declare Ellipsoid = sphere { <0, 0, 0>, 0.5 scale <$scale,$scale,$scale*$length> }\n";

}

$lala=0.0;
$maxr = 0.0;
for ($i=0; $i<=$#data; $i++) {
   @line = split " ", $data[$i];
   if ($#line < 5 && $#line != 2 ) {
       print "\nWARNING: Each line of input must contain three or six components\n\n";
       print "line was:\n_\n".$data[$i]."\n_\n";
       die;
   }
   if ($#line == 2) {
       ($x, $y, $z) = @line;
        $ux = 1.0; $uy = 0.0; $uz = 0.0;
   }
   if ($#line == 5) {
       ($x, $y, $z, $ux, $uy, $uz) = @line;
   }
   if ($#line == 6) {
       ($x, $y, $z, $ux, $uy, $uz, $lala) = @line;
   }
   

   $mag = sqrt($ux*$ux + $uy*$uy + $uz*$uz);
   $ux /= $mag;
   $uy /= $mag;
   $uz /= $mag;

   $red   = abs($ux);
   $green = abs($uy);
   $blue  = abs($uz);

   if( $forceCol != -99.0 ) {
	$red   =  1.0 - 2.0 * $forceCol;
	$blue  = -1.0 + 2.0 * $forceCol;

	if( $red < 0.0 ) {
		 $red = 0.0;
	}
	if( $blue < 0.0 ) {
		 $blue = 0.0;
	}
	$green = 1.0 - $red - $blue;
   }
   if( $forceCol == -1.0 ) {
	$red   = 1.0;
	$green = 1.0;
	$blue  = 1.0;
   }

   # Fade blues
   $scale = 1.0 - sqrt(1.0 - $blue*$blue);
   $red   += $scale * $fade;
   $green += $scale * $fade;

   # Brightening
   if ($bright == 1) {
      $scale = largest($red, $green, $blue);
   } else {
      $scale = 1.0;
   }
   $red   /= $scale;
   $green /= $scale;
   $blue  /= $scale;

   $r = $x*$x + $y*$y + $z*$z;
   if ($r > $maxr) { $maxr = $r };
   $theta = atan2(sqrt(1.0-$uz*$uz), $uz) * 180.0 / $pi;
   $phi = 180.0 - atan2($ux, $uy) * 180.0 / $pi;
 
	printf FH "object { Ellipsoid rotate $theta*x rotate $phi*z\n".
             "                        translate <$x, $y, $z>\n".
             "                        texture {$phong pigment {color rgbt <$red , $green, $blue, $transmit>}} }\n"

   
}
if( $append == 0 ) {

$r = 50.0*sqrt(sqrt($r));
if ($location eq "") { $location = "0, 0, $r"; }
printf FH "camera { location <$location> angle $angle sky <0, 0, 1> look_at <$look_at> }\n";
printf FH "light_source { <$location> color White }\n";
}
close FH;

#--------------------------------------------------------------------------------

# Returns the largest of three arguments.

sub largest
{
   if ($_[0] >= $_[1] && $_[0] >= $_[2]) {
      return $_[0];
   } elsif ($_[1] >= $_[0] && $_[1] >= $_[2]) {
      return $_[1];
   } else {
      return $_[2];
   }
}
