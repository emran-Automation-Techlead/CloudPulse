#!/usr/bin/env python3
# ---------------------------------------------------------------------------
# PLAIN ENGLISH: This script is CloudPulse's weekly "financial checkup."
# It asks AWS's Cost Explorer API two questions: "what did we actually
# spend last week, broken down by service?" and "has AWS's anomaly
# detection flagged anything unusual?" It then writes the answer as a
# plain-language Markdown report that gets posted to GitHub Issues by
# the accompanying workflow (.github/workflows/cost-report.yml). The
# goal is that a finance lead or engineering manager can read this
# report in under a minute and immediately understand where the money
# went and whether anything needs attention — no AWS console login
# required.
# ---------------------------------------------------------------------------

import argparse
import datetime
import sys

import boto3


def get_last_7_days_range() -> tuple[str, str]:
    """Plain English: computes the Mon-Sun (or run-date -7) window this
    report covers, formatted the way the Cost Explorer API expects."""
    end = datetime.date.today()
    start = end - datetime.timedelta(days=7)
    return start.isoformat(), end.isoformat()


def fetch_cost_by_service(ce_client, start: str, end: str) -> list[dict]:
    """Plain English: asks AWS 'how much did each service (EC2, S3, EKS,
    etc.) cost in this time window?' and returns it sorted, most
    expensive first, so the biggest cost driver is immediately visible."""
    response = ce_client.get_cost_and_usage(
        TimePeriod={"Start": start, "End": end},
        Granularity="DAILY",
        Metrics=["UnblendedCost"],
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
    )

    totals: dict[str, float] = {}
    for day in response.get("ResultsByTime", []):
        for group in day.get("Groups", []):
            service = group["Keys"][0]
            amount = float(group["Metrics"]["UnblendedCost"]["Amount"])
            totals[service] = totals.get(service, 0.0) + amount

    return sorted(
        [{"service": k, "cost": v} for k, v in totals.items() if v > 0.0],
        key=lambda x: x["cost"],
        reverse=True,
    )


def fetch_anomalies(ce_client, start: str, end: str) -> list[dict]:
    """Plain English: asks AWS 'did your machine-learning anomaly
    detector notice any unusual spending this week?' — this catches
    problems that a simple budget threshold would miss, like a resource
    that's still technically under budget but spending in a way that
    doesn't match its normal pattern."""
    try:
        response = ce_client.get_anomalies(
            DateInterval={"StartDate": start, "EndDate": end}
        )
        return response.get("Anomalies", [])
    except Exception as exc:  # pragma: no cover - defensive, API/permission variance
        print(f"Warning: could not fetch anomalies ({exc})", file=sys.stderr)
        return []


def render_markdown(start: str, end: str, costs: list[dict], anomalies: list[dict]) -> str:
    total = sum(c["cost"] for c in costs)
    lines = [
        f"## CloudPulse Weekly Cost Report ({start} to {end})",
        "",
        f"**Total spend this week: ${total:,.2f}**",
        "",
        "### Top cost drivers",
        "",
        "| Service | Cost (USD) | Share |",
        "|---|---:|---:|",
    ]

    for entry in costs[:10]:
        share = (entry["cost"] / total * 100) if total > 0 else 0
        lines.append(f"| {entry['service']} | ${entry['cost']:,.2f} | {share:.1f}% |")

    lines += ["", "### Anomaly detection"]
    if not anomalies:
        lines.append("")
        lines.append("No spending anomalies were flagged this week.")
    else:
        lines.append("")
        lines.append("| Anomaly | Estimated impact | Root cause |")
        lines.append("|---|---:|---|")
        for a in anomalies:
            impact = a.get("Impact", {}).get("TotalImpact", 0.0)
            root_causes = ", ".join(
                rc.get("Service", "unknown") for rc in a.get("RootCauses", [])
            ) or "unknown"
            lines.append(f"| {a.get('AnomalyId', 'n/a')} | ${impact:,.2f} | {root_causes} |")

    lines += [
        "",
        "---",
        "_This report was generated automatically by CloudPulse's weekly cost "
        "intelligence workflow. It solves 'zero visibility' by putting real "
        "spend data where the engineering team already works, and catches "
        "'AWS bill shock' before it becomes a surprise invoice._",
    ]

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate the CloudPulse weekly cost report.")
    parser.add_argument("--output", default="report.md", help="Path to write the Markdown report to.")
    args = parser.parse_args()

    start, end = get_last_7_days_range()
    ce_client = boto3.client("ce")

    costs = fetch_cost_by_service(ce_client, start, end)
    anomalies = fetch_anomalies(ce_client, start, end)

    report = render_markdown(start, end, costs, anomalies)

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(report)

    print(f"Wrote cost report to {args.output}")


if __name__ == "__main__":
    main()
