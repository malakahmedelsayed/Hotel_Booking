#  Hotel Booking Analysis

## Team Members
- [ Malak rafaat 23011557] 
- [malak ahmed 23011556] 
- [Madawi mohammed 23011923] 
- [malak rabie 23011558]  
- [mariam alaa 2402242542 ]

End-to-end data analytics project covering reservations at a **City Hotel** and a **Resort Hotel** (2015–2017), built with **Power Query**, **SQL Server**, and **Power BI**.

> Data Cleaning (Power Query) · SQL Analysis · Power BI Dashboard
> Prepared: September 2026

---

##  Executive Summary

This project analyzes hotel booking demand data to understand why bookings get canceled, where revenue is won and lost, who the customers are, and how operational factors (lead time, deposit type, special requests, room assignment) relate to cancellation risk.

The workflow moves data through three stages: **cleaning & enrichment** → **structured SQL querying** → **interactive Power BI visualization**.

**Headline numbers (cleaned dataset, 87,207 bookings):**

| Metric | Value |
|---|---|
| Overall cancellation rate | **27.53%** |
| City Hotel cancellation rate | 30.10% |
| Resort Hotel cancellation rate | 23.49% |
| Total potential stay revenue | ~$34.44M |
| Total realized (net) revenue | ~$22.96M |
| Revenue lost to cancellations | ~$11.48M (33.3%) |

Lead time, market segment, and number of special requests emerged as the strongest behavioral signals for cancellation risk.

---

##  Project Objectives

- What is the overall booking cancellation rate, and how does it vary by hotel, market segment, and lead time?
- Which channels, customer types, and market segments generate the most net revenue?
- How do bookings and revenue trend over time (by year and month)?
- What is the relationship between special requests, deposit type, and cancellation likelihood?
- How often is a guest assigned a different room type than reserved, and does this affect cancellations?
- Which countries and hotels contribute the most bookings and revenue?

These map directly to the 18 numbered queries in `Hotel_Booking_SQL_Analysis.sql` and to the five pages of `Final_Project.pbix`.

---

##  Data Source & Description

### Raw Dataset
- **File:** `hotel_bookings.csv`
- **Rows:** 119,391 bookings (+ header)
- **Columns:** 32
- **Grain:** One row per hotel booking
- **Time span:** Arrivals dated 2015–2017
- **Hotel types:** City Hotel, Resort Hotel

Key raw fields: `hotel`, `is_canceled`, `lead_time`, `arrival_date_year/month/week/day`, `stays_in_weekend_nights`, `stays_in_week_nights`, `adults`, `children`, `babies`, `meal`, `country`, `market_segment`, `distribution_channel`, `is_repeated_guest`, `previous_cancellations`, `reserved_room_type`, `assigned_room_type`, `deposit_type`, `agent`, `company`, `customer_type`, `adr`, `required_car_parking_spaces`, `total_of_special_requests`, `reservation_status`, `reservation_status_date`.

### Cleaned Dataset
- **File:** `powerbi_cleaning.pbix`
- **Rows:** 87,207 (32,184 removed — ~27% of raw file)
- **Columns:** 37 (32 original + 5 derived)

**Derived fields added:**
| Field | Description |
|---|---|
| `arrival_date` | Proper date built from year/month/day parts |
| `total_guests` | `adults + children + babies` |
| `total_nights` | `stays_in_weekend_nights + stays_in_week_nights` |
| `total_stay_revenue` | `adr × total_nights` |
| `booking_status` | Readable label ("Canceled" / "Not Canceled") from `is_canceled` |

---

##  Data Cleaning & Preparation

**Steps applied:**
- Removed exact duplicate booking records
- Standardized missing categorical values (e.g. unspecified agent/company codes) as explicit 0/NULL markers
- Converted year/month/day parts into a single `arrival_date` field
- Derived `total_guests` and `total_nights`
- Calculated `total_stay_revenue` (`adr × total_nights`)
- Added a readable `booking_status` label
- Filtered out structurally invalid rows (e.g. zero guests, non-numeric `adr`)

**Net Revenue Logic:**
`net_revenue` = `total_stay_revenue` for completed bookings, `0` for canceled bookings.
`Revenue Loss` = `total_stay_revenue − net_revenue` (potential income forfeited to cancellations).

The cleaned, enriched table (87,207 rows × 37 columns) was loaded into SQL Server as `dbo.HotelBookings`, the single source of truth for both the SQL analysis and the Power BI data model.

---

##  Database & SQL Analysis

**File:** `Hotel_Booking_SQL_Analysis.sql` — run against SQL Server database `HotelBookingAnalysis`.

Starts with data validation (row counts, column/data-type inventory, sample preview), then answers **18 numbered business questions** using aggregation, `CASE`-based bucketing, CTEs, and a window function (`RANK`).

### Highlighted results

**Q1 — Overall cancellation rate**
| Total Bookings | Canceled | Not Canceled | Rate |
|---|---|---|---|
| 87,207 | 24,008 | 63,199 | 27.53% |

**Q2 — By hotel**
| Hotel | Bookings | Canceled | Rate |
|---|---|---|---|
| City Hotel | 53,267 | 16,035 | 30.10% |
| Resort Hotel | 33,940 | 7,973 | 23.49% |

**Q3 — By market segment** (top risk: Online TA at 35.39%)
**Q4 — By lead time** (181+ days → 39.79% vs. 0–7 days → 8.42%)
**Q9 — Special requests vs. cancellation** (0 requests → 33.26% vs. 5 requests → 5.56%)
**Q10 — Top countries:** Portugal leads with 27,352 bookings, followed by UK and France
**Q12:** 14.89% of bookings received a different room type than reserved
**Q15 — By year:** cancellation rate rose from 20.35% (2015) to 31.95% (2017)

Other queries cover revenue by customer type/hotel/segment, time trends, room-type mismatches, CTE usage, window-function ranking, and filtering/sorting examples (see the full script for all 18 queries).

---

##  Power BI Dashboard

Two Power BI files support this project:
- **`powerbi_cleaning.pbix`** — staging file for Power Query data shaping (single blank canvas, used only for prep)
- **`Final_Project.pbix`** — finished, 5-page interactive report



**Key measures:** Total Bookings, Canceled Bookings, Cancellation Rate, `net_revenue`, `total_stay_revenue`, Revenue Loss, Total Guests, Repeat Guests, Bookings with Special Requests, Lead Time Group, Room Type Match.

**Interactivity:** All five pages share consistent hotel and arrival-date slicers, with page-navigation buttons so selections persist across views.

---

##  Key Insights

- Nearly **3 in 10 bookings (27.53%)** are canceled; City Hotel cancels meaningfully more (30.10%) than Resort Hotel (23.49%).
- Cancellation risk rises steadily with lead time: **181+ days → 39.79%**, roughly **4.7x** the rate within 7 days of arrival (8.42%).
- **Online TA** is the largest channel (59% of bookings) *and* the highest-risk (35.39% cancellation) — more than double Corporate (12.12%) or Direct (14.75%).
- More special requests at booking = lower cancellation risk (33.26% at 0 requests vs. 5.56% at 5 requests) — a useful commitment signal.
- Of $34.44M potential revenue, only 66.7% ($22.96M) was realized — an **$11.48M** loss exposure concentrated in City Hotel and Online TA.
- **Portugal** is the dominant source market (~31% of bookings), followed by UK and France.
- **14.89%** of bookings receive a different room type than reserved.
- Cancellation rate rose year-over-year: 20.35% (2015) → 31.95% (2017), even as bookings and revenue grew.

---

##  Recommendations

- Tighten deposit/confirmation policies for long-lead-time bookings (91+ days).
- Review Online TA channel terms (cancellation windows, deposit requirements).
- Use "zero special requests" as an early-warning flag; trigger a confirmation touchpoint.
- Prioritize overbooking/room-assignment protection for City Hotel.
- Track year-over-year cancellation rate as an ongoing KPI.
- Extend the model with a forward-looking cancellation-probability score (lead time + market segment + special requests).

---

##  Tools & Technologies

| Stage | Tool | Purpose |
|---|---|---|
| Data Cleaning | Power BI / Power Query | De-duplication, null handling, column derivation |
| Database | Microsoft SQL Server | Hosting `dbo.HotelBookings`, running the analysis script |
| Analysis | T-SQL | Aggregation, `CASE` bucketing, CTEs, window functions (`RANK`) |
| Visualization | Power BI Desktop | 5-page interactive report |

---

##  Project Files

| File | Role |
|---|---|
| `hotel_bookings.csv` | Raw source data (119,391 rows, 32 columns) |
| `powerbi_cleaning.pbix` | Power Query staging file for data preparation |
| `Hotel_Booking_SQL_Analysis.sql` | 18-question T-SQL analysis script |
| `Final_Project.pbix` | Final 5-page Power BI report |

---

##  Getting Started

1. Clone/download this repository.
2. Load `hotel_bookings.csv` into SQL Server (or use `powerbi_cleaning.pbix` to reproduce the cleaning steps).
3. Run `Hotel_Booking_SQL_Analysis.sql` against the resulting `dbo.HotelBookings` table.
4. Open `Final_Project.pbix` in Power BI Desktop to explore the interactive dashboard.
