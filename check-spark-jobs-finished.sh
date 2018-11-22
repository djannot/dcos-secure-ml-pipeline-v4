seconds=0
OUTPUT=1
sleep 5
while [ "$OUTPUT" -ne 0 ]; do
  OUTPUT=`dcos task | grep -c driver`;
  seconds=$((seconds+5))
  printf "Waiting %s seconds for all the Spark jobs to finish\n" "$seconds"
  sleep 5
done
