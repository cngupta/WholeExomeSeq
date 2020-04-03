#! /usr/bin/perl

# Script to call somatic variants from Tumor Normal samples 

# Author: Chirag Gupta (cxg040@uark.edu)

$usage = "\nUsage: perl $0 NormalFwd NormalRev TumorFwd TumoRev2 #threads genomeFile bwaIndx outTag  \n\n"; # $0 holds the absolute path of this script
$Nforward = @ARGV[0]; #Normal forward reads
$Nreverse = @ARGV[1]; #Normal reverse reads
$Tforward = @ARGV[2]; #Tumor forward reads
$Treverse = @ARGV[3]; #Tumor reverse reads
$threads = @ARGV[4]; 
$gnome= @ARGV[5]; #genome fasta file
$bwaIndex= @ARGV[6]; #path to BWA index
$tag= @ARGV[7]; #unique tag for the sample/patient
$ARGV[7] or die $usage;
chomp($gnome);

$Nfwdpaired = $Nforward . 'paired.fastq';
$Nfwdup = $Nforward . 'unpaired.fastq'; 
$Nrevpaired = $Nreverse . 'paired.fastq';
$Nrevup = $Nreverse . 'unpaired.fastq';


#Normal sample
system "java -jar /home/ubuntu/bin/Trimmomatic-0.38/trimmomatic-0.38.jar PE -phred33 $Nforward $Nreverse $Nfwdpaired $Nfwdup $Nrevpaired $Nrevup LEADING:20 TRAILING:20"; #trim read ends
system "bwa mem -t $threads $bwaIndex $Nfwdpaired $Nrevpaired  > Normal.sam";
system "samtools view -bF 4 -q 1 Normal.sam > Normal.bam"; #remove unmapped reads and create bam file from sam
system "picard FixMateInformation I=Normal.bam O=Normal.fixmate.bam TMP_DIR=./tmp SO=coordinate VALIDATION_STRINGENCY=STRICT";
system "picard ReorderSam I=Normal.fixmate.bam O=Normal.fixmate.reorder.bam R=$gnome TMP_DIR=./tmp VALIDATION_STRINGENCY=STRICT";
system "picard MarkDuplicates I=Normal.fixmate.reorder.bam O=Normal.fixmate.reorder.mrkdup.bam METRICS_FILE=./metrics_file.txt VALIDATION_STRINGENCY=STRICT";
system "picard AddOrReplaceReadGroups I=Normal.fixmate.reorder.mrkdup.bam O=Normal.fixmate.reorder.mrkdup.rg.bam"; 
system "picard BuildBamIndex I=Normal.fixmate.reorder.mrkdup.rg.bam";


#Tumor sample
system "java -jar /home/ubuntu/bin/Trimmomatic-0.38/trimmomatic-0.38.jar PE -phred33 $Tforward $Treverse $Tfwdpaired $Tfwdup $Trevpaired $Trevup LEADING:20 TRAILING:20"; #trim read ends
system "bwa mem -t $threads $bwaIndex $Tfwdpaired $Trevpaired  > Tumor.sam";
system "samtools view -bF 4 -q 1 Tumor.sam > Tumor.bam"; #remove unmapped reads and create bam file from sam
system "picard FixMateInformation I=Tumor.bam O=Tumor.fixmate.bam TMP_DIR=./tmp SO=coordinate VALIDATION_STRINGENCY=STRICT";
system "picard ReorderSam I=Tumor.fixmate.bam O=Tumor.fixmate.reorder.bam R=$gnome TMP_DIR=./tmp VALIDATION_STRINGENCY=STRICT";
system "picard MarkDuplicates I=Tumor.fixmate.reorder.bam O=Tumor.fixmate.reorder.mrkdup.bam METRICS_FILE=./metrics_file.txt VALIDATION_STRINGENCY=STRICT";
system "picard AddOrReplaceReadGroups I=Tumor.fixmate.reorder.mrkdup.bam O=Tumor.fixmate.reorder.mrkdup.rg.bam"; 
system "picard BuildBamIndex I=Tumor.fixmate.reorder.mrkdup.rg.bam";


system "samtools mpileup -q 1 -f $gnome Normal.fixmate.reorder.mrkdup.rg.bam Tumor.fixmate.reorder.mrkdup.rg.bam  > Normal-tumor.mpileup";
system "java -jar /home/ubuntu/bin/varscan/VarScan.v2.4.3.jar somatic Normal-tumor.mpileup $tag.Varscan2.normal-tumor --mpileup 1 --output-vcf 1" ;




