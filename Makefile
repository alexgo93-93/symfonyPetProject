.PHONY: dev prod down bash db logs clear

dev:
	USER_ID=$$(id -u) GROUP_ID=$$(id -g) docker compose up -d --build

prod:
	USER_ID=$$(id -u) GROUP_ID=$$(id -g) docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

down:
	docker compose down

bash:
	docker compose exec php bash

db:
	docker compose exec postgres psql -U ${POSTGRES_USER:-symfony} -d ${POSTGRES_DB:-symfony}

logs:
	docker compose logs -f

clear:
	docker compose exec php php bin/console cache:clear