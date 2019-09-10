# Remove previous installation
ASSETS=/inst/rmarkdown/resources/assets
if [ -d "$ASSETS" ]; then rm -Rf $ASSETS; fi

rm -r inst/rmarkdown/resources/assets

# Create a package.json file -- only has to be done once.
# npm init -f

# Download govuk-frontend. It will warn about no description or repository field
# in the package.json.
npm install govuk-frontend

# Make the path to assets relative
sed -i "s/\/assets\//assets\//" node_modules/govuk-frontend/govuk/settings/_assets.scss

# Create an scss file to import all of govuk-frontend -- only has to be done once
# echo "@import \"node_modules/govuk-frontend/govuk/all\";" > govuk.scss

# Compile the scss to css
sassc scss/govuk.scss inst/rmarkdown/resources/govuk.css

# Make a variant that doesn't use the New Transport font
sed -i "s/\$govuk-font-family-nta/sans-serif/" node_modules/govuk-frontend/govuk/settings/_typography-font.scss
sed -i "s/\$govuk-font-family-nta-tabular/sans-serif/" node_modules/govuk-frontend/govuk/settings/_typography-font.scss
sed -i "s/sans-serif-tabular/sans-serif/" node_modules/govuk-frontend/govuk/settings/_typography-font.scss
sed -i "/@include _govuk-font-face-nta;/d" node_modules/govuk-frontend/govuk/helpers/_typography.scss

# Recompile the scss to css
sassc scss/govuk.scss inst/rmarkdown/resources/govukish.css

# Move assets to /inst/rmarkdown/resources
mv node_modules/govuk-frontend/govuk/assets inst/rmarkdown/resources/
mv node_modules/govuk-frontend/govuk/all.js inst/rmarkdown/resources
# rm -r node_modules
