#!/bin/bash
#SBATCH --job-name=wsp_het
#SBATCH -A fnrtowhee
#SBATCH -t 10-00:00:00 
#SBATCH -N 1 
#SBATCH -n 20 
#SBATCH -e %x_%j.err
#SBATCH -o %x_%j.out

ml biocontainers
ml angsd
ml R

#Path to parent directory of genus-species
PD=/scratch/bell/blackan/PUPFISH/C.tularosa/popgen/illumina/angsd_out/
REF=/scratch/bell/blackan/PUPFISH/C.tularosa/assembly/ncbi/Cyprinodon-tularosa/GCF_016077235.1_ref/GCF_016077235.1.fna

cd $PD

mkdir ./HET
OUTDIR='HET'

ls -1 ../final_bams/*bam | sed 's/\//\'$'\t/g' | cut -f 3| sed 's/.bam//g' |sed 's/_filt//g'|  while read -r LINE

do

angsd -i ../final_bams/${LINE}_filt.bam -ref $REF -anc $REF -dosaf 1 -minQ 35 -GL 2 -P 20 -out ${OUTDIR}/${LINE} 

/depot/fnrdewoody/apps/angsd/misc/realSFS -P 20 -fold 1 ${OUTDIR}/${LINE}.saf.idx > ${OUTDIR}/${LINE}_est.ml

done

#Get individual SFS:
cat ./*ml

#Use Excel to calculate proportion of heterozygotes, then import file:

#Import into R
het_pupfish <- read_excel("het_pupfish.xlsx")
#Assign factor
het_pupfish$pop <- factor(het_pupfish$pop , levels=c("MS","SC", "LR"))
#plot
ggplot(het_pupfish,aes(x=pop,y=het,fill=pop))+geom_boxplot(show.legend =FALSE)+scale_fill_manual(name="pop", values =c("SC"="black","LR"="black","MS"="darkgrey"))+xlab("")+ylab("Individual Heterozygosity")+theme_classic()
#produce plot
ggsave("Figure_2.svg")
