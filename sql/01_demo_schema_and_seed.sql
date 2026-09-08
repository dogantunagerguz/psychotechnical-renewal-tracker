-- Fully synthetic SQLite fixture for the psychotechnical renewal portfolio.
-- No names, dates or results below come from private operational records.

PRAGMA foreign_keys = ON;

CREATE TABLE trainees (
    candidate_id       INTEGER PRIMARY KEY,
    candidate_name     TEXT NOT NULL,
    licence_class      TEXT NOT NULL CHECK (licence_class IN ('B', 'C', 'D', 'E')),
    licence_issue_date TEXT NOT NULL
);

CREATE TABLE call_outcomes (
    candidate_id INTEGER PRIMARY KEY REFERENCES trainees(candidate_id),
    called_at    TEXT NOT NULL,
    outcome      TEXT NOT NULL CHECK (outcome IN ('interested', 'not_interested'))
);

CREATE TABLE external_pool (
    pool_id     INTEGER PRIMARY KEY,
    person_ref  TEXT NOT NULL UNIQUE,
    source_date TEXT NOT NULL
);

INSERT INTO trainees (candidate_id, candidate_name, licence_class, licence_issue_date) VALUES
    (1, 'DEMO TRAINEE 001', 'C', '2019-01-15'),
    (2, 'DEMO TRAINEE 002', 'D', '2021-08-20'),
    (3, 'DEMO TRAINEE 003', 'E', '2021-09-15'),
    (4, 'DEMO TRAINEE 004', 'C', '2021-10-20'),
    (5, 'DEMO TRAINEE 005', 'D', '2021-11-01'),
    (6, 'DEMO TRAINEE 006', 'E', '2022-02-01'),
    (7, 'DEMO TRAINEE 007', 'B', '2021-09-10');

INSERT INTO call_outcomes (candidate_id, called_at, outcome) VALUES
    (1, '2026-07-05', 'interested'),
    (3, '2026-09-01', 'not_interested');

INSERT INTO external_pool (pool_id, person_ref, source_date) VALUES
    (1, 'DEMO EXTERNAL 001', '2025-12-15'),
    (2, 'DEMO EXTERNAL 002', '2026-01-15'),
    (3, 'DEMO EXTERNAL 003', '2026-02-15');

