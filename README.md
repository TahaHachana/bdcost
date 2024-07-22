# bdcost

A simple CLI app that retrieves and displays cost and bandwidth consumption details for a Bright Data zone.

## Configuration

A Bright Data API token is required to use this app. You can obtain one by following the instructions [here](https://docs.brightdata.com/api-reference/unlocker/api_token). Please note that the token is saved as plain text in a `.env` file.

Set the API token by running the following command:

```bash
$ ./bdcost -t <API_TOKEN>
```
## Options
* -m, --months `<int>`: the number of months to retrieve data for. Default is 12.
* -z, --zone `<string>`: the zone to retrieve data for.

## Usage

```bash
$ ./bdcost -z zone_name -m 3
```

### Output
```
Fetching data for zone zone_name from 2024-05-01 to 2024-05-31...
Fetching data for zone zone_name from 2024-06-01 to 2024-06-30...
Fetching data for zone zone_name from 2024-07-01 to 2024-07-31...
┌───────────┬────────────────┬────────────┐
│ Month     │ Bandwidth (GB) │ Cost (USD) │
├───────────┼────────────────┼────────────┤
│ May 2024  │ 131.5          │ 494.55     │
├───────────┼────────────────┼────────────┤
│ June 2024 │ 85.25          │ 320.59     │
├───────────┼────────────────┼────────────┤
│ July 2024 │ 58.93          │ 221.6      │
├───────────┼────────────────┼────────────┤
│ Total     │ 275.68         │ 1036.74    │
└───────────┴────────────────┴────────────┘
```

## Dependencies
* [clitable](https://vpm.vlang.io/packages/TahaHachana.clitable)