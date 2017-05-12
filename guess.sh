#!/bin/bash

clear
rand=$RANDOM

#create score file if it doesn't exist, setting default contents
if [[ ! -f score ]]; then
	echo "0|1" > score
fi

best=$(<score)

#checks if variable best is in the right format, i.e. x|y, where x can be any positive number and y is in the inclusive range of 1-5, resets value if not.
if [[ ! "$best" =~ (^[0-9]+\|[1-5]$) ]]; then
	echo -e "\e[31mThe score file has been altered. Your lowest number of guesses and highest completed difficulty have been reset.\e[0m"
	echo "0|1" > score
	best=$(<score)
fi

#lowest is set to the number before the pipe, highest is set to the number after.
lowest=${best%|*}
highest=${best##*|}

function game {
	echo -e "Your lowest number of guesses is \e[36m$lowest\e[0m, and your highest completed difficulty is \e[36m$highest\e[0m."
	read -p "How difficult would you like the game to be, from level 1-5? (1 = 1-digit random number, 5 = 5-digit random number) " diff
	secret=${rand:0:$diff}
	count=1

	if (($secret < 10000 && $diff == 5))
	then
		rand2=$RANDOM
		secret=$secret${rand2:0:1}
	fi

#	showRandom

	echo
	read -p "Guess a random $diff digit number! " guess
	while [[ $guess != $secret ]]
	do
		((count++))
		if (($guess < $secret))
		then
			echo -n -e "\e[34m$guess\e[0m is \e[31mtoo low!\e[0m Try again! "
			read guess
		else
			echo -n -e "\e[34m$guess\e[0m is \e[31mtoo high!\e[0m Try again! "
			read guess
		fi
	done

	if [[ "$count" -eq "1" ]]
	then
		echo
		echo -e "\e[32mCorrect!\e[0m \e[34m$secret\e[0m was the right number! You got it in \e[96m$count guess\e[0m! How did you know?!"
	else
		echo
		echo -e "\e[32mCorrect!\e[0m \e[34m$secret\e[0m was the right number! It took you \e[96m$count guesses\e[0m! Good job!"
	fi

	#logic for output about their lowest number of guesses and highest difficulty
	if [[ "$count" -eq "$lowest" ]] && [[ "$lowest" -eq "1" ]]
	then
		echo -e "Your lowest number of guesses was already \e[36m1\e[0m. A winner is still you! Try a higher difficulty, or delete the score file."
		echo
	elif [[ "$count" -eq "$lowest" ]] && [[ "$lowest" -ne "1" ]]
	then
		echo -e "Your current number of guesses was tied for your best at \e[36m$count guesses\e[0m. You were so close!"
		echo
	elif [[ "$count" -lt "$lowest" ]] || [[ "$lowest" -eq "0" ]]
	then
		prevlowest=$lowest
		lowest=$count

		if [[ "$prevLowest" -eq "0" ]]; then
			echo -e "You set a new record for the lowest number of guesses at \e[36m$lowest\e[0m!"
		else
			echo -e "You beat your previous record of \e[36m$prevLowest guesses\e[0m! Good job!"
		fi

		if [[ "$highest" -eq "5" ]] && [[ "$lowest" -ne "1" ]]; then
			echo -e "Your highest completed difficulty was already \e[36m5\e[0m. Try to beat your lowest number of guesses on this difficulty."
			echo
		elif [[ "$highest" -eq "5" ]] && [[ "$lowest" -eq "1" ]]; then
			echo -e "Your highest completed difficulty was already \e[36m5\e[0m. You have technically beaten the game! Congratulations!"
			echo
		elif [[ "$diff" -gt "$highest" ]]; then
			prevHighest=$highest
			highest=$diff
			echo -e "You have beaten your previous highest difficulty of \e[36m$prevHighest\e[0m. Your new highest difficulty is \e[36m$highest\e[0m!"
			echo
		fi
		echo "$lowest|$diff" > score
	elif [[ "$count" -gt "$lowest" ]] && [[ "$lowest" -eq "1" ]]
	then
		echo
		echo -e "You did not beat your record of \e[36m$lowest guess\e[0m! Better luck next time!"
		echo
	else
		echo
		echo -e "You did not beat your record of \e[36m$lowest guesses\e[0m! Better luck next time!"
		echo
	fi
}

#Function to show the current Random Number, for testing
function showRandom {
	if (($secret < 10))
	then
		echo "$secret is 1 number long"
	elif (($secret < 100))
	then
		echo "$secret is 2 numbers long"
	elif (($secret < 1000))
	then
		echo "$secret is 3 numbers long"
	elif (($secret < 10000))
	then
		echo "$secret is 4 numbers long"
	elif (($secret < 100000))
	then
		echo "$secret is 5 numbers long"
	fi
}

if [[ -z "$1" ]]; then
	echo
	echo -e "Welcome to my Bash Guessing Game!"
	echo "You will be offered a choice of difficulty from 1-5. The higher the difficulty, the more digits will be in the random number, i.e. Difficuty 1 is a 1-digit number from 1 to 9, but difficulty 5 will be a 5 digit number from 10000 to 99999."	
	echo -e "Your best score (lowest number of guesses), as well as your highest difficulty completed will be stored in a file named 'score'."
	echo
	echo -e "To play the game, type \e[32m./guess.sh play\e[0m. To delete your score file, type \e[31m./guess.sh reset\e[0m."
	echo
else
	if [[ "$1" == "reset" ]]; then
		read -p "Are you sure you want to delete your lowest score and highest difficulty? (y/n) " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			rm score
			echo -e "\e[31mScore file has been deleted.\e[0m"
			echo
		else
			echo -e "\e[32mYour score file has not been deleted.\e[0m"
			echo
		fi
	elif [[ "$1" == "play" ]]; then
		game
	fi
fi
