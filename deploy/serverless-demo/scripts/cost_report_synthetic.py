#!/usr/bin/env python3
# PLAIN ENGLISH: Runs the repository's real render_markdown() on made-up numbers so the
# weekly report format can be shown with no AWS call, no cost and no notification.
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[3] / "scripts" / "cost-report"))
from generate_report import render_markdown

print("SYNTHETIC DATA - not live billing\n")
print(render_markdown("2026-10-15", "2026-10-22",
      [{"service": "AWS Lambda", "cost": 0.42}, {"service": "Amazon CloudWatch", "cost": 0.11}], []))
