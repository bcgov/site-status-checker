# Site Status Checker

The provided script uses curl to record HTTP status codes from a CSV file containing web addresses.  Results are provided in a modified version of the original CSV file.  Tested on Fedora 32 Linux.

## Installation

There is no installation.  The script can be cloned or copied.  If copied make sure the new file is executable as below.

```bash
chmod +x count.sh
```

## Usage

Running the script without parameters provides some basic direction.

```bash
./count.sh 

   Reads a CSV file of websites (header=URL) and outputs their statuses (header=HTTP_STATUS)

     [TIMEOUT=10] ./count.sh ./input.csv [./results.csv]
```

As an example point the script to sample data in `sites.csv`.


```bash
./count.sh sites.csv 
```

Specify an output file by providing it as a parameter.
```bash
./count.sh sites.csv output-file.csv
```

### Input and Output Files

A CSV (comma separated value) is expected.  Call the input column header URL.  A second CSV file is created with the same contents, but adding results under the HTTP_STATUS column.  It will be created that column is not present.

* `URL` is the default input header
* `HTTP_STATUS` is the default output header

### Changing Default Behaviour

Input and output headers can be specified at runtime.

```bash
HEADER_IN=URL HEADER_OUT=HTTP_STATUS ./count.sh sites.csv
```

The default curl timeout as been set at 15 seconds, but may be changed as follows.

```bash
TIMEOUT=30 ./count.sh sites.csv
```

A verbose mode is provided for troubleshooting.

```bash
VERBOSE=true ./count.sh sites.csv 
```

Any combination of those variables can be specified.

```bash
VERBOSE=true TIMEOUT=30 HEADER_IN=URL HEADER_OUT=HTTP_STATUS ./count.sh sites.csv
```

### Understanding Output

Empty addresses and those containing `ftp://` or `\\` will be labeled `Excluded`.

Addresses that do not receive a response will be labeled `Unavailable`.

Otherwise HTTP response codes will be provided. `200`-codes indicate success.

Any other codes may be generalized as an error.  Redirections are handled silently.

Please see this [Wikipedia](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) article for a brief overview of HTTP status codes.

## Sample data

Sample sites.csv

| Won       | Too     | URL                                                     | Fore      | HTTP_STATUS |
| --------- | ------- | ------------------------------------------------------- | --------- | ----------- |
| sweet     | bike    | https://github.com/bcgov/site-status-checker            | margin    | 1           |
| encourage | egg     | https://www.google.ca/                                  |           | 2           |
| adventure | lily    | https://www.google.ca/ (duplicate!)                     | threaten  | 3           |
|           | traffic | \\things.yup.blorg.idir.yup                             | butterfly | 4           |
| reckless  | read    | ftp://watermelon                                        | conscious | 5           |
| sphere    | appear  | eato.burrito (this is not a thing)                      | gradient  |             |
| landowner | suite   | https://www.facebook.com/marketplace                    | album     | 7           |
| free      |         | https://farts.com/ (redirects to thepooter.com)         | reduction | 8           |
| tribute   | balance | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar | infinite  | 9           |
|           |

Sample run
```bash
./count.sh sites.csv
```

| Won            | Too     | URL                                                     | Fore      | HTTP_STATUS |
| -------------- | ------- | ------------------------------------------------------- | --------- | ----------- |
| sweet          | bike    | https://github.com/bcgov/site-status-checker            | margin    | 200         |
| encourage      | egg     | https://www.google.ca/                                  |           | 200         |
| adventure      | lily    | https://www.google.ca/ (duplicate!)                     | threaten  | 200         |
|                | traffic | \\things.yup.blorg.idir.yup                             | butterfly | Excluded    |
| reckless       | read    | ftp://watermelon                                        | conscious | Excluded    |
| sphere         | appear  | eato.burrito (this is not a thing)                      | gradient  | Unavailable |
| landowner      | suite   | https://www.facebook.com/marketplace                    | album     | 200         |
| free           |         | https://farts.com/ (redirects to thepooter.com)         | reduction | 200         |
| tribute        | balance | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar | infinite  | 405         |
|                |
| 10 in / 10 out |

Sample run specifying a header that is not already present.

```bash
HEADER_OUT=NEW ./count.sh sites.csv
```

| Won            | Too     | URL                                                     | Fore      | HTTP_STATUS | NEW         |
| -------------- | ------- | ------------------------------------------------------- | --------- | ----------- | ----------- |
| sweet          | bike    | https://github.com/bcgov/site-status-checker            | margin    | 1           | 200         |
| encourage      | egg     | https://www.google.ca/                                  |           | 2           | 200         |
| adventure      | lily    | https://www.google.ca/ (duplicate!)                     | threaten  | 3           | 200         |
|                | traffic | \\things.yup.blorg.idir.yup                             | butterfly | 4           | Excluded    |
| reckless       | read    | ftp://watermelon                                        | conscious | 5           | Excluded    |
| sphere         | appear  | eato.burrito (this is not a thing)                      | gradient  |             | Unavailable |
| landowner      | suite   | https://www.facebook.com/marketplace                    | album     | 7           | 200         |
| free           |         | https://farts.com/ (redirects to thepooter.com)         | reduction | 8           | 200         |
| tribute        | balance | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar | infinite  | 9           | 503         |
|                |
| 10 in / 10 out |

## Contributing

Please request features or issue corrections by submitting issues.

Pull requests are even better!  Contributions will be squashed on merge after review and acceptance.  Providing adequate description of changes makes this much easier.

Of course, please test thoroughly using `sites.csv` and any other CSV data.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Team

[Derek Roberts](https://github.com/derekroberts)

[Julian Subda](https://github.com/actionanalytics)

[Shivagani Murti](https://github.com/zoyavit)

## Attributions

[Matt Lewis](https://github.com/mplewis) for creating [csvtomd](https://csvtomd.com/), which formatted the CSV in this guide.  [Source](https://github.com/mplewis/csvtomd-web).

[Danny Guo](https://github.com/dguo/make-a-readme) for the starter [README.md](https://www.makeareadme.com) and guide.  [Source](https://github.com/dguo/make-a-readme).

## Security concerns

Please be aware is unsafe to provide confidential data to an online tool.