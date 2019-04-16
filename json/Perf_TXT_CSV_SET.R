setwd('F:/HPM_UAT/DGIS_InputOutput/csv')
csv_data<-list()
listcsv <- dir(pattern = "*.txt") # creates the list of all the csv files in the directory
for (j in 1:length(listcsv)){
	csv_data[[j]]<-read.csv(file=listcsv[j], header=TRUE, sep=",")
if (j==1) {  write.table(csv_data[[j]], file = "HPM_OUTPUT_perf.csv",sep=",",append=F,col.names = TRUE,row.names=F,quote = TRUE) } 
 else { write.table(csv_data[[j]], file = "HPM_OUTPUT_perf.csv",sep=",",append=T,col.names = F, row.names=F ,quote = TRUE) }
}
