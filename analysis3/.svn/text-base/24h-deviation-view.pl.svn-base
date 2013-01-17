#!/usr/bin/perl

# imports
use strict;
use warnings;
use Text::CSV;
use Statistics::Descriptive;
use Data::Dumper;


#variables

my $AGGR_DELTA = 1800; # seconds
my $DEBUG = 2; # 0 = no debug; 1 = some debug info; 


my @range = (30);
my @delta = (60);
my @checkInterval = (15);
my @targets = (11,229,1159,2208,3211,4339,5120,6051,7073,8184);
my $percentage = (10);


# constants

my $folder = "data/";
my $delimiter = "\t";
my $outputFolder = "24h-deviation-view/";

my @temporaryData;
my @resultData;






# main programe

loopThroughFiles();  # also computes temporary aggregated. stored in @temporaryData
computeFinalData(@temporaryData); # computes final data. stored in @resultData
writeOutput(@resultData);
plotGraph();




#############################
# read CSV data into array
#############################

sub readCSV {
	my $csv = Text::CSV->new({
			'quote_char'  => '',
			'escape_char' => '',
			'sep_char'    => "\t",
			'binary'      => 1
			});

	my @result;

	open (FILE, $_[0]) or die "Couldn't open input file";
	while (<FILE>) {
		next if ($. == 1);
		$csv->parse($_);
		push(@result, [$csv->fields]);
	}
	close FILE;
	return @result;
}

### loop through selected files
sub loopThroughFiles {
	print "parsing data\n";
	foreach my $d (@delta) {
		foreach my $r (@range) {
			foreach my $c (@checkInterval) {
				foreach my $t (@targets) {
					my $inputFile = $folder . "triangulation-CI-" . $c  .  "-D" . $d . "-R" . $r . "-PCT" . $percentage .
						"-TGT" . $t . ".csv";
					my $outputFile = $folder . "triangulation-CI-" . $c  .  "-R" . $r . "-R" . $r . "-PCT" . $percentage .
						"-TGT" . $t . "-aggregated.csv";
					my @csvData = readCSV($inputFile);

					computeAggrArray(@csvData);
				}
			}
		}
	}
}


################################
# compute aggregation
################################

sub computeAggrArray {
	my $interval = 0;
	my @aggregated;
	my $j = 0;
	my $statCollect = Statistics::Descriptive::Full->new();

	foreach my $line (@_) {
		if (($line->[0] / $AGGR_DELTA) > $interval) {  # next aggr interval

# store results in temporary array
			my $mean = $statCollect->mean();
			my $stddev = $statCollect->standard_deviation();
			my @tmp;
			push(@tmp,$mean);
			push(@tmp,$stddev);

			push(@{$temporaryData[$interval]},[@tmp]);

			$interval++;
			$j = 0;
			$statCollect = Statistics::Descriptive::Full->new();
		}

		$statCollect->add_data($line->[8]);
		$j++;
	}
}



################################
# compute final results
################################

sub computeFinalData {
	print "computing final output data\n";
	my $interval = 0;
	foreach (@_) {
		my $statCollectAvg = Statistics::Descriptive::Full->new();
		my $statCollectStddev = Statistics::Descriptive::Full->new();
		$statCollectAvg->add_data($_->[0]);
		$statCollectStddev->add_data($_->[1]);
		my @tmp;
		push(@tmp,($interval * $AGGR_DELTA));
		push(@tmp,$statCollectAvg->mean());
		push(@tmp,$statCollectStddev->mean());
		if ($DEBUG) { print "interval:" . ($interval * $AGGR_DELTA)  . " average:" . $statCollectAvg->mean() . " stddev:" . $statCollectStddev->mean() ."\n"; }

		if($interval != 0) { # skip first result as it's not valid
			push(@resultData,[@tmp]);
		}
		$interval++;
	}


}

################################
# Write to disk
################################


sub writeOutput {

	print("writing results to disk\n");
	open OUTPUT, ">" . $outputFolder . "aggr-data.csv";

	my $interval = 0;

	print OUTPUT "#time\taverage\tstddev\n";

	foreach (@_) {

		print OUTPUT "" . $_->[0] .  $delimiter . $_->[1] . $delimiter . $_->[2] . "\n";

	}


	close OUTPUT;
}


################################
# plot graph
################################

sub plotGraph {
        exec('cd ' . $outputFolder . ' && gnuplot plot-total && cd ..');
}
