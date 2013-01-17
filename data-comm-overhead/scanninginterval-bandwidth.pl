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
my @delta = (30);
my @checkInterval = (1,15,30,60);
my @targets = (11);
my $percentage = (10);


# constants

my $folder = "data/";
my $delimiter = "\t";
my $outputFolder = "scanninginterval-bandwidth/";



# main program
deleteOutputFiles();
loopThroughFiles();
plotGraphs();


sub plotGraphs {
	exec('cd ' . $outputFolder . ' && gnuplot plot-total && cd ..');
}

sub loopThroughFiles {
		foreach my $c (@checkInterval) {
		my $outputMeanCollect = Statistics::Descriptive::Full->new();
		my $outputMaxCollect = Statistics::Descriptive::Full->new();
		foreach my $r (@range) {
			foreach my $d (@delta) {
				my $meanCollect = Statistics::Descriptive::Full->new();
				my $maxCollect = Statistics::Descriptive::Full->new();
				my $mean;
				my $max;

				foreach my $t (@targets) {
					my $inputFile;
					my $outputFile;

					if($c == 1) { 
						$inputFile = $folder . "triangulation-CI-" . $c  .  "-D" . $d . "-R" . $r . "-PCT" . $percentage . "-TGT" . 7073 . ".csv";
						$outputFile = $folder . "triangulation-CI-" . $c  .  "-R" . $r . "-R" . $r . "-PCT" . $percentage . "-TGT" . 7073 . "-summary.csv";
					} else {
						$inputFile = $folder . "triangulation-CI-" . $c  .  "-D" . $d . "-R" . $r . "-PCT" . $percentage . "-TGT" . $t . ".csv";
						$outputFile = $folder . "triangulation-CI-" . $c  .  "-R" . $r . "-R" . $r . "-PCT" . $percentage . "-TGT" . $t . "-summary.csv";
					}
					my @csvData = readCSV($inputFile);
					($mean, $max) = computeAvgMax(@csvData);

					$meanCollect->add_data(convertToKBs($d,$mean));
					$maxCollect->add_data(convertToKBs($d,$max));		

					$outputMeanCollect->add_data(convertToKBs($d,$mean));
					$outputMaxCollect->add_data(convertToKBs($d,$max));
				}


				my $outputFile = $outputFolder . "triangulation-D" . $d  .  "-R" . $r . "-PCT" . $percentage . "-summary.csv"; 

				writeLine($outputFile,$c . "\t" . $meanCollect->mean() .
						"\t" . $maxCollect->mean() . "\n");


			}
		}

		my $outputFile = $outputFolder . "triangulation-total.csv";  

		writeLine($outputFile,$c . "\t" . $outputMeanCollect->mean() .
				"\t" . $outputMaxCollect->mean() . "\n");




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

					my $outputFile = $outputFolder . "triangulation-D" . $d  .  "-R" . $r . "-PCT" . $percentage . "-summary.csv"; 
					deleteFile($outputFile);
					writeLine($outputFile,"#scanningInterval \t mean \t max \n");
					$outputFile = $outputFolder . "triangulation-total.csv";  
					deleteFile($outputFile);
					writeLine($outputFile,"#scanningInterval \t mean \t max \n");

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

	open (FILE, $_[0]) or die "Couldn't open location file:" . $_[0];
	while (<FILE>) {
		next if ($. == 1);
		$csv->parse($_);
		push(@result, [$csv->fields]);
	}
	close FILE;
	return @result;
}


sub computeAvgMax {
	my $stat = Statistics::Descriptive::Full->new();

        foreach my $i (@_) {    
                $stat->add_data($i->[9]);
        }


	my $mean = $stat->mean();
	my $max = $stat->max();

	return ($mean, $max);
}

sub convertToKBs {
	# compute KiloBytes per Minute
	my $totalKiloBytesPerMinute = $_[1] * 9 * (60 / $_[0]);	

	# add 10% transport overhead
	#$totalKiloBytesPerMinute = $totalKiloBytesPerMinute * 1.1;

	# compute KiloBytes per second
	my $kilobytes = ($totalKiloBytesPerMinute/60);

	# divide by 905 to get bandwidth for 100 scanning nodes
	return (($kilobytes/905)*1000);
}


