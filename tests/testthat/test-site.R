context("site")

test_that("rmarkdown::render_site", {

  skip_on_cran() # due to Pandoc v2 dependency

  # copy our demo site to a tempdir
  site_dir <- tempfile()
  dir.create(site_dir)
  files <- c("_site.yml", "index.Rmd", "tech-docs.Rmd",
             "404.md", "accessibility.md", "LICENSE.md",
             "NEWS.md", "README.md", "images", "favicon")
  file.copy(file.path("site", files), site_dir, recursive = TRUE)

  # render it
  capture.output(rmarkdown::render_site(site_dir))

  # did the html files get rendered and the css get copied?
  html_files <- c("index.html", "tech-docs.html", "404.html",
                  "accessibility.html", "LICENSE.html", "NEWS.html")
  html_files <- file.path(site_dir, "docs", html_files)
  expect_true(all(file.exists(html_files)))

  # copied directories
  moved <- c("site_libs", "favicon", "images")
  expect_true(all(file.exists(file.path(site_dir, "docs", moved))))
})
