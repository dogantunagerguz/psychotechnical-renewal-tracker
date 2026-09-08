-- Raw landing tables mirror the four public Power BI demo workbooks.

CREATE TABLE raw_trainees (
    candidate_id       INTEGER,
    licence_class      TEXT,
    certificate_serial TEXT,
    licence_issue_date TEXT,
    phone_ref          TEXT,
    candidate_name     TEXT,
    entry_type         TEXT
);

CREATE TABLE raw_call_results (
    candidate_id                 INTEGER,
    first_name                   TEXT,
    last_name                    TEXT,
    certificate_issue_date       TEXT,
    psychotechnical_assessment_date TEXT,
    source_month                 TEXT,
    source_year                  INTEGER,
    licence_class                TEXT,
    phone_ref                    TEXT,
    source_next_test_date        TEXT,
    source_status                TEXT
);

CREATE TABLE raw_external_pool (
    pool_id         INTEGER,
    customer_name   TEXT,
    source_date     TEXT,
    phone_ref       TEXT,
    source_workbook TEXT
);

