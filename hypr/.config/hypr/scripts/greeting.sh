#!/usr/bin/env bash
hour=$(date +%H)
if [ "$hour" -lt 12 ]; then
  period="Morning"
elif [ "$hour" -lt 17 ]; then
  period="Afternoon"
else
  period="Evening"
fi
echo "Good $period, $(whoami)"
