module main

import time


struct Month {
	month int
	year  int
}

struct DateRange {
	from time.Time
	to   time.Time
}

fn (m Month) full_month_date_range() DateRange {
	days_in_month := time.days_in_month(m.month, m.year) or { panic(err) }

	from := time.Time{
		year: m.year
		month: m.month
		day: 1
	}
	
	to := time.Time{
		year: m.year
		month: m.month
		day: days_in_month
	}

	return DateRange{
		from: from
		to: to
	}
}

fn past_n_months(n int) []Month {
	mut months := []Month{}
	now := time.now()
	mut current_month := now.month
	mut current_year := now.year

	for i := 0; i < n; i++ {
		if current_month < 1 {
			current_month = 12
			current_year--
		}
		month := Month{
			month: current_month
			year: current_year
		}
		months << month
		current_month--
	}
	return months.reverse()
}

fn (d DateRange) to_string() (string, string) {
	from_str := d.from.get_fmt_date_str(.hyphen, .yyyymmdd)
	to_str := d.to.get_fmt_date_str(.hyphen, .yyyymmdd)
	return from_str, to_str
}
