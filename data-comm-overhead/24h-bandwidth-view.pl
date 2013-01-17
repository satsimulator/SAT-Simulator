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
my @delta = (30);
my @checkInterval = (15);
my @targets = (11);
my $percentage = (10);


# constants

my $folder = "data/";
my $delimiter = "\t";
my $outputFolder = "24h-bandwidth-view/";

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
                foreach my $c (@checkInterval) {
                foreach my $r (@range) {
                        foreach my $d (@delta) {

                                foreach my $t (@targets) {
                                	my $inputFile;
                                	my $outputFile;

					$inputFile = $folder . "triangulation-CI-" . $c  .  "-D" . $d . "-R" . $r . "-PCT" . $percentage . "-TGT" . 7073 . ".csv";
					$outputFile = $folder . "triangulation-CI-" . $c  .  "-R" . $r . "-R" . $r . "-PCT" . $percentage . "-TGT" . 7073 . "-summary.csv";

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
			my $min = $statCollect->min();
			my $max = $statCollect->max();
			my @tmp;
			push(@tmp,$min);
			push(@tmp,$mean);
			push(@tmp,$max);

			push(@{$temporaryData[$interval]},[@tmp]);

			$interval++;
			$j = 0;
			$statCollect = Statistics::Descriptive::Full->new();
		}

		$statCollect->add_data(convertToKBs($line->[9])); # 9th collumn
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
		my $statCollect = Statistics::Descriptive::Full->new();
		$statCollect->add_data($_->[0]);
		my @tmp;
		push(@tmp,($interval * $AGGR_DELTA));
		push(@tmp,$statCollect->mean());
		push(@tmp,$statCollect->min());
		push(@tmp,$statCollect->max());
		if ($DEBUG) { print "interval:" . ($interval * $AGGR_DELTA)  . " min:" . $statCollect->min() . " mean:" . $statCollect->mean() ." max:" . $statCollect->max()  . "\n"; }

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

	print OUTPUT "#time\tmean\tmin\tmax\n";

	foreach (@_) {

		print OUTPUT "" . $_->[0] .  $delimiter . $_->[1] . $delimiter . $_->[2] . $delimiter . $_->[3] . "\n";

	}


	close OUTPUT;
}


################################
# compute average and max
################################
sub computeAvgMax {
        my $stat = Statistics::Descriptive::Full->new();

        foreach my $i (@_) {    
                $stat->add_data($i->[9]);
        }


        my $mean = $stat->mean();
        my $max = $stat->max();

        return ($mean, $max);
}

################################
# 
################################
sub convertToKBs {
        # compute KiloBytes per Minute


	#detections * #message size (in kilobytes) * (60 seconds / #Delta seconds)
        my $totalKiloBytesPerMinute = $_[0] * 9 * (60 / @delta->[0]);  # 9 kilobytes includes 10% overhead

        # compute KiloBytes per second
        my $kilobytes = ($totalKiloBytesPerMinute/60);

        # divide by 905 to get bandwidth for 100 scanning nodes
        return (($kilobytes/905)*1000);
}



################################
# plot graph
################################

sub plotGraph {
	exec('cd ' . $outputFolder . ' && gnuplot plot-total && cd ..');
}
