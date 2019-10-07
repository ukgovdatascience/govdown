#!/bin/bash

if [[ $TRAVIS_BRANCH == 'master' ]]
then
  # Decrypt the deploy key
  openssl aes-256-cbc -K $encrypted_e5387e4e26d8_key -iv $encrypted_e5387e4e26d8_iv -in deploy_key.enc -out deploy_key -d

  # Start ssh agent and add key
  eval "$(ssh-agent -s)" # Start the ssh agent
  chmod 600 deploy_key
  ssh-add deploy_key

  # configure your name and email if you have not done so
  git config --global user.email "duncan.garmonsway@digital.cabinet-office.gov.uk"
  git config --global user.name "nacnudus"

  # clone the repository to the book-output directory
  git clone -b gh-pages \
    git@github.com:ukgovdatascience/govdown.git \
    book-output
  cd book-output
  git rm -rf *
  # Copy the new book and commit!
  cp -r ../docs/* ./
  git add --all *
  git commit -m "Travis built book"
  git push -q origin gh-pages
else
  echo "Not publishing as not in MASTER branch"
fi
