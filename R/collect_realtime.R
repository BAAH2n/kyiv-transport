# collect_realtime.R — збирач GPS-знімків (БОНУС-частина плану)
# Фід — бінарний GTFS-Realtime protobuf (не JSON!); зберігаємо байти в .pb,
# парсинг у CSV — наприкінці збору: scripts/parse_realtime.py
# Запуск (термінал, Mac):  caffeinate -i Rscript R/collect_realtime.R
# Зупинити: Ctrl+C.
# ВАЖЛИВО: портал редіректить на http-адресу, тому curl::curl_download,
# а НЕ download.file (той падає з «ПОМИЛКА завантаження»).
# Код-скелет згенеровано з допомогою Claude (Anthropic), допрацьовано командою.

library(here)
library(curl)

url <- "https://data.kyivcity.gov.ua/dataset/dani-pro-mistseznakhodzhennia-miskoho-elektrychnoho-ta-pasazhyrskoho-avtomobilnoho-tra-dep-transport/resource/1e0ced20-e242-4805-af55-d9afd37ab380/data/download"
out_dir <- here("data", "raw", "rt")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

h <- new_handle(followlocation = TRUE, timeout = 60)

repeat {
  dest <- file.path(out_dir, format(Sys.time(), "vp_%Y%m%d_%H%M%S.pb"))
  ok <- try(curl_download(url, dest, handle = h, quiet = TRUE), silent = TRUE)
  if (inherits(ok, "try-error") || !file.exists(dest) || file.size(dest) < 1000) {
    message(Sys.time(), "  ПОМИЛКА завантаження — повтор через 2 хв")
    if (file.exists(dest) && file.size(dest) < 1000) file.remove(dest)  # прибрати биті знімки
  } else {
    message(Sys.time(), "  збережено ", basename(dest),
            " (", file.size(dest), " байт)")
  }
  Sys.sleep(120)  # кожні 2 хвилини
}
