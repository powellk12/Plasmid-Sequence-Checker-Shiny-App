# Plasmid-Sequence-Checker-Shiny-App
Shiny App that checks for the plasmid insert sequence to be aligned with a reference sequence. Uses FASTA files. 

Recombinant Plasmid DNA Creation and Sequencing Project

Using Benchling to Visualize the Plasmid Orientation and Check Mismatches: 
In my CCSF course, I used Benchling to check that the correct inserts were ligated into the pcDNA3.1(+) vector. I created the recombinant plasmid in vitro on Benchling using the cut sites for the restriction enzymes NotI and BamHI on both the pcDNA3.1(+) vector and the dsRedMito section of the donor plasmid. 

Benchling has a feature that allows alignment of the Sanger sequences with the in vitro plasmid sequence to check that the ligation was performed correctly. I used a forward primer for one aliquot of the sample, and a reverse primer for the second aliquot. I aligned both these sequences to the in vitro plasmid sequence in the Benchling software to check for mismatches and insert orientation. 

For the sample treated with the forward primer (bp length 910), there were three mismatches. The sample treated with the reverse primer (bp length 891) had five mismatches. 

Creating a Shiny App in R to Check for Mismatches and Presence of Insert:
I decided this would be a great opportunity to review creation of a Shiny App in R. I already had information from the plasmids that I could use to cross-check that my app was reading and interpreting the sequence data correctly. I was also unfamiliar with the Biostrings and pwalign packages and wanted practice manipulating strings of DNA in R. 

I first created a basic skeleton of the Shiny App that would prompt users to upload the FASTA files for the in vitro template to check their Sanger sequence against. They would also upload their Sanger sequence insert data as a FASTA file. 

I made the app offer the ability to trim the ends off the insert sequences because I ran into errors with the accuracy of the readings toward the 5' and 3' ends of the DNA. I could have lowered the acceptable ratio of mismatches to trigger the function that checks for the insert, but I decided to have the app trim off the unreliable base pair reads on either end. The user has the option to change the length that is trimmed in the UI of the app. 

The app then uses the pwalign::pairwiseAlignment() function to align the sequence strings and check for mismatches. The ligation success is determined by the ratio of matches to the length of the insert. The threshold it is currently set at is 0.85, and can be adjusted if needed on the back end. 

The app will display both sequences aligned. If I find more time for the project, I am working on a version that displays a mismatch table.
