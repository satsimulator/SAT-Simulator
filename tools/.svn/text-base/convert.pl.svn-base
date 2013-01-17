#!/usr/bin/perl


my $AGGR_DELTA = 600; # seconds
my $delimier = "\t";

my $DEBUG = 1; # 0 = no debug; 1 = some debug info



#############################
# read CSV data into array
#############################

use Text::CSV;

my @triangulations;
my $csv = Text::CSV->new({
	'quote_char'  => '',
	'escape_char' => '',
	'sep_char'    => "\t",
	'binary'      => 1
});

open (FILE, $ARGV[0]) or die "Couldn't open location file: $!";
while (<FILE>) {
	next if ($. == 1);
	$csv->parse($_);
	push(@triangulations, [$csv->fields]);
}
close FILE;


################################
# compute aggregation
################################
print("compute aggregation\n");

my $interval = 0;
my @aggregated;
my $j = 0;

foreach (@triangulations) {
	my @data; push (@data, $_);
	if ($DEBUG) { print "parsed timestamp: " . $data[0][0] . " with deviation:" . $data[0][8] . "\n"; }
	
	$j++;
	if (($data[0][0] / $AGGR_DELTA) > $interval) { $interval++; $j = 0; } # next aggr interval	
	$aggregated[$interval][$j] = $data[0];
}


my @result;
my $i = 0;


################################
# compute high-low
################################

print $result;

print("compute high-low\n");

$j = 0;
my $i = 0;


foreach my $dataInterval (@aggregated) {

	$i = 0;
	my $ylow = 0;
	my $yhigh = 0;
	my $AVGdeviation = 0;
	my $AVGtime = 0; #seconds

	if ($DEBUG) { print "computing high-low " . $dataInterval[$j][0] . "\n"; }
	foreach my $line (@dataInterval) {
		print $line[8];
		if ($line[8] < $ylow) { $ylow = $line[8] }
		if ($line[8] > $yhigh) { $yhigh = $line[8] }
		$AVGdeviation = $AVGdeviation + $line[8];
		$AVGtime = $AVGtime + $line[0];
		$i++;
	}
	
	

	if($i != 0) {

		$AVGdeviation = $AVGdeviation / $i;
		$AVGtime = $AVGtime / $i;
		
		@tmp = ($AVGtime, $AVGdeviation, $ylow, $yhigh);
		$result[$j] = @tmp;

		if($DEBUG) {
			print "adding to result\n";
			print "avgtime:" . $AVGtime . " avgdev:" . $AVGdeviation . " ylow:" . $ylow . " yhigh:" . $yhigh . "";
		}
	}

	$j++;
}

################################
# Write to disk
################################

print("write to disk\n");

open OUTPUT, ">aggr-" . $ARGV[0];

my $csv_output = "";

foreach my $row (@result) {
	foreach my $value ($row) {
		print "lol";
		$csv_output = "" . $csv_output . $value . $delimiter . "\n";
	}
}

print OUTPUT $csv_output;

close OUTPUT;





