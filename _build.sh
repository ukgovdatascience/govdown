# Build the book!
cp NEWS.md ./site/NEWS.md
Rscript -e "rmarkdown::render_site(input = './site')"
