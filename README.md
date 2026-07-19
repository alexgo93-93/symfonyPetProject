# Symfony Pet Project

Веб-приложение на Symfony с Docker-окружением (PHP-FPM, Nginx, PostgreSQL) и multistage-сборкой.

---

## Требования

- Docker 24.0+
- Docker Compose v2
- Git
- Make (опционально, для удобства)

---

## Быстрый старт (5 минут)

```bash
# 1. Клонируем репозиторий
git clone <url-репозитория>
cd symfony_pet_project

# 2. Создаём .env из примера
cp .env.example .env

# 3. Редактируем .env (меняем пароли, порты если нужно)
nano .env

# 4. Запускаем проект
make dev

# 5. Открываем в браузере
# http://localhost:8080/health