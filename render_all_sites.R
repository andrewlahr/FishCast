# =============================================================================
# render_all_sites.R
# -----------------------------------------------------------------------------
# Loops over every (Stream, Section) combination and renders one standalone
# HTML report per site using site_report_template.Rmd. Outputs land in docs/
# so they can be served directly by GitHub Pages.
#
# Usage:
#   Rscript render_all_sites.R
#
# Configure the `sites` data frame below (or point it at a CSV) to match your
# actual site list. Site names must match the "{Stream}.{Section}" stem used
# in your *_RecLagInclusionProbQuad.csv and .rds files.
# =============================================================================
library(tidyverse)
# ---- 1. Paths ---------------------------------------------------------------
template_path <- here::here("r/site_report_template.Rmd")
output_dir    <- here::here("docs")                 # GitHub Pages serves from here
data_dir      <- "data/ModelFits/Brown Trout"       # relative to project root

dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# ---- 2. Define sites to render ----------------------------------------------
# Option A: inline list (easiest to edit)
sites <- read.csv('data/sites.csv')
# write.csv(sites,'data/sites.csv')
# Option B: load from a CSV (uncomment to use)
# sites <- readr::read_csv(here::here("sites.csv"))   # expects columns: stream, section

# ---- 3. Auto-discover sites from CSVs in data_dir (alternative) -------------
# Uncomment to skip the manual list and render every site that has a
# *_RecLagInclusionProbQuad.csv file on disk.
#
# csv_files <- list.files(here::here(data_dir),
#                         pattern = "_RecLagInclusionProbQuad\\.csv$",
#                         full.names = FALSE)
# sites <- tibble::tibble(
#   stem    = sub("_RecLagInclusionProbQuad\\.csv$", "", csv_files)
# ) %>%
#   tidyr::separate(stem, into = c("stream", "section"), sep = "\\.", extra = "merge")

# ---- 4. Render loop ---------------------------------------------------------
results <- purrr::map_dfr(seq_len(nrow(sites)), function(i) {
  stream  <- sites$stream[i]
  section <- sites$section[i]
  out_name <- paste0(stream, "_", section, ".html")

  message(sprintf("[%d/%d] Rendering %s - %s ...",
                  i, nrow(sites), stream, section))

  status <- tryCatch({
    rmarkdown::render(
      input       = template_path,
      output_file = out_name,
      output_dir  = output_dir,
      params      = list(
        stream   = stream,
        section  = section,
        data_dir = data_dir
      ),
      envir       = new.env(),   # isolate each render
      quiet       = TRUE
    )
    "ok"
  }, error = function(e) {
    message("   FAILED: ", conditionMessage(e))
    paste("error:", conditionMessage(e))
  })

  tibble::tibble(stream = stream, section = section,
                 file = out_name, status = status)
})

# ---- 5. Write the site index JSON used by the dropdown ---------------------
# docs/sites.json feeds the <select> on docs/index.html
site_index <- results %>%
  filter(status == "ok") %>%
  transmute(
    stream,
    section,
    label = paste(stream, "\u2014", section),
    file  = file
  )

jsonlite::write_json(
  site_index,
  file.path(output_dir, "sites.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

message("\nRendered ", sum(results$status == "ok"), "/", nrow(results),
        " sites into ", output_dir)
if (any(results$status != "ok")) {
  message("Failures:")
  print(results %>% filter(status != "ok"))
}
