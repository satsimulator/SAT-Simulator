#!/usr/bin/perl

# author Daniel Genis
# reads simulation output data, calculates mean dev and standard dev. writes
# output to csv file
#
# also plot the relevant graphs



# imports
use strict;
use warnings;
use Text::CSV;
use Statistics::Descriptive;

# variables

my @range = (15,30,45);
my @delta = (30,60);
my @checkInterval = (1,15,30,60);
my @targets = (11,229,1159,2208,3211,4339,5120,6051,7073,8184);
my $percentage = (10);


# constants

my $folder = "data/";
my $delimiter = "\t";
my $outputFolder = "delta-timegap/";



# main program
deleteOutputFiles();
loopThroughFiles();
plotGraphs();


sub plotGraphs {
	exec('cd ' . $outputFolder . ' && gnuplot plot-total && gnuplot plot-rest && cd ..');
}



sub loopThroughFiles {
	foreach my $d (@delta) {
		my $meanCollect = Statistics::Descriptive::Full->new();
		foreach my $r (@range) {
			foreach my $c (@checkInterval) {
				my $mean = Statistics::Descriptive::Full->new();

				foreach my $t (@targets) {
					my $inputFile = $folder . "triangulation-CI-" . $c  .  "-D" . $d . "-R" . $r . "-PCT" . $percentage . "-TGT" . $t . ".csv";
					my $outputFile = $folder . "triangulation-CI-" . $c  .  "-R" . $r . "-R" . $r . "-PCT" . $percentage . "-TGT" . $t . "-summary.csv";
					my @csvData = readCSV($inputFile);

					my $maxTimeGap = computeMaxTimeGap(@csvData);
					$mean->add_data($maxTimeGap);
				}

				$meanCollect->add_data($mean->mean());

				my $outputFile = $outputFolder . "triangulation-CI-" . $c  .  "-R" . $r . "-PCT" . $percentage . "-summary.csv"; 

				writeLine($outputFile,$d . "\t" . $mean->mean() . "\n");


			}
		}

		my $outputFile = $outputFolder . "triangulation-total.csv";  

		writeLine($outputFile,$d . "\t" . $meanCollect->mean() . "\n");




	}
}

# functions

sub writeLine {
	open OUTPUT, ">>" . $_[0];
	print OUTPUT $_[1];
	close OUTPUT;
}

sub deleteFile {
	unlink ($_[0]);
}


sub deleteOutputFiles {
	foreach my $d (@delta) {
		foreach my $r (@range) {
			foreach my $c (@checkInterval) {
				foreach my $t (@targets) {

					my $outputFile = $outputFolder . "triangulation-CI-" . $c  .  "-R" . $r . "-PCT" . $percentage . "-summary.csv"; 
					deleteFile($outputFile);
					writeLine($outputFile,"#delta \t mean \n");
					$outputFile = $outputFolder . "triangulation-total.csv";  
					deleteFile($outputFile);
					writeLine($outputFile,"#delta \t mean \n");

	}	}	}	}

}


sub readCSV {
	my $csv = Text::CSV->new({
			'quote_char'  => '',
			'escape_char' => '',
			'sep_char'    => "\t",
			'binary'      => 1
			});

	my @result;

	open (FILE, $_[0]) or die "Couldn't open location file: $!";
	while (<FILE>) {
		next if ($. == 1);
		$csv->parse($_);
		push(@result, [$csv->fields]);
	}
	close FILE;
	return @result;
}


sub computeMaxTimeGap {
        my $firstTimestamp = 0;
        my $secondTimestamp = 0;
        my $timeGap = 0; #minutes

        foreach my $i (@_) {

                $firstTimestamp = $secondTimestamp;
                $secondTimestamp = $i->[0];
                

                if($timeGap < (($secondTimestamp - $firstTimestamp) / 60)) {
                        $timeGap = (($secondTimestamp - $firstTimestamp) / 60); 
                }
        }

        return ($timeGap);
}


