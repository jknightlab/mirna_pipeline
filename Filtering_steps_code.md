# mirna_pipeline
--------------------------------------
Bioinformatic pipeline to analyze micro RNA sequencing data

### Filtering based on coverage and fold change

These are the commands used to filter miRNAs and create
the candidate lists:

```
i="diff_expression_HC_nonTh17_VS_AS_nonTh17.txt"
cat $i | wc -l
cat $i | grep -v NA -c
cat $i | grep -v NA | grep -v Inf -c
cat $i | grep -v NA | grep -v Inf | awk '$6 > 2 {print $0}' > $i.temp
cat $i | grep -v NA | grep -v Inf | awk '$6 < -2 {print $0}' | grep -v fold >> $i.temp
cat $i.temp | wc -l
cat $i.temp | awk '$3 > 5 {print $0}' | wc -l
cat $i.temp | awk '$3 > 5 {print $0}' | awk '$4 > 5 {print $0}' | wc -l

for i in `ls diff_expression_*txt`
do
j=`echo $i | sed s/.*expression/candidates/g`
cat $i | grep -v NA | grep -v Inf | awk '$6 > 2 {print $0}' > $i.temp
cat $i | grep -v NA | grep -v Inf | awk '$6 < -2 {print $0}' | grep -v fold >> $i.temp
cat $i.temp | awk '$3 > 5 {print $0}' | awk '$4 > 5 {print $0}' > $j
echo done for $j
sleep 3
done
```

#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
