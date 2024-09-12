#!/bin/sh

# Check if .env file exists and source it
if [ -f .env ]; then
  . .env
else
  echo ".env file not found. Please create it first."
  exit 1
fi

# Substitute environment variables in the YAML file
sed -e "s/TELEGRAM_BOTTOKEN_PLACEHOLDER/${TELEGRAM_BOTTOKEN}/" \
    -e "s/TELEGRAM_CHATID_PLACEHOLDER/\"${TELEGRAM_CHATID}\"/" \
    grafana/alerting/template_contact_points.yaml > grafana/alerting/contact_points.yaml