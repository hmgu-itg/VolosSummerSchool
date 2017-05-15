#========================================================================================
### Exclude samples based on IBD 

IBDcutoff<-0.2

file1="/nfs/t144_helic/notebooks/VolosSummerSchool/Workshop_QC/kh7/tab-VSS-chr1-22-mafgte0.01-noCR-LDpruned0.2-genome.genome"
file2="/nfs/t144_helic/notebooks/VolosSummerSchool/Workshop_QC/kh7/VSS-chr1-22-mafgte0.01-missing.imiss"
file3="/nfs/t144_helic/notebooks/VolosSummerSchool/Workshop_QC/kh7/VSS_IDsToExcludeonIBD.out"

IBDinfo<-read.table(file1,header=TRUE)
MISSinfo<-read.table(file2,header=TRUE)
MISSinfo<-cbind(MISSinfo,CallRate=1-MISSinfo$F_MISS)

st<-which(IBDinfo$PI_HAT>IBDcutoff)
rel<-IBDinfo[st,c(2,4,10)]

IBDinfo<-read.table(file1,header=TRUE)
MISSinfo<-read.table(file2,header=TRUE)
MISSinfo<-cbind(MISSinfo,CallRate=1-MISSinfo$F_MISS)

st<-which(IBDinfo$PI_HAT>IBDcutoff)
rel<-IBDinfo[st,c(2,4,10)]

EXCLUDE <- -1
if(nrow(rel)==1){
	cr<-c(MISSinfo[match(rel$IID1,MISSinfo$IID),]$CallRate,MISSinfo[match(rel$IID2,MISSinfo$IID),]$CallRate)
	indx<-min(cr)
	if(cr[1]!=cr[2]) exclude<-as.character(rel[1,which(cr==indx)])
	if(cr[1]==cr[2]) exclude<-as.character(rel[1,1])
}else{
	all<-c(as.character(rel$IID1),as.character(rel$IID2))
	mult<-table(all)
	cand<-cbind(id=names(mult),mult=as.numeric(mult))
	exclude<- -1
	for(i in 1:nrow(rel)){

		if( (!as.character(rel[i,]$IID1)%in%exclude) && (!as.character(rel[i,]$IID2)%in%exclude) ){

			mult1<-as.numeric(cand[match(as.character(rel[i,]$IID1),cand[,1]),2])
			mult2<-as.numeric(cand[match(as.character(rel[i,]$IID2),cand[,1]),2])
			if(mult1==mult2){
				cr<-c(MISSinfo[match(rel[i,]$IID1,MISSinfo$IID),]$CallRate,MISSinfo[match(rel[i,]$IID2,MISSinfo$IID),]$CallRate)
				indx<-min(cr)
				if(cr[1]!=cr[2]) exclude<-c(exclude,as.character(rel[i,which(cr==indx)]))
				if(cr[1]==cr[2]) exclude<-c(exclude,as.character(rel[i,1]))
			}else if(mult1>mult2){
				exclude<-c(exclude,as.character(rel[i,]$IID1))
			}else{
				exclude<-c(exclude,as.character(rel[i,]$IID2))
			}

		}
	}
	exclude<-exclude[-1]
}
EXCLUDE<-c(EXCLUDE,exclude)
EXCLUDE<-EXCLUDE[-1]

write.table(cbind(EXCLUDE,EXCLUDE),file3,quote=FALSE,row.names=FALSE,col.names=FALSE)

