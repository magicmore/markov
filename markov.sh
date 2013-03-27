#!/bin/bash

cat expAlldata.txt | sed 's/.*\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\)|\([0-9]\{2\}\).*/\1,\2,\3,\4,\5,\6,\7/g'>tmpdata
cat tmpdata|
awk '
BEGIN{
    FS=",";
    getline;
    getline;
    getline;
    for(j=1;j<34;j++)
    {
        proArray[j]=0;
    }
}
{   
    for(i=1;i<7;i++)
    {
        for(j=1;j<34;j++)
        {
            if(strtonum($i)==j)
            {
            proArray[j]++;
            }
        }
    }
}
END{
    sum=0
    for(j=1;j<34;j++)
    {
        printf("%d ", proArray[j]);
        #sum+=proArray[j];
    }
    #printf("total: %d\n", NR-3);
    #printf("sum:   %d\n", sum);
}
'>./curPro.data



tac tmpdata|
awk 'BEGIN{
FS=",";
    getline;
    for(i=1;i<34;i++)
    {
        for(j=1;j<34;j++)
        {
            markovTrans[i][j]=0;
        }
    }
    getline;
    for(j=1;j<7;j++)
    {
        getdataArrayOne[j]=$j;
        #printf("%d ", $j);
        #printf("%d ", getdataArrayOne[j]);
    }
}
{
    for(j=1;j<7;j++)
    {
        getdataArrayTwo[j]=$j;
        #printf("%d ", $j);
        #printf("%d ", getdataArrayTwo[j]);
    }
    #printf("\n");
    for(i=1;i<7;i++)
    {
        for(j=1;j<7;j++)
        {
            markovTrans[strtonum(getdataArrayOne[i])][strtonum(getdataArrayTwo[j])]++;
        } 
    }
    for(j=1;j<7;j++)
    {
        getdataArrayOne[j]=$j;
    }
}
END{
    #for(j=0;j<34;j++)
    #{
        #printf("%2d ",j);
    #}
    for(i=1;i<34;i++)
    {
        #printf("\n%2d ", i);
        for(j=1;j<34;j++)
        {
            printf("%2d ",markovTrans[i][j]);
        }
        printf("\n");
    }
    #printf("total: %d\n", NR);
}'>transPro.data

#get recent balls
cat tmpdata | sed '1,3'd>3
oldIFS=$IFS
IFS=","
printf "balls \n"
read balls[{0..6}]<3
for i in {0..5}
do  
    echo ${balls[i]}
done
#select current balls' probability
IFS=" "
read orgProArray[{1..33}]<curPro.data
for i in {0..5}    
do
    echo ${orgProArray[balls[i]]}
done
#Copy transfer probability 
IFS=" "
sampleSpan=33
for i in {0..32}
do 
    read marKovTransPro[$[i*sampleSpan+{1..33}]]
done<transPro.data
#Test marKovTransPro
for i in {0..32}
do 
    for j in {1..33}
    do
        printf "%2d " "${marKovTransPro[$[i*sampleSpan+j]]}"
    done
    printf "\n"
done

#Copy selected marKovTransPro
printf "selected\n"
for i in {0..5}
do
    for j in {1..33}
    do
        selectMKTP[$[i*sampleSpan+j]]=${marKovTransPro[$[$[balls[i]-1]*sampleSpan+j]]}
        printf "%d " "${selectMKTP[$[i*sampleSpan+j]]}"
    done
    printf "\n"
done

#Calculate the probability with markovChain
for i in {1..33}
do
    sum=0
    for j in {0..5}
    do
        sum=$[$sum+${orgProArray[balls[j]]}*${selectMKTP[j*sampleSpan+i]}]
        #echo ${orgProArray[balls[j]]}
    done
    choiseProArray[i]=$sum     
done

printf "final choice\n"
for i in {1..33}
do
    printf "%d:%d\n" ${choiseProArray[i]} $i
done>4
sort -t":" -nrk 1 <4 >decision2.txt
   

