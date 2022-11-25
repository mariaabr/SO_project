#!/bin/bash

# case $# in
#     0)
#         echo "Please insert some arguments"
#         ;;
#     *)
#         echo "coisas"
#         ;;
# esac

# echo [0-9]

cd /proc
for proc in $(ls | grep -E '^[0-9]+$'); do
    # pid=$(cat $entry/status | grep -w Pid | tr -dc '0-9')

    printf "%d -> o valor do proc (pid) \n" "$proc"

    cd /proc/$proc
    comm=$(cat comm)
    printf "%s -> o valor do comm \n" "$comm"

	userproc=$(ls -ld | awk '{print $3}')
	printf "%s -> o valor do user \n" "$userproc"
done
cd

# for processos in $pid ;do
# 	if [ -d  $processos ];then
# 		cd ./$processos
# 		if [ -r ./io ];then
# 			rchar=$(cat /proc/$processos/io | grep rchar |   grep -o -E '[0-9]+'  )
# 			wchar=$(cat /proc/$processos/io | grep wchar |  grep -o -E '[0-9]+'  )
#             # temp_r[$processos]=$rchar 
#             # temp_w[$processos]=$wchar 

# 			printf "%d -> o valor do rchar \n" "$rchar"
#             printf "%d -> o valor do wchar \n" "$wchar"
# 		fi
# 		cd ../
# 	fi
# done


# for process in $pid; do
#     echo $process # -> processos listados!!!
#     if [ -f $process/comm ]; then # -f is a test command that will check if the file exists
#         # if [ -d $process ]; then # -d check if the directory exists or not
#         echo "estás aqui, patinho lindinho?"

#         if [ -f $process/io]; then
#             if [ -r $process/status && -r $process/io]; then
#                 rchar = $(cat /proc/$process/io | grep rchar | grep -o -E '[0-9]+') # "|" pipe chains commands together -> takes the output from one command and feeds it to the next as input
#                 wchar = $(cat /proc/$process/io | grep wchar | grep -o -E '[0-9]+')
                
#                 echo "estás aqui, patinho?"
#                 printf "%d -> o valor do rchar \n" "$rchar"
#                 printf "%d -> o valor do wchar \n" "$wchar"

#                 # arrread[$process] = $rchar
#                 # arrwrite[$process] = $wchar
#             fi
#         fi
#     fi
# done