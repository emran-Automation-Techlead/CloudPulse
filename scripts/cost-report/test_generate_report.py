#!/usr/bin/env python3
# ---------------------------------------------------------------------------
# PLAIN ENGLISH: Automated tests proving the report-formatting logic
# produces correct, readable output — without needing a live AWS
# connection. Run with: python -m pytest scripts/cost-report
# ---------------------------------------------------------------------------

from generate_report import render_markdown


def test_render_markdown_includes_total_and_services():
    costs = [
        {"service": "Amazon EKS", "cost": 120.50},
        {"service": "Amazon EC2", "cost": 45.25},
    ]
    report = render_markdown("2026-07-01", "2026-07-08", costs, [])

    assert "Amazon EKS" in report
    assert "$120.50" in report
    assert "Total spend this week: $165.75" in report
    assert "No spending anomalies were flagged this week." in report


def test_render_markdown_includes_anomalies():
    costs = [{"service": "Amazon EC2", "cost": 100.0}]
    anomalies = [
        {
            "AnomalyId": "abc-123",
            "Impact": {"TotalImpact": 42.0},
            "RootCauses": [{"Service": "Amazon EC2"}],
        }
    ]
    report = render_markdown("2026-07-01", "2026-07-08", costs, anomalies)

    assert "abc-123" in report
    assert "$42.00" in report


def test_render_markdown_handles_zero_spend():
    report = render_markdown("2026-07-01", "2026-07-08", [], [])

    assert "Total spend this week: $0.00" in report
