sudo rm -r ../users/*
docker-compose down
docker-compose up -d --build
sudo chmod 755 -R users
docker-compose logs
