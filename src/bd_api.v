module main

import json
import math
import net.http
import regex

const cost_base_url = 'https://api.brightdata.com/zone/cost?zone='
const bearer_prefix = 'Bearer '
const auth_header_name = 'Authorization'
const account_pattern = r'{"[^"]+"'
const bandwith_divisor = math.pow(1000, 3)

// API response model
struct Stats {
	bw   f64
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

fn parse_api_response(resp http.Response) Root {
	mut re := regex.regex_opt(account_pattern) or { panic(err) }
	// Replace the actual account name with a placeholder to avoid parsing errors
	json_resp := re.replace_n(resp.body, '{"account"', 1)
	return json.decode(Root, json_resp) or { panic(err) }
}

fn bandwith_in_gb(r Root) Root {
	bw_gb := r.account.custom.bw / bandwith_divisor
	return Root{
		account: AccountStats{
			custom: Stats{
				bw: math.round_sig(bw_gb, 2)
				cost: r.account.custom.cost
			}
		}
	}
}

fn zone_stats(zone string, dr DateRange, token string) Stats {
	from, to := dr.to_string()
	req_url := build_req_url(zone, from, to)
	req := build_req(req_url, token)
	println('Fetching data for zone ${zone} from ${from} to ${to}...')
	resp := req.do() or { panic(err) }
	root := bandwith_in_gb(parse_api_response(resp))
	return root.account.custom
}

fn bulk_zone_stats(zone string, drs []DateRange, token string) []Stats {
	return drs.map(fn [zone, token] (dr DateRange) Stats {
		return zone_stats(zone, dr, token)
	})
}
