#!/bin/sh

for i in {1..1000}
do
echo -e "1 \ncheck.txt \n,..$i.., \n2" | ./a.out
sleep .5
done
