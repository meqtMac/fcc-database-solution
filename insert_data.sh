#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# 清空表
echo $($PSQL "TRUNCATE TABLE games, teams;")

# 读取CSV文件并处理每一行
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # 跳过标题行
  if [[ $year != "year" ]]
  then
    # 获取或插入winner球队
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $winner_id ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$winner') RETURNING team_id"
       winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    fi

    # 获取或插入opponent球队
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $opponent_id ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$opponent') RETURNING team_id"
      opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    
    fi

    # 插入比赛记录
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
  fi
done
