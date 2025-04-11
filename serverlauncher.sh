target=$1

case $target in

"axum")
  cd ~/project/axum_app && cargo run --release
  ;;
"asp.net")
  cd ~/project/dotnet_app && dotnet run
  ;;
"express")
  cd ~/project/express_app && pm2 start index.js
  ;;
"gin")
  cd ~/project/gin_app && go run .
  ;;
"stopexpress")
  pm2 kill
  ;;
*)
  echo "Usage: runserver [asp.net | axum | express | gin | stopexpress]"
  exit
  ;;

esac
