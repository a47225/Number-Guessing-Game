#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_GUESS() {
  echo -e "\nEnter your username:"
  read USERNAME
  USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
  NUMBER_TO_GUESS=$((RANDOM % 1000 + 1))
  NUMBER_OF_GUESSES=0
  if [[ -z $USERNAME_RESULT ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    GAME
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
    echo -e "\nWelcome back, $USERNAME_RESULT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    GAME
  fi
}

GAME(){
  if [[ $NUMBER_OF_GUESSES -lt 1 ]]
  then
    echo -e "\nGuess the secret number between 1 and 1000:"
    READ_INPUT_AND_PLAY
  else
    if [[ $NUMBER_INPUT -eq $NUMBER_TO_GUESS ]]
    then
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
      if [[ -z $USERNAME_RESULT ]]
      then
        INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME',1,$NUMBER_OF_GUESSES)")
      else
        if [[ $BEST_GAME -ge $NUMBER_OF_GUESSES ]]
        then
          BEST_GAME=$NUMBER_OF_GUESSES
        fi
        UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED + 1, best_game=$BEST_GAME WHERE username='$USERNAME'")
      fi
    elif [[ $NUMBER_INPUT -lt $NUMBER_TO_GUESS ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      READ_INPUT_AND_PLAY
    else
      echo -e "\nIt's lower than that, guess again:"
      READ_INPUT_AND_PLAY
    fi
  fi
}

READ_INPUT_AND_PLAY(){
  read NUMBER_INPUT
  if [[ ! $NUMBER_INPUT =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    READ_INPUT_AND_PLAY
  else
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
    GAME
  fi
}

NUMBER_GUESS