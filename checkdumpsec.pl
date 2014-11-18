###########################
# Find bad homefolders in
# a Windows domain
#
# Remember to change CONTOSO below into your
# own active directory domain!
#
# Input: DumpSec file of the root where your
#        home folders are located
# Output: List of home folders which are not
#         secured correctly
#
# Be aware! We define "correctly" in the sense
# that the user himself is the ONLY user added
# to the home folder
#
# By: Max Duijsens
###########################
$|++;
use strict;
use warnings;
use Text::CSV_XS;



#get all level 1 folders from dump (E:\users\123456)
# (actually '2' when split)
if ( $#ARGV != 0) { print "Check dumpsec\nUsage: $0 <csv filename>\neg. $0 bla.csv\n";
				exit; }

&parsecsv($ARGV[0]);

sub trim($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub parsecsv ($) {
my %gooddrives = ();
my %alldrives = ();
my %baddrives = ();
my (@regel, $f_userid, $temp_userid) = "";
	my $csvfile = shift;
	my $csv = Text::CSV_XS->new({sep_char => ','}) or
	die "Cannot use CSV: ".Text::CSV_XS->error_diag ();

	open my $fh, "<:encoding(utf8)", "$csvfile" or die ": $!"; #, "<:encoding(utf8)"
	open (OUT, ">bad_dumpsec_" . $csvfile . "");
	open (BAD, ">>bad_dumps.csv");

	my $servername = $csvfile;
	$servername =~ s/^udrive_fix_//;
	$servername =~ s/_dumpsec.*\.csv$//;


	#put all u-drives in hash
	# $udrives{path}{username} = perms;
	# if user is not added print it out immediately
	while(my $line = <$fh>) {

		if($csv->parse($line)) {
			@regel = $csv->fields();
		}

		$regel[0] = &trim($regel[0]);

		#check if path = level 1
		if ( $regel[0] =~ m/Somarsoft DumpSec/ ) {
			next;
		}

		my @splitpath = split(/\\/, $regel[0]);
		if ( scalar(@splitpath) == 3 ) { #filter out the u-drives themselves
			#crop last slash
			$regel[0] =~ s/\\$//;

			$f_userid = $splitpath[2];
			#per line:
			# if the user is added to the u-drive add it to hash %gooddrives
			# if the user is not added add to %alldrives
			my $tmp = "CONTOSO\\" . $f_userid;
			if ( &trim($regel[1]) eq $tmp ) {
				$gooddrives{"$f_userid"} = "$regel[0]";
			} else {
				$alldrives{"$f_userid"} = "$regel[0]";
			}
		}

	}


	# check if user with number is added to the folder
	#   if yes = good
	#   if no = print dumpsec to csv
	# eg. compare %alldrives with %gooddrives
	# userid is in good drives, remove it from alldrives
	# leftover alldrives lookup in dumpsec and print out

	foreach ( sort(keys(%alldrives)) ) {
		$temp_userid = $_;
		if ( !($gooddrives{$temp_userid}) ) {
			print BAD "$servername;$alldrives{\"$temp_userid\"};$temp_userid\n";
		}
	}
}
