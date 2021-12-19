#!/bin/bash
# Runs the scraper

cd ~/srv/scraper
~/.poetry/bin/poetry run python3 scrape.py --article-limit 10
