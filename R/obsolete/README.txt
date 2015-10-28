datacycler.r

Uses BCIdat_slicer.

Cuts EEG records by last start-bit (2). It works in directory that contains all the experiments data (*.asciis (made by launching compareFix.r in this directory) & *.dats) and *.csv file (separator - comma) with table with 4 columns: 1) 1200 ms *.dat filename; 2) corresponding *.edf filename; 3) 800 ms *.dat filename; 2) corresponding *.edf filename. The upper row of table must contain (by cells): 1) "1200ms"; 3) "800 ms"; 2,4) - empty. All values in table (including header row) must be WITHOUT QUOTES. File *.csv must be in the directory with records.

Makes in working directory directories like "WD\(experiment_number)\(fixation_latency) and puts in them corresponding cut *.mats with EEG data and *.asciis.

REMEMBER! After importing *.mat file to matlab do "data=data'" to rotate matrix.
