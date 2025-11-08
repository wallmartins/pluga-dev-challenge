up:
	docker compose up

build:
	docker compose up --build

down:
	docker compose down -v

restart:
	docker compose down && docker compose up --build

logs:
	docker compose logs -f

test:
	docker compose exec backend bundle exec rspec

test-coverage:
	docker compose exec backend bundle exec rspec --format progress

test-spec:
	docker compose exec backend bundle exec rspec $(SPEC)

server-shell:
	docker compose exec backend bash
