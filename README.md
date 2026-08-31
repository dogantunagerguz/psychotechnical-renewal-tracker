# Psychotechnical Renewal Tracker

| | |
|---|---|
| **Business impact** | Prioritizes upcoming psychotechnical renewals and prevents duplicate calls through a self-updating contact pool. |
| **Tools** | Power BI, Power Query, DAX |
| **Status** | In operational use; fully automated via M365 scheduled cloud refresh. |


**TL;DR:** A Power BI report for a driving school. It tracks when commercial drivers' psychotechnical assessments are due for renewal and turns the ones coming up into a call list. The goal wasn't to discover something new. It was to take work already being done and make it faster, repeatable, and easier to follow.

## Context

In Turkey, psychotechnical assessment became mandatory for drivers of commercial vehicles after 30 June 2021. People who got their licence before that date were included too. The assessment has to be renewed every five years.

For a driving school, that means hundreds of people need reassessment at regular intervals, and someone has to keep track of whose turn is coming up when. That tracking can be done by hand. This system makes doing it by hand unnecessary.

## What the system does

It first filters the driving school data down to people who hold a C, D, or E class licence. Then, for each person, it works out the next test date, shows whose turn is approaching, and produces the call list on its own. Three pieces make that possible.

**Anchor.** A start date for each person. If the licence was issued before 30 June 2021, the anchor becomes that day; otherwise it's the real licence date. The regulation collapses into a single column.

**Next Test.** Starting from the anchor, it steps forward in five-year cycles and finds roughly when the person's next test falls. Whatever point of the cycle someone is in, the system finds the right date on its own. The purpose is targeting. Instead of calling trainees at random, we call the ones whose turn is approaching, not the ones whose time hasn't come yet.

**Status.** Based on the months left until the next test, everyone falls into a group: Overdue, Due now, Upcoming, Later. The people to call come out of these groups.

The same logic runs for the pool. The trainee list feeds the pool, and for people in the pool the next test date is calculated and grouped by status as well. The user sees whose date is approaching through Power BI and calls them to let them know when their time comes.

The Overdue group was kept deliberately narrow, showing only those whose date passed within the last three months. The aim is to keep the call list manageable. If the window were wide, the list would get crowded and the people who genuinely need calling right now would get lost.

## Who it covers

Only C, D, and E class commercial licences. Motorcycle and automobile licences were left out of the system. Those classes are often held for personal use rather than commercial work, so most of their holders aren't interested in psychotechnical renewal. Leaving them out spends calling time on the people actually worth calling.

## What happens to the people who get called

When a person is called, two things happen, both from a single record.

Interested people get added to the pool. The pool is fed from two sources: people found externally and trainees who, when called, say they're interested. Each person in the pool carries a source tag, so the user can see whether the person came from the course or from outside. The point of the pool is to reach these people and set up an appointment when their psychotechnical date comes due.

Called people also drop off the call list. I didn't write separate code for this. I used the existing status field in a page filter, so only people who haven't been called yet show up. The same person doesn't get called twice.

![Flow of called candidates: trainee list and externally sourced people feed the pool, and the pool leads to an appointment](docs/psychotechnical_called_candidates_flow.png)

## Numbers

Of 1092 people called from the trainee list, 648 shared their psychotechnical date, meaning they were interested. A little over half. The thing to note is that this isn't the share of people who took the assessment. It's the share who were interested when we called. So it measures the aim of the list, not its outcome: are we calling the right people. Because motorcycle and automobile licences were filtered out, the list is already full of people worth calling.

The number of people on the tracking list looks high at first glance. That's the regulatory transition. Because everyone who got their licence before 2021 is anchored to the same date, a one-time backlog built up. That backlog isn't permanent. As the system runs, as calls are made and real dates get written back into the pool, the number comes down on its own. Its size today is the size of the work the transition created.

## Update: Automated Cloud Refresh Pipeline

The manual refresh step has been fully automated:
* **Cloud Architecture:** Configured end-to-end data ingestion directly from Microsoft 365 (SharePoint/OneDrive) using native OAuth2 cloud connections, completely eliminating the need for an on-premises data gateway.
* **Dynamic Lead Feedback:** Built cross-table DAX logic (`LOOKUPVALUE` and status switching) that automatically identifies called candidates and flags them as "Called", removing them from the active call queue in real time once updated in the cloud sources.
* **Hands-off Scheduling:** The semantic model now runs on automated scheduled refresh inside Power BI Service, keeping operational call lists up to date without manual intervention.
