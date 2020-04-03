# Somatic mutation calling in whole exome sequence data 

* Works with matched Tumor Normal samples
* Needs human genome and bwa index in the directory called genome 
* Uses GATK best preactices pipeline for preprocessing
	* FixMateInformation
	* ReorderSam
	* MarkDuplicates
	* AddOrReplaceReadGroups
* Uses Samtools mpileup and Varscan for calling variants

