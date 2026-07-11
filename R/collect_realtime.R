# 02_collect_realtime.R — збирач GPS-знімків (БОНУС-частина плану)
# УВАГА: фід — бінарний GTFS-Realtime protobuf (не JSON!). Просто зберігаємо
# байти у .pb-файли; парсинг у CSV — наприкінці збору через scripts/parse_realtime.py
# Запустити на ноутбуці, який не засне (закрити кришку заборонено :)
# Зупинити: Esc/Ctrl+C. Код-скелет згенеровано з допомогою Claude (Anthropic).

library(here)

url <- "https://data.kyivcity.gov.ua/dataset/dani-pro-mistseznakhodzhennia-miskoho-elektrychnoho-ta-pasazhyrskoho-avtomobilnoho-tra-dep-transport/resource/1e0ced20-e242-4805-af55-d9afd37ab380/data/download"
out_dir <- here("data", "raw", "rt")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

repeat {
  dest <- file.path(out_dir, format(Sys.time(), "vp_%Y%m%d_%H%M%S.pb"))
  ok <- try(download.file(url, dest, mode = "wb", quiet = TRUE), silent = TRUE)
  if (inherits(ok, "try-error")) {
    message(Sys.time(), "  ПОМИЛКА завантаження — спробую ще раз через 2 хв")
  } else {
    message(Sys.time(), "  збережено ", basename(dest),
            " (", file.size(dest), " байт)")
  }
  Sys.sleep(120)  # кожні 2 хвилини
}
