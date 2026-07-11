# Kyiv Public Transport — Final Project (KSE Probability & Statistics)

Дослідження: чи рівномірно Київ планує розподіл громадського транспорту в часі та між маршрутами/районами. Повний план (гіпотези, ролі, таймлайн) — у `PLAN.md`.

---

## Структура проєкту

```
Project/
├── PLAN.md                  # план: гіпотези, ролі, таймлайн, лінки на дані
├── README.md                # ця інструкція
├── kyiv-transport.Rproj     # відкривати проєкт у RStudio ЧЕРЕЗ ЦЕЙ ФАЙЛ
├── .gitignore
├── 01_data_preparation.qmd  # Quarto: завантаження даних → аналітична таблиця
├── 02_analysis.qmd          # Quarto: EDA → тести H1–H5 → фінальні графіки
├── 03_realtime_bonus.qmd    # Quarto: бонус «план vs факт» на добових GPS
├── R/
│   └── collect_realtime.R   # збирач GPS (нескінченний цикл — тому НЕ Quarto)
├── scripts/
│   └── parse_realtime.py    # конвертація зібраних .pb → один CSV
├── data/
│   ├── raw/                 # сирі дані (завантажені 11.07.2026, закомічені)
│   │   ├── gtfs_kyiv.zip / gtfs/     # GTFS Static
│   │   ├── vehicles_kpt.json         # ТЗ Київпастрансу з місткістю
│   │   ├── vehicles_marshrutky.csv   # ТЗ приватних перевізників
│   │   ├── stops_kpt.json            # зупинки
│   │   └── rt/                       # .pb-знімки GPS (в git НЕ йдуть)
│   └── processed/           # результати обробки (analysis_table.csv тощо)
├── report/                  # фінальний звіт (виросте з 01+02)
└── slides/                  # презентація
```

---

## 0. Що встановити (кожен член команди, один раз)

1. **R** ≥ 4.3: https://cran.r-project.org/
2. **RStudio Desktop** (Quarto йде в комплекті): https://posit.co/download/rstudio-desktop/
3. **Git**: перевір у терміналі `git --version`; на Mac запропонує встановити сам.
4. **Python 3** (тільки тому, хто робить бонус-частину): `python3 --version`.

Потім відкрий `kyiv-transport.Rproj` у RStudio (подвійний клік) і в консолі R:

```r
install.packages(c("tidyverse", "tidytransit", "sf", "lubridate",
                   "jsonlite", "janitor", "here"))
```

`sf` на Mac може попросити систему залежностей — якщо впаде, спочатку в терміналі: `brew install gdal proj geos`, потім повторити.

---

## 1. Git: як отримати проєкт і працювати разом

**Той, хто створює репозиторій (один раз):**

```bash
cd "шлях/до/Project"
git init
git add .
git commit -m "Initial project structure + raw data snapshot 2026-07-11"
git branch -M main
# створи порожній репозиторій на github.com (без README!) і підстав URL:
git remote add origin https://github.com/<нік>/kyiv-transport.git
git push -u origin main
# додай трьох інших: Settings → Collaborators
```

**Решта команди:**

```bash
git clone https://github.com/<нік>/kyiv-transport.git
cd kyiv-transport
```

**Робочий цикл для всіх** (щоб не переписувати одне одному файли — кожен працює у своєму .qmd):

```bash
git pull                      # ЗАВЖДИ перед початком роботи
# ... працюєш ...
git add -A
git commit -m "H1-H2: діагностика і тести"
git push
```

---

## 2. Порядок роботи з файлами

### 2.1. `01_data_preparation.qmd` — дані (людина B, сьогодні)

Відкрий файл у RStudio → кнопка **Render** (або по чанках Cmd+Shift+Enter).
Чанки з готовим кодом виконаються; місця з `# TODO` — твоя робота:

- замапити коди `route_type` у назви (дивись вивід `count()`);
- `separate_rows()` для `routeId` виду "14,47" у vehicles;
- довжина маршрутів із `shapes`;
- фінальний join → `data/processed/analysis_table.csv`.

Сирі дані **вже в репозиторії** — качати нічого не треба. Чанк `download`
вимкнений (`eval: false`); вмикати лише для оновлення даних.

Прямі посилання на всі джерела — у `PLAN.md`, розділ 2 (таблиця з лінками).

### 2.2. `R/collect_realtime.R` — збирач GPS (людина A, запустити ЗАРАЗ)

Це нескінченний цикл, тому НЕ Quarto і НЕ RStudio. У терміналі:

```bash
cd "шлях/до/Project"
# Mac: caffeinate не дає ноуту заснути, поки живий процес
caffeinate -i Rscript R/collect_realtime.R
# Windows (PowerShell): вимкни сон у налаштуваннях живлення, потім:
# Rscript R\collect_realtime.R
```

Що має відбуватись: кожні 2 хв у консолі рядок `... збережено vp_*.pb (~27000 байт)`,
а в `data/raw/rt/` ростуть файли. Залишити до неділі вечора.
Зупинити: Ctrl+C.

**Наприкінці збору** (людина A, неділя) — конвертація в CSV:

```bash
cd "шлях/до/Project"
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install gtfs-realtime-bindings pandas
python scripts/parse_realtime.py   # → data/processed/realtime_positions.csv
```

### 2.3. `02_analysis.qmd` — статистика (людина C, після появи analysis_table.csv)

Схема кожної гіпотези: **діагностика → вибір тесту → p-value → висновок словами.**
Тільки методи курсу (лекції 6–10): t-тест, Shapiro–Wilk/QQ, KS, chi-square,
Mann–Whitney, Kruskal–Wallis, bootstrap. Підказки — у коментарях чанків.

### 2.4. `03_realtime_bonus.qmd` — бонус (людина A, неділя)

Тільки якщо ядро готове. Порівнюємо фактичні headway 2–3 маршрутів із
плановими **вихідного дня**. Не встигаємо — дропаємо без жалю.

### 2.5. Звіт і слайди (людина D, паралельно)

Звіт — Quarto у `report/` (Introduction з code book → Methodology → Results →
Discussion → Appendix із внесками). Рендер у PDF: у YAML `format: pdf`
(потрібен `quarto install tinytex`) або `format: html` і друк у PDF з браузера.
Слайди — Google Slides, ≤ 7 хв. Здача: кожен окремо завантажує ідентичний
пакет (звіт + код + слайди) у Moodle.

---

## 3. Особливості даних (перевірено на реальних файлах 11.07.2026)

Вірити цьому списку, а не описам на порталі:

- GTFS покриває **лише КП «Київпастранс»** (трамвай/тролейбус/автобус). Маршрутки — тільки список ТЗ, без розкладу.
- `stop_times.txt` — лише **контрольні точки**, не всі зупинки. Для headway ок: перша точка = відправлення з кінцевої.
- `stop_sequence` починається **з 1** (портал каже «з 10» — неправда).
- `route_type`: 0 = трамвай (стандарт GTFS); перевірити всі значення через `count(routes, route_type)`.
- `calendar.txt`: окремі service_id будні/вихідні. Основний аналіз — **будній** (monday = 1); бонус-порівняння з фактом — **вихідний**!
- `vehicles_kpt.json`: `routeId` буває списком через кому ("14,47").
- `vehicles_marshrutky.csv`: capacity текстом («не менше 21»), багато null.
- Realtime — **бінарний GTFS-RT protobuf** (не JSON). ~400 ТЗ у знімку. Парсити тільки через `scripts/parse_realtime.py`.
- Відомі баги GTFS (з пропозицій громадян): дзеркальні напрямки (виправлено), відсутні тимчасові маршрути → у Discussion.

---

## 4. Academic integrity

Силабус дозволяє AI для коду **з явним цитуванням**. Скелети .qmd/скриптів
згенеровано за допомогою Claude (Anthropic) і допрацьовано командою — вказати
це в звіті. Наратив (текст звіту) пишемо самі — AI для наративу заборонений.

## 5. Джерела даних

Портал даних Києва, ліцензія Open Data Licence:
https://data.kyivcity.gov.ua/organization/komunal-ne-pidpryiemstvo-kyivpastrans
Прямі лінки на кожен файл — у `PLAN.md`, розділ 2.
