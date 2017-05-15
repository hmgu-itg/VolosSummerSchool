#!/bin/bash

# $1 is sample size of group1
# $2 is samples size of group2

s1=$(( $1 - $3 ))
s2=$(( $2 - $3 ))
ovlp=$3
maf=$4
effect=$5
total=$(( s1 + $(( s2 + ovlp )) ))
# $6
#chr=$7

#kg=/lustre/scratch113/teams/zeggini/ReferenceData/1kg/Phase3_May.15/ALL.chr11.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
#kg=/nfs/humgen01/projects/t144_usoc/Coreexome/v1.0/Final_QCed_data/UKHLS_coreex_usgwas_20131119.gencall.smajor_strandupdated_PARupdated_9965samples_525314SNPs_QC
kg=/lustre/scratch113/projects/t144_gomap/Simulations_Jun16_SH/1KG/chr21-22.EUR.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.quallt32k
plink="plink --memory 1000"

# echo "Simulating $s1 and $s2 individuals with $ovlp overlap (total $total)."

## generate random sets of samples for each group
# cut -f1 -d' ' $kg.fam | shuf > samples.rnd
# head -n $s1 samples.rnd > group1
# tail -n +$(( $s1 + 1 )) samples.rnd | head -n $s2 > group2
# tail -n +$(( $s1 + $(( $s2 + 1 )) )) samples.rnd | head -n $ovlp > overlap


# report MAF
$plink --bfile $kg --chr 1-22 --allow-no-sex --freq --out group1
#$plink --bfile $kg --chr 1-22 --allow-no-sex --keep <(paste <(cat group1 overlap) <(cat group1 overlap)) --out group1 --make-bed --freq
#$plink --bfile $kg --chr 1-22 --allow-no-sex --keep <(paste <(cat group2 overlap) <(cat group2 overlap)) --out group2 --make-bed --freq

# select effect SNP
maxvar=$(sort -k2,2 group1.frq | awk -v f=$maf '$5>f*0.98 && $5<f*1.02 && $10>f*0.98 && $10<f*1.02' | wc -l)
join -j2 <(sort -k2,2 group1.frq) <(sort -k2,2 group2.frq) | awk -v f=$maf '$5>f*0.98 && $5<f*1.02 && $10>f*0.98 && $10<f*1.02' | head -n $6 | tail -n1 > causal.snp
echo "Selected $(cat causal.snp) out of $maxvar SNPs"

# extract snp from whole dataset
$plink --bfile $kg --keep <(paste <(cat group1 group2 overlap) <(cat group1 group2 overlap)) --snp $(cut -f1 -d' ' causal.snp) --recode 01 --output-missing-genotype '.'
count=$(awk 'OFS="\t"{print $1, $1, $8+$7}' plink.ped | cut -f3 | paste -sd+ | bc) # allele counts for each sample
echo COUNT=$count

# flip allele if necessary
if [ $count -gt $total ]
        then
                awk 'OFS="\t"{print $1, $1, 2-($8+$7)}' plink.ped > pheno.all
        else
                awk 'OFS="\t"{print $1, $1, $8+$7}' plink.ped > pheno.all
        fi

# Simulate phenotype
Rscript --vanilla <(echo 'd=read.table("pheno.all");d$V3[d$V3!=0]='$effect'*d$V3[d$V3!=0]+rnorm(length(d$V3[d$V3!=0]));d$V3[d$V3==0]=rnorm(length(d$V3[d$V3==0]));options(width=1000);d;') |cut -d' ' -f2- | tail -n+2 | sed -r 's/^\s+//;s/ +/ /g' > pheno.all.real

# Add phenotype to groups, delete groups
$plink --pheno pheno.all.real --allow-no-sex --bfile group1 --make-bed --out group1.pheno --assoc
$plink --pheno pheno.all.real --allow-no-sex --bfile group2 --make-bed --out group2.pheno --assoc
grep -v NA group2.pheno.qassoc > t
mv t group2.pheno.qassoc
join -j2 <(tail -n+2 group2.pheno.qassoc | sort -k2,2) <(sed 's/ \+/\t/g;s/^\t//g' group2.frq | tail -n+2 | sort -k2,2) | sort -k2,2n -k3,3n | sed 's/  / /g'> group2.pheno.merged
grep -v NA group1.pheno.qassoc > t
mv t group1.pheno.qassoc
join -j2 <(tail -n+2 group1.pheno.qassoc | sort -k2,2) <(sed 's/ \+/\t/g;s/^\t//g' group1.frq | tail -n+2 | sort -k2,2) | sort -k2,2n -k3,3n | sed 's/  / /g'> group1.pheno.merged

mv group1.pheno.qassoc group1.qassoc
mv group2.pheno.qassoc group2.qassoc


sed -r -i 's/^ +//;s/ +/\t/g' group1.qassoc
sed -r -i 's/^ +//;s/ +/\t/g' group2.qassoc

