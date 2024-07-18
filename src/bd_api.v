module main

import net.http

const cost_base_url = 'https://api.brightdata.com/zone/cost?zone='
const bearer_prefix = 'Bearer '
const auth_header_name = 'Authorization'

// API response model
struct Stats {
	bw   u64
	cost f32
}

struct AccountStats {
	custom Stats
}

struct Root {
	account AccountStats
}

fn build_req_url(zone string, from string, to string) string {
	return '${cost_base_url}${zone}&from=${from}&to=${to}'
}

fn build_req(req_url string, token string) http.Request {
	mut req := http.Request{
		method: http.Method.get
		url: req_url
	}
	auth_header_value := bearer_prefix + token
	req.add_custom_header(auth_header_name, auth_header_value) or { panic(err) }
	return req
}

fn zone_stats(zone string, dr DateRange, token string) {
	// Get the date ranges for the past n months
	//date_ranges := past_n_months(months).map(|m| m.full_month_date_range())
	from, to := dr.to_string()
	req_url := build_req_url(zone, from, to)
	req := build_req(req_url, token)
	println('Fetching data for zone ${zone} from ${from} to ${to}...')
	resp := req.do() or { panic(err) }
	println(resp.body)
}