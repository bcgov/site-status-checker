# Site Status Checker

Reads web addresses from a CSV file and use curl to record their HTTP status codes.  Results are provided in a modified version of the original CSV file.  Created and tested on Fedora 32 Linux.

## Usage

### Installation

There is no installation.  The script can be cloned or copied.  If copied make sure the new file is executable.

Clone medthod.

```bash
git clone https://github.com/bcgov/site-status-checker
cd site-status-checker
```

Copy and paste method.

```bash
<copy and paste into count.sh>
chmod +x count.sh
```

### Parameters

Run the script without parameters for basic help.

```bash
./count.sh 

   Reads a CSV file of websites (header=URL) and outputs their statuses (header=HTTP_STATUS)

     [TIMEOUT=10] ./count.sh ./input.csv [./results.csv]
```

Required: Consume an input file with the first parameter.

```bash
./count.sh sites.csv 
```

Optional: Change the default file output from `results.csv` with the second parameter.

```bash
./count.sh sites.csv output-file.csv
```

### Input and Output Files

A CSV (comma separated value) is expected.  Call the input column header `URL`.  A second CSV file is created with the same contents, but adding results under the `HTTP_STATUS` column.  If not present the column will be created.

`URL` is the default input header.

`HTTP_STATUS` is the default output header.

### Changing Default Behaviour

Input and output headers can be specified at runtime.

```bash
HEADER_IN=URL HEADER_OUT=HTTP_STATUS ./count.sh sites.csv
```

The default curl timeout has been set at 15 seconds, but may be changed as follows.

```bash
TIMEOUT=30 ./count.sh sites.csv
```

A verbose mode is provided for troubleshooting.

```bash
VERBOSE=true ./count.sh sites.csv 
```

Any combination of variables and optional parameters can be specified.

```bash
VERBOSE=true TIMEOUT=30 HEADER_IN=URL HEADER_OUT=HTTP_STATUS ./count.sh sites.csv output-file.csv
```

## Understanding Output

### Excluded

Empty and filtered out addresses will be labeled `Excluded`.

FTP sites and local file shares cannot be used.  E.g. `ftp://` or `\\`.

### No Response

Addresses that do not receive a response will be labeled `No Response`.

This may mean that the address is wrong, has been moved without providing a redirect or is down.

### HTTP Codes

Sites that do respond will receive HTTP status codes.  Please see Wikipedia for a [List of HTTP status codes](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes).


#### 200 - Success Codes

`200`-codes indicate success.  Any other codes may be generalized as an error.

#### 400 and 500 - Error Codes

`400`-codes indicate client errors.  They are usually related to rights or incorrect addresses.

`500`-codes indicate server errors.  The site could be down, overloaded, timing out othrewise unavailable.

#### 100 and 300 - Unreported Codes

`100`-codes are informational.  These will not be reported.

`300` codes are redirections.  The will be silently followed, resulting in 200, 400 or 500 codes.

## Sample data

Sample data.

| Won       | Too     | URL                                                     | Fore      | HTTP_STATUS |
| --------- | ------- | ------------------------------------------------------- | --------- | ----------- |
| sweet     | bike    | https://github.com/bcgov/site-status-checker            | margin    | 1           |
| encourage | egg     | https://www.google.ca/                                  |           | 2           |
| adventure | lily    | https://www.google.ca/ (duplicate!)                     | threaten  | 3           |
|           | traffic | \\\things.yup.blorg.idir.yup                             | butterfly | 4           |
| reckless  | read    | ftp://watermelon                                        | conscious | 5           |
| sphere    | appear  | eato.burrito (this is not a thing)                      | gradient  |             |
| landowner | suite   | https://www.facebook.com/marketplace                    | album     | 7           |
| free      |         | https://farts.com/ (redirects to thepooter.com)         | reduction | 8           |
| tribute   | balance | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar | infinite  | 9           |
|           |

Sample run.

```bash
./count.sh sites.csv
```

| Won            | Too     | URL                                                     | Fore      | HTTP_STATUS |
| -------------- | ------- | ------------------------------------------------------- | --------- | ----------- |
| sweet          | bike    | https://github.com/bcgov/site-status-checker            | margin    | 200         |
| encourage      | egg     | https://www.google.ca/                                  |           | 200         |
| adventure      | lily    | https://www.google.ca/ (duplicate!)                     | threaten  | 200         |
|                | traffic | \\\things.yup.blorg.idir.yup                             | butterfly | Excluded    |
| reckless       | read    | ftp://watermelon                                        | conscious | Excluded    |
| sphere         | appear  | eato.burrito (this is not a thing)                      | gradient  | Unavailable |
| landowner      | suite   | https://www.facebook.com/marketplace                    | album     | 200         |
| free           |         | https://farts.com/ (redirects to thepooter.com)         | reduction | 200         |
| tribute        | balance | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar | infinite  | 405         |
|                |
| 10 in / 10 out |

Sample run appending a non-standard header.

```bash
HEADER_OUT=NEW ./count.sh sites.csv
```

| Won            | Too     | URL                                                     | Fore      | HTTP_STATUS | NEW         |
| -------------- | ------- | ------------------------------------------------------- | --------- | ----------- | ----------- |
| sweet          | bike    | https://github.com/bcgov/site-status-checker            | margin    | 1           | 200         |
| encourage      | egg     | https://www.google.ca/                                  |           | 2           | 200         |
| adventure      | lily    | https://www.google.ca/ (duplicate!)                     | threaten  | 3           | 200         |
|                | traffic | \\\things.yup.blorg.idir.yup                             | butterfly | 4           | Excluded    |
| reckless       | read    | ftp://watermelon                                        | conscious | 5           | Excluded    |
| sphere         | appear  | eato.burrito (this is not a thing)                      | gradient  |             | Unavailable |
| landowner      | suite   | https://www.facebook.com/marketplace                    | album     | 7           | 200         |
| free           |         | https://farts.com/ (redirects to thepooter.com)         | reduction | 8           | 200         |
| tribute        | balance | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar | infinite  | 9           | 503         |
|                |
| 10 in / 10 out |

## Attributions

### Cloud Pathfinder Team

[Julian Subda](https://github.com/actionanalytics), Product Owner

[Shivagani Murti](https://github.com/zoyavit), Technical Administrator

[Derek Roberts](https://github.com/derekroberts), DevOps Specialst

### Thanks

[Matt Lewis](https://github.com/mplewis), creator of [csvtomd-web](https://github.com/mplewis/csvtomd-web), which formatted the CSV in this guide

[Danny Guo](https://github.com/dguo/make-a-readme), for the starter [README.md](https://github.com/dguo/make-a-readme)

## Contributing

### Issues

Please request features or issue corrections by submitting issues.

### Pull Requests

Pull requests are even better!  Contributions will be squashed on merge after review and acceptance.  Providing adequate description of changes makes this much easier.

Of course, please test thoroughly using `sites.csv` and any other CSV data.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Security concerns

Please be aware is unsafe to provide confidential data to an online tool.
