library(Rsubread)
ann <- "/data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/gtf/dmel-all-r6.21.gtf"

setwd("/data/lai/moroa/RNA-seq")
files <- list.files(path = ".",pattern = "sortedByCoord")


for (d in list.dirs('.', recursive=FALSE)){
	f_name = list.files(path =d,pattern = "bam$")
	file = paste(d,f_name,sep="/")
	print (file)
	seq_data <- featureCounts(file,annot.ext=ann,isGTFAnnotationFile = TRUE, countMultiMappingReads=TRUE,allowMultiOverlap=TRUE,isPairedEnd=TRUE)
	assign(f_name,seq_data$count)
	write.table(get(f_name),paste(d,"/",f_name,".txt",sep=""),sep="\t",quote=F,col.names="ID\tNUMBER")
	}
