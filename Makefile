build:
	go build -o bin/mgmt-server api/main.go

run:
	export PORT=8080
	go run api/main.go