#!/bin/bash

cat alldata.txt | sed 's/.*\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\),\([0-9]\{2\}\)|\([0-9]\{2\}\).*/\1,\2,\3,\4,\5,\6/g'>tmpdata
BALLNUM=6
tac tmpdata|
awk 'BEGIN{
    BALLNUM=6
    TOTAL=33
    FS=",";
    for(pos=0;pos<BALLNUM;pos++)
    {
        for(i=0;i<TOTAL;i++)
        {
            for(j=0;j<TOTAL;j++)
            {
                markovTrans[pos][i][j]=0;
            }
        }
    }
    
    getline;
    for(j=0;j<BALLNUM;j++)
    {
        getdataArrayOne[j]=strtonum($(strtonum(j)+1));
        #printf("%d \n", strtonum($(strtonum(j)+1)));
        #printf("%d ", getdataArrayOne[j]);
    }
}
{
    for(j=0;j<BALLNUM;j++)
    {
        getdataArrayTwo[j]=strtonum($(strtonum(j)+1));
        #printf("%d ", $j);
        #printf("%d ", getdataArrayTwo[j]);
    }
    #printf("\n");
    RELEVENT=1
    if(RELEVENT==0)
    {
        for(i=0;i<BALLNUM;i++)
        {
            markovTrans[i][getdataArrayOne[i]-1][getdataArrayTwo[i]-1]++;
        }
    }
    else
    {
        for(pos=0;pos<BALLNUM;pos++)
        {
            for(cor=0;cor<BALLNUM;cor++)
            {
                markovTransCor[pos][cor][getdataArrayOne[(pos+cor)%BALLNUM]-1][getdataArrayTwo[pos]-1]++
            }
        }
    }

    for(j=0;j<BALLNUM;j++)
    {
        getdataArrayOne[j]=$(strtonum(j)+1);
    }
}
END{
    #for(j=0;j<TOTAL;j++)
    #{
        #printf("%2d ",j);
    #}

    "sed '4'q tmpdata|grep .*,.*,.*,.*,.*,.*"|getline oneline; 
    #printf("oneline: %s", oneline);
    split(oneline, ballsArray, ","); 
    #printf("ballsArray: %s\n", ballsArray[1]);
    if(1==RELEVENT)
    {
        for(pos=0;pos<BALLNUM;pos++)
        {
            for(i=0;i<TOTAL;i++)
            {
                for(j=0;j<TOTAL;j++)
                {
                    markovTrans[pos][i][j] = 0;
                    for(k=0;k<BALLNUM;k++)
                    {
                        markovTrans[pos][i][j]+=markovTransCor[pos][k][i][j];
                    }
                    #markovTrans[pos][i][j] = markovTransCor[pos][0][i][j]+markovTransCor[pos][1][i][j]+markovTransCor[pos][2][i][j];
                    #printf("%d ", markovTrans[pos][i][j]);
                }
                #printf("\n");
            }
           #printf("\n\n");
        }
       
    }    
    for(i=0;i<TOTAL;i++)
    {
        for(j=0;j<TOTAL;j++)
        {
            decisionArray[i][j] = 0;
            for(pos=0;pos<BALLNUM;pos++)
            {
                decisionArray[i][j]+=markovTrans[pos][i][j]
            }
            #printf("%d ", decisionArray[i][j]);
        }
        #printf("\n");
    }
      
    
    for(i=0;i<TOTAL;i++)
    {
        for(pos=0;pos<BALLNUM;pos++)
        {
            printf("%d:%d ",decisionArray[ballsArray[pos+1]-1][i],i+1);
        }
        #print sortedDecesion
        printf("\n");
    }
    
    #printf("total: %d\n", NR);
}'>transPro.data

for i in {1..7}
do
    sort -nrk $[i] transPro.data |cut -d" " -f$[i] >$[2+i]
done
paste 3 4 5 6 7 8| head -5>selection.data

for i in {1..6}
do
    cat selection.data |cut -f$[i] |cut -d":" -f2 >$[2+i]
done
cat 3 4 5 6 7 8 |sort -nr|uniq -c  |sort -nr

