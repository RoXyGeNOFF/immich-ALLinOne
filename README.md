# Immich One‑Minute Setup

Готовый репозиторий для установки **Immich** за ~1 минуту одним скриптом на Linux / Docker Desktop.
Базируется на официальной документации Immich (Docker Compose — Recommended).

## Быстрый старт
```bash
# 1) Распакуйте zip, зайдите в папку репозитория
cd immich-one-minute-setup

# 2) Запустите установку (потребуются права sudo, если docker требует их)
./install-immich.sh

# 3) Откройте в браузере (после запуска контейнеров):
#    http://<IP-сервера>:2283
# Первый зарегистрированный пользователь станет админом.
```

> Скрипт сам скачает **docker-compose.yml** и **.env** из последних релизов Immich, заполнит минимальные переменные,
> подставит ваш часовой пояс, и запустит `docker compose up -d`.
> Docker/Compose должны быть установлены заранее (как в оф. документации).

## Что делает скрипт
- Проверяет наличие `docker` и `docker compose`.
- Создаёт рабочую директорию `immich-app`.
- Скачивает последнюю версию `docker-compose.yml` и пример `.env` из GitHub релизов Immich.
- Заполняет `.env`: 
  - `UPLOAD_LOCATION=./library` (можно изменить),
  - `DB_DATA_LOCATION=./postgres`,
  - генерирует случайный `DB_PASSWORD` (A–Z, a–z, 0–9),
  - устанавливает `IMMICH_VERSION=release`,
  - проставляет `TZ` из `/etc/timezone` (если доступен) иначе `Europe/Berlin`.
- Запускает Immich в фоне: `docker compose up -d`.
- Печатает URL панели: `http://<IP>:2283` и путь к данным.

## Донат (QR)
Разместите ваш QR‑код в `assets/donate-qr.png`. Он уже подключён в README ниже:

![Donate QR](assets/donate-qr.png)

Если файла нет, картинка просто не отобразится. После того как отправите мне QR‑код, я обновлю архив (или замените файл сами).

## Полезные команды
```bash
# Остановить
docker compose -f immich-app/docker-compose.yml down

# Обновить до последнего релиза Immich
cd immich-app && docker compose pull && docker compose up -d

# Посмотреть логи
docker compose -f immich-app/docker-compose.yml logs -f --tail 200
```

## Лицензия
MIT. Файлы `docker-compose.yml` и `.env` **не хранятся** в репозитории — они скачиваются из официальных релизов Immich.
