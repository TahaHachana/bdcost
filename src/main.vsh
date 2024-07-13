import clitable
import json
import net.http
import os
import regex
import time
import thomaspeissl.dotenv

const brightdata_api_token = load_env_var('BRIGHTDATA_API_TOKEN')
const test_zone = load_env_var('TEST_ZONE')
const cost_base_url = 'https://api.brightdata.com/zone/cost?zone='
const bearer_prefix = 'Bearer '
const auth_header_name = 'Authorization'

struct Month {
	month int
	year  int
}

struct DateRange {
	from time.Time
	to   time.Time
}

struct Custom {
	bw   u64
	cost f32
}

struct Data {
	custom Custom
}

struct Root {
	account Data
}

fn (m Month) to_date_range() DateRange {
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

fn past_twelve_months() []Month {
	mut months := []Month{}

	now := time.now()
	current_month := now.month
	current_year := now.year

	for i in current_month + 1 .. 13 {
		month := Month{
			month: i
			year: current_year - 1
		}
		months << month
	}

	for i in 1 .. current_month + 1 {
		month := Month{
			month: i
			year: current_year
		}
		months << month
	}

	return months
}

fn load_env_var(var_name string) string {
	dotenv.load_file('../.env')
	return os.getenv(var_name)
}

mut months := past_twelve_months()
date_ranges := months.map(|m| m.to_date_range())

mut data := []Root{}

for dr in date_ranges {
	from_str := dr.from.get_fmt_date_str(.hyphen, .yyyymmdd)
	to_str := dr.to.get_fmt_date_str(.hyphen, .yyyymmdd)

	req_url := '${cost_base_url}${test_zone}&from=${from_str}&to=${to_str}'
	mut req := http.Request{
		method: http.Method.get
		url: req_url
	}
	auth_header_value := bearer_prefix + brightdata_api_token
	req.add_custom_header(auth_header_name, auth_header_value) or { panic(err) }
	resp := req.do()!

	account_pattern := r'{"[^"]+"'
	mut re := regex.regex_opt(account_pattern)!
	//println(re.get_query())
	json_resp := re.replace_n(resp.body, '{"account"', 1)
	data << json.decode(Root, json_resp)!
}

customs := data.map(|d| d.account.custom)
clitable.print_structs(customs)
