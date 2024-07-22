module main

import arrays
import clitable
import os
import flag

const bd_token_var = 'BRIGHTDATA_API_TOKEN'

fn init_fp() &flag.FlagParser {
	mut fp := flag.new_flag_parser(os.args)
	fp.application(name)
	fp.version(version)
	fp.description(description)
	fp.skip_executable()
	return fp
}

fn finalize_fp(mut fp flag.FlagParser) ! {
	additional_args := fp.finalize()!
	if additional_args.len > 0 {
		println('Unprocessed arguments:\n${additional_args.join_lines()}')
	}
}

fn print_zone_report(months int, zone string, token string) {
	date_ranges := past_n_months(months).map(|m| m.full_month_date_range())

	stats := bulk_zone_stats(zone, date_ranges, token)

	mut table := clitable.Table{}

	table.add_column('Month')
	table.add_column('Bandwidth (GB)')
	table.add_column('Cost (USD)')

	for stat in stats {
		table.add_row([stat.month, stat.bw.str(), stat.cost.str()])
	}

	// Total row
	total_bw := arrays.sum(stats.map(|s| s.bw)) or { panic(err) }
	total_cost := arrays.sum(stats.map(|s| s.cost)) or { panic(err) }
	table.add_row(['Total', total_bw.str(), total_cost.str()])

	clitable.print_table(table)
}

fn main() {
	mut fp := init_fp()

	// Set the API token from the environment variable if it exists
	env_vars := os.read_lines('.env') or { [] }
	if env_vars.len != 0 {
		os.setenv(bd_token_var, env_vars[0].split('=')[1], true)
	}
	bd_api_token := os.getenv(bd_token_var)

	// Parse the command line arguments
	token := fp.string('token', `t`, bd_api_token, 'The Bright Data API token.')
	months := fp.int('months', `m`, 12, 'The number of months to retrieve data for.')
	zone := fp.string('zone', `z`, '', 'The zone to retrieve data for.')

	finalize_fp(mut fp)!

	// Save new token to the environment variable and .env file
	if token == '' {
		println('A valid API token is required.')
		exit(1)
	} else {
		if token != bd_api_token {
			os.setenv(bd_token_var, token, true)
			text := 'BRIGHTDATA_API_TOKEN=${token}'
			os.write_file('.env', text)!
		}
	}

	if zone == '' {
		exit(0)
	}

	print_zone_report(months, zone, token)
}
