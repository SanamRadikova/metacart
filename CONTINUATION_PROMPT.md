# 📋 ПРОМПТ ДЛЯ НОВОГО ЧАТА — Продолжение гармонизации спецификаций MetaCart

Скопируйте текст ниже, начиная с `---` и до конца, и вставьте в новый чат.

---

## Контекст проекта

Я разрабатываю проект **MetaCart** — мобильное приложение (Flutter) + бэкенд (Go) + PostgreSQL/Supabase. Это превентивный нутрициологический движок, который берёт биомаркёры пользователя (анализы крови + данные носимых устройств), определяет его метаболический профиль и формирует персонализированное 7-дневное меню + продуктовую корзину.

**Рабочая директория:** `c:\Users\sanam\Desktop\metaCart\metacart`

**Стек:**
- Backend: Go (modular monolith, разрабатывается отдельно, потом будет отдельный репо)
- Frontend: Flutter (mobile, будет отдельный репо)
- DB: PostgreSQL 15 на Supabase + native range partitioning
- API: OpenAPI YAML (будет создаваться по факту реализованных endpoints)

**Стратегия разработки (утверждённая):**
1. Согласовать и исправить неточности в требованиях, архитектуре и формулах + соответствие между `use_cases.md` ↔ `detailed_screen_specs.md`
2. Разработка бэка с unit-тестами + Postman; swagger.yaml **генерируется по факту реализованных endpoints** (не выдумывается заранее)
3. Фронт использует swagger.yaml как контракт

---

## Что уже сделано в предыдущей сессии

### Фаза A: `docs/decisions.md` — ЗАВЕРШЕНА ✅
- **ADR-011** обновлён: устаревшие ссылки `E10a/E10b` → `E22/E23` (замечание ревьюера #1)
- **ADR-018** помечен как TBD, добавлена секция "Consistency note" с обеими формулами GSS (простая и со штрафом) и рекомендацией добавить `formula_version` в `drift_analyses`

### Фаза B: `specs/requirements/use_cases.md` — ЗАВЕРШЕНА ✅
- 2 случая **ADR-019 → ADR-018** (формула GSS) исправлены
- 1 случай **ADR-010 → ADR-009** (soft-delete в UC-50) исправлен

### Фаза C: `specs/requirements/detailed_screen_specs.md` — 3 из 9 правок ✅
- **C.1 (E7)**: hormonal status enum → `follicular` / `pms` / `perimenopause` / `postmenopause` / `not_applicable` (short codes по UC-15)
- **C.3 (E22)**: упрощена confidence scoring — только 🟢≥0.7 и 🔴<0.7 (убран средний уровень)
- **C.4 (E19)**: добавлена кнопка "Use receipt photo instead" → E21 (по UC-29 A1)

---

## Что осталось сделать (12 пунктов в 4 фазах)

### Фаза C (6 оставшихся правок в `detailed_screen_specs.md`)

**C.2 (E10: Profile Result)** — уточнить Profile 5 trigger через symptoms:
- Сейчас в use_cases.md (UC-18): "Axis 5 = 🟠 OR SDNN paradox OR dG/dt < -0.7 with symptoms OR hormonal modifier + HRV <35"
- В detailed_screen_specs.md сейчас размыто. Привести к точному виду из UC-18.
- **Действие:** в секции "Profile Selection Logic" в E10 добавить bullet-point список 4 условий.

**C.5 (E25: Drift Dashboard empty state)** — обновить текст:
- В use_cases.md (UC-39 A1): "Capture your first purchase to see drift"
- В detailed_screen_specs.md E25: другой текст. Привести к use_cases.

**C.6 (E1: Splash Screen onboarding resume)** — добавить описание:
- В use_cases.md (UC-03): "Redirect to Home or resume onboarding"
- В detailed_screen_specs.md E1 нет упоминания onboarding resume. Добавить в секцию "User Flow" строку: "If authenticated AND onboarding_completed = false → redirect to first incomplete step (E2 → E3 → E4 → ...)"

**C.7 (E4a: OCR Review)** — добавить warning banner для диабета:
- В use_cases.md (UC-09 A2): "Your results indicate diabetes. MetaCart is a preventive tool, not a treatment. Please consult your doctor."
- В detailed_screen_specs.md E4a этого нет. Добавить в Error States новую строку:
  | Value indicates diabetes (glucose ≥126, HbA1c ≥6.5%) | "Your results indicate diabetes. MetaCart is a preventive tool, not a treatment. Please consult your doctor." User can still explore app but cannot participate in pilot. |

**C.8 (E35: Account Management)** — добавить `POST /api/v1/account/delete`:
- В use_cases.md (UC-53): hard-delete через 7 лет, только admin
- В detailed_screen_specs.md E35 нет упоминания. Добавить в секцию "Key Architectural Decisions" строку: "Hard delete is NOT available in the mobile app — it happens only after the 7-year IRB retention period via the `POST /api/v1/account/delete` endpoint, accessible only by support staff, not via the mobile app."

**C.9 (E17: Recipe Detail)** — убрать отдельный endpoint или объединить:
- В detailed_screen_specs.md E17 есть `GET /api/v1/recipes/{recipe_id}`
- В архитектуре: recipe data должна быть в `GET /api/v1/menu/week` response
- **Решение:** в E17 в секции "API Calls" изменить:
  - БЫЛО: "Primary: `GET /api/v1/recipes/{recipe_id}`"
  - СТАЛО: "Recipe data is included in `GET /api/v1/menu/week` response (each meal has a `recipe` nested object with full details). E17 reads from local cache populated by the menu response — no additional API call needed."

### Фаза D: `specs/requirements/complete_screen_list.md` — дополнить таблицу трассировки

Таблица трассировки US → Screens в конце файла (строки ~567-598) **НЕПОЛНАЯ** (замечание ревьюера #2). Покрывает только 28 user stories из 56. Нужно добавить:

| User Story | Screens Covered |
|------------|-----------------|
| US-08 (Normalize units) | E4a (lab values normalized automatically) |
| US-09 (Validate labs) | E4a (validation messages) + E4b (range check) |
| US-11 (Edit cultural) | E5 (edit mode) + E32 (Settings tile) |
| US-14 (Sync device data) | backend only — no screen |
| US-16 (Update hormonal) | E7 (edit mode) + E32 |
| US-21 (View modifiers) | E11 (section in E10) |
| US-22 (Generate menu) | E13 (auto-generated, no user action) |
| US-25 (Household size) | E14 |
| US-27 (View cart) | E15 |
| US-31 (Match purchases) | backend only — auto |
| US-32 (Purchase summary) | E24 |
| US-35 (Retry OCR) | E22 (retry button) + E21 |
| US-36 (Fallback manual) | E21 ("Enter Manually" link) |
| US-37 (OCR History) | E19 (recent purchases list) |
| US-38 (Compute Drift Score) | backend only — auto |
| US-41 (Drift Trends) | E27 |
| US-42 (Drift Insights) | E28 |
| US-43 (HRV Morning Alert) | push notification (E29 pattern) |
| US-44 (Meal Reminder) | push notification (E29 pattern) |
| US-45 (Post-Dinner Walk) | push notification (E29 pattern) |
| US-49 (Profile Change Notif) | E31 (push notification) + E30 |
| US-52 (Reactivate) | E2 (sign-in flow) + E35 (info) |
| US-53 (Hard delete) | admin only — not in app |
| US-56 (Extended mode) | E8 (data completeness indicator) |

**Действие:** заменить существующую таблицу на полную. Добавить столбец "Notes" где уместно (например, "backend only", "admin only").

### Фаза E: `db/schema.sql` + `specs/DATABASE.md`

**E.1:** Добавить `users.is_participant BOOLEAN NOT NULL DEFAULT FALSE`:
- В `db/schema.sql` найти секцию `users` и добавить строку после `onboarding_completed`:
  ```sql
  is_participant BOOLEAN NOT NULL DEFAULT FALSE,  -- TRUE if user signed research_consent
  ```
- В `specs/DATABASE.md` обновить документацию таблицы `users` — добавить описание этого поля.

**E.2:** Добавить `users.onboarding_step SMALLINT NOT NULL DEFAULT 0`:
- В `db/schema.sql` найти секцию `users` и добавить строку:
  ```sql
  onboarding_step SMALLINT NOT NULL DEFAULT 0,  -- 0=not started, 1=registered, 2=consent, 3=labs, 4=cultural, 5=devices, 6=hormonal, 7=completed
  ```
- В `specs/DATABASE.md` обновить документацию.

**E.3:** Расширить `cultural_profiles.primary_culture` CHECK:
- В `db/schema.sql` найти CHECK constraint для `primary_culture` и добавить значение `'other'` в список
- В `specs/DATABASE.md` обновить документацию.

### Фаза F: `docs/rules.md` — добавить 3 новых раздела

**F.1: Раздел "Contract Truth: swagger.yaml"**
```markdown
## 📜 Contract Truth: swagger.yaml

**Файл:** `packages/shared/openapi/metacart-api.yaml`

**Правило:**
1. `specs/requirements/detailed_screen_specs.md` и `specs/requirements/use_cases.md` — это human-readable спецификации.
2. `swagger.yaml` — это MACHINE-READABLE контракт между бэком и фронтом.
3. `swagger.yaml` создаётся и обновляется **только на основе реализованных endpoints** в коде.
4. Workflow: код бэка → автогенерация/ручное обновление swagger.yaml → фронт читает swagger.yaml.
5. **Никаких выдуманных endpoints** в swagger.yaml — каждый endpoint должен иметь реальную реализацию в Go-коде.
```

**F.2: Раздел "swagger.yaml Update Process"**
```markdown
## 🔄 swagger.yaml Update Process

При добавлении/изменении endpoint в Go-коде:
1. Реализовать handler в `apps/api/internal/handlers/...`
2. Добавить/обновить endpoint в `packages/shared/openapi/metacart-api.yaml`
3. Обновить DTOs (генерируются из yaml)
4. Скопировать обновлённый yaml в `packages/shared/openapi/` (если он находится в другом месте)
5. Коммитнуть оба файла вместе (handler + yaml) — **никогда один без другого**
6. При релизе бэка — зафиксировать версию yaml (например, через git tag)
```

**F.3: Раздел "Spec ↔ Code Sync Rules"**
```markdown
## 📝 Spec ↔ Code Sync Rules

- При **обнаружении противоречия** между use_cases.md / detailed_screen_specs.md / кодом:
  1. Если код готов — обновить спецификации (use_cases.md + detailed_screen_specs.md)
  2. Если спецификации актуальны — обновить код
  3. Нельзя оставлять расхождения в долг — баг создаётся в трекере
- **Source of truth** (в порядке приоритета при разработке):
  1. Код (если реализован)
  2. use_cases.md (если код не реализован, но use case описан)
  3. detailed_screen_specs.md (если ничего не реализовано)
- При **изменении endpoint** в спеке — обязательно обновить все 3 источника в одном PR
```

---

## Ключевые файлы для чтения

Перед началом работы прочитай:
1. `docs/decisions.md` — все ADR (особенно ADR-009, ADR-011, ADR-012, ADR-018)
2. `specs/requirements/use_cases.md` — особенно UC-09, UC-18, UC-29, UC-39, UC-50, UC-53
3. `specs/requirements/detailed_screen_specs.md` — особенно E1, E4a, E10, E17, E19, E25, E35
4. `specs/requirements/complete_screen_list.md` — строки 565-598 (таблица трассировки)
5. `db/schema.sql` — секции `users` и `cultural_profiles`
6. `docs/rules.md` — текущая структура (для понимания куда вставлять новые разделы)

---

## Приоритеты выполнения

1. **СНАЧАЛА** прочитай все 6 файлов выше (это критично для понимания контекста)
2. **ЗАТЕМ** выполни правки в порядке: Фаза C → Фаза D → Фаза E → Фаза F
3. **В ФАЗЕ C** — после каждой правки проверяй через `search_files` что ADR-номера в файле консистентны с `decisions.md`
4. **В ФАЗЕ D** — будь внимателен, замена всей таблицы может быть большой. Используй `read_file` чтобы увидеть точную структуру существующей таблицы перед заменой
5. **В ФАЗЕ E** — `db/schema.sql` большой, используй `search_files` чтобы найти точные места вставки перед `replace_in_file`
6. **В ФАЗЕ F** — `docs/rules.md` может быть структурирован по секциям. Добавь новые разделы в конец файла с разделителем `---`

---

## Важные правила

1. **НЕ ТРОГАЙ** уже изменённые места (Phase A, B, C.1, C.3, C.4 уже применены)
2. **НЕ ВЫДУМЫВАЙ** новые формулы или API endpoints — используй только то, что описано в use_cases.md и architecture
3. **ВСЕГДА** ссылайся на существующие артефакты (use_cases.md, decisions.md, DATABASE.md) в комментариях
4. **НЕ ПЕРЕВОДИ** ADR номера которые я тебе даю — они уже финальные
5. **НЕ ТРОГАЙ** файлы `data_seed.sql`, `MetaCart Developer Architecture FINAL.md`, `visual/*.html`, `specs/screens/*` — они вне scope этой гармонизации

---

## Формат отчёта

После каждой фазы выведи краткий итог:
```
✅ Фаза X завершена
- Правка 1: [файл] — [что изменилось]
- Правка 2: [файл] — [что изменилось]
...
```

В конце всех фаз выведи общий summary с подтверждением что ВСЕ 12 пунктов выполнены.

---

Начни с чтения 6 ключевых файлов, затем приступай к Фазе C. Если контекст приближается к 200K токенов — остановись и сообщи о прогрессе (как в предыдущей сессии).