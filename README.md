# Psychotechnical Renewal Tracker

![Dashboard](assets/dashboard.png)

**What it does:** Tracks commercial drivers' five-year psychotechnical renewals and turns upcoming dates into prioritized call lists and a contact pool.  
**Tools:** Power BI · DAX · Power Query · Python · SQLite  
**Status:** Operational use with scheduled M365/Power BI Service refresh; local public demo refreshes manually; operational source data is private.

[▶ Run the public demo](#run-the-public-demo) · [SQL companion](sql/) · [Full story](docs/story.md)

[View all dashboard pages](docs/dashboard.md)

## Run the public demo

The public demo uses **fully synthetic data**, generated locally without private files, credentials, or API requests. Demo figures are illustrative and do not reproduce the [reported business results](docs/story.md#numbers).

1. Download this repository (Code → Download ZIP) and extract it, or clone it.
2. Install Python 3.10+ and a current Power BI Desktop for Windows with PBIP/TMDL support.
3. Close the project in Power BI Desktop, then run these commands from the repository folder:

```bash
python -m pip install -r requirements.txt
python scripts/setup_demo.py
```

4. Open `pbip/Psiko Demo.pbip` and select **Refresh**.

The script writes the sample workbooks to `demo-data/` and updates the single `DemoDataFolder` Power Query parameter in the local project. If you move the repository, close Power BI Desktop and run the setup command again. To use another sample-data location, run `python scripts/setup_demo.py --data-dir "path/to/demo-data"`. You can also edit `DemoDataFolder` through **Transform data → Manage Parameters**.

Python can generate the files on Windows, macOS, or Linux; opening the report requires [Power BI Desktop](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview). No Power BI Service workspace or cloud refresh setup is required for this local demo. If a map requests an online map service, the remaining report pages can still be reviewed offline.

The sample workbooks are anchored to 2026 and contain invented identities and records, with matching keys across related tables. Renewal dates and status buckets use the date at model refresh through `TODAY()`, so they can change on a later refresh even when the sample files are unchanged. Existing screenshots and operational results describe the original project; their totals will differ from this demo.

Run the automated source-data and relocation checks with:

```bash
python -m unittest discover -s tests -v
```

## SQL evidence

The [SQL companion README](sql/README.md) explains the synthetic source-to-mart pipeline, renewal logic, call queue and data-quality controls. Python and SQLite support this public portfolio companion; SQL is not presented as part of the original production workflow.

```bash
python sql/run_demo.py
```

[Executed SQL results](sql/RESULTS.md) · [Data dictionary](sql/DATA_DICTIONARY.md) · [Metric definitions and cohort limits](docs/story.md#numbers)
