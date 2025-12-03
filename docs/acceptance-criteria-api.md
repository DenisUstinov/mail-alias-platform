# Критерии приёмки: [issue #42](https://github.com/DenisUstinov/mail-alias-platform/issues/67) — Сервис API для управления алиасами

## Контекст

Сервис предоставляет возможность создание и удаление почтовых алиасов поверх внешнего почтового провайдера.
Источник истины — локальная БД.
`target_email` пользователь задает как логин при регистрации и изменяет **в внешнем сервисе авторизации**.
Наш сервис получает `target_email` из JWT и использует его для всех алиасов пользователя.

## Область применения

Включено:

* Создание алиаса.
* Удаление алиаса.
* Получение списка алиасов.
* Асинхронная интеграция с провайдером.
* Идемпотентность создания.

Исключено:

* Управление `target_email`.
* Управление доменами.
* Несколько target email.
* Массовые операции.
* UI.

## API-контракт

### 1. `POST /v1/aliases`

Тело запроса:

```json
{ "local_part": "shop" }
```

Заголовки:

```
Idempotency-Key: <uuid> (необязательно)
```

Коды:

* `201 Created` — алиас создан сразу
* `202 Accepted` — операция поставлена в очередь
* `400 Bad Request` — ошибка валидации
* `409 Conflict` — алиас уже существует

---

### 2. `GET /v1/aliases`

Тело ответа:

```json
{
  "items": [
    { "alias_id": 1, "local_part": "shop", "email": "shop@example.com", "status": "pending" },
    { "alias_id": 2, "local_part": "blog", "email": "blog@example.com", "status": "active" },
    { "alias_id": 3, "local_part": "shop2", "email": "shop2@example.com", "status": "error" },
    { "alias_id": 4, "local_part": "news", "email": "news@example.com", "status": "deleting" }
  ],
  "total": 4
}
```

Коды:

* `200 OK` — успешный возврат списка алиасов
* `401 Unauthorized` — нет авторизации

---

### 3. `DELETE /v1/aliases/{alias_id}`

Коды:

* `202 Accepted` — удаление инициировано, алиас в состоянии `deleting`
* `404 Not Found` — алиас не найден
* `401 Unauthorized` — нет авторизации
* `403 Forbidden` — попытка удалить чужой алиас

## Правила валидации

* `local_part`: `/^[a-z0-9._%+-]{1,64}$/i`
* `local_part` должен быть уникален для одного пользователя. Повторная попытка создать алиас с тем же `local_part` приведёт к конфликту.
* Полный email формируется как `{local_part}@example.com`
* Алиас уникален по полю `email`
* `target_email` обязателен — берётся из JWT, не из API
* > > > > > `local_part` не может быть пустым (иначе 400 Bad Request)

## Переходы состояний

Alias:

* `pending` → `active`
* `pending` → `error`
* `active` → `deleting` → `deleted` — внутреннее состояние после физического удаления

Events:

* `pending` → `processing` → `done`
* `pending` → `processing` → `error` — события фильтруются по пользователю через `aliases.user_id`

## Ошибки

Формат:

```json
{ "detail": "..." }
```

Коды:

* 400 — ошибка валидации
* 401 — нет авторизации
* 403 — попытка доступа к чужим ресурсам
* 404 — алиас не найден
* 409 — алиас уже существует

## Минимальная модель БД

### `users`

* `id` PK
* `external_subject` text unique (sub из JWT)
* `target_email` text — хранится для кэширования/удобства, берётся из JWT
* `created_at`, `updated_at`

### `aliases`

* `id` PK
* `user_id` FK
* `local_part` text
* `email` text unique
* `status` enum(`pending`, `active`, `error`, `deleting`, `deleted`)
* `idempotency_key` text nullable — уникальность Idempotency-Key должна быть гарантирована на уровне пользователя
* `created_at`, `updated_at`

### `alias_events`

* `id` PK
* `alias_id` FK
* `op_type` enum(`create`, `delete`)
* `status` enum(`pending`, `processing`, `error`, `done`)
* `attempts` int
* `last_error` text
* `payload` jsonb
* `created_at`

## Политика хранения и удаления

* Алиасы удаляются физически (soft delete не используется).
* Все события (alias_events) сохраняются навсегда для аудита и отладки.
* TTL на pending/error не применяется в MVP.

## Безопасность

* Авторизация: `Bearer <access_token>` (JWT)
* `target_email` берётся из claims токена
* Роли:

  * `user` — управляет только своими алиасами
  * `admin` — полный доступ

## Тесты приёмки (сценарии)

1. **Создание алиаса**

   * POST `/v1/aliases`
   * В БД появляется запись `pending`
   * В очередь отправляется задача `create`
   * После обработки — статус `active`

2. **Идемпотентность**

   * Два POST с одинаковым Idempotency-Key
   * Ожидаем один и тот же `alias_id`

3. **Получение списка**

   * GET `/v1/aliases`
   * Возвращает алиасы конкретного пользователя

4. **Удаление**

   * DELETE `/v1/aliases/{id}`
   * Статус → `deleting`
   * После выполнения — `deleted`

## Нефункциональные требования

* Метрики (Prometheus format):

  * aliases_create_attempts_total — количество попыток создания алиасов
  * aliases_create_failures_total — количество ошибок при создании
  * aliases_provider_errors_total — ошибки провайдера
  * aliases_queue_depth — глубина очереди Celery

* SLA: асинхронная операция ≤ N попыток с backoff

## Примечания / открытые вопросы

* Нужно ли хранить историю всех событий?
* Нужен ли soft delete?
* Нужно ли TTL на pending/error?
