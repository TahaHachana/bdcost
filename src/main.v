module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args)

	fp.application(name)
	fp.version(version)
	fp.description(description)
	fp.skip_executable()

	env_var := os.read_lines('.env') or { [] }
	if env_var.len != 0 {
		os.setenv('BRIGHTDATA_API_TOKEN', env_var[0].split('=')[1], true)
	}
	bd_api_token := os.getenv('BRIGHTDATA_API_TOKEN')

	token := fp.string('token', `t`, bd_api_token, 'The Bright Data API token.')
	additional_args := fp.finalize()!

	if additional_args.len > 0 {
		println('Unprocessed arguments:\n${additional_args.join_lines()}')
	}

	if token == '' {
		println('A valid API token is required.')
		exit(1)
	} else {
		if token != bd_api_token {
			os.setenv('BRIGHTDATA_API_TOKEN', token, true)
			text := 'BRIGHTDATA_API_TOKEN=${token}'
			os.write_file('.env', text)!
		}
	}

	println('Token: ${os.getenv('BRIGHTDATA_API_TOKEN')}')
}
