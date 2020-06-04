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

| Thing#1    | Thing #2 | Thing Three | URL                                                     |            | blerf       | woog      | HTTP_STATUS    | Thing_four |
| ---------- | -------- | ----------- | ------------------------------------------------------- | ---------- | ----------- | --------- | -------------- | ---------- |
| tribute    | balance  | population  | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar |            | needle      | effective | response       | infinite   |
| encourage  | egg      | slump       | https://www.google.ca/                                  | first      |             | urgency   | decorative     | connection |
| hammer     | slant    | tell        | https://www.google.ca/                                  | regulation | tumble      | premature | goalkeeper     | elbow      |
| adventure  | lily     | personality | https://www.google.ca/ (duplicate!)                     | pour       | proud       | lamb      | !@#$%!!http:// | threaten   |
| free       | traffic  | float       | \\\things.yup.blorg.idir.yup                            | muscle     | gate        | carry     | hover          | butterfly  |
| reckless   | read     | transparent | ftp://watermelon                                        | prison     | photography | owe       | barrier        | conscious  |
| sphere     | appear   | hostile     | eato.burrito (this is not a thing)                      | oh         | garbage     | reform    | dressing       | gradient   |
| breast     | horn     | frequency   | blerf.blorf                                             | brink      | shaft       | award     | agriculture    | lawyer     |
| landowner  | suite    | gift        | https://www.facebook.com/marketplace                    | kid        | hip         | accept    | leg            | album      |
| hypothesis |          | clerk       | https://thepooter.com/                                  | tragedy    | retain      | decrease  | verdict        | reduction  |
| umbrella   | leaf     | mislead     | https://thepooter.com/                                  | conviction | wrap        | position  | shatter        | reflection |
| sweet      | bike     | authority   | https://github.com/bcgov/site-status-checker            | beg        | alive       | seem      | ratio          | margin     |

Sample run
```bash
./count.sh sites.csv
```

| Thing#1        | Thing #2 | Thing Three | URL                                                     |            | blerf       | woog      | HTTP_STATUS | Thing_four |
| -------------- | -------- | ----------- | ------------------------------------------------------- | ---------- | ----------- | --------- | ----------- | ---------- |
| tribute        | balance  | population  | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar |            | needle      | effective | 503         | infinite   |
| encourage      | egg      | slump       | https://www.google.ca/                                  | first      |             | urgency   | 200         | connection |
| hammer         | slant    | tell        | https://www.google.ca/                                  | regulation | tumble      | premature | 200         | elbow      |
| adventure      | lily     | personality | https://www.google.ca/ (duplicate!)                     | pour       | proud       | lamb      | 200         | threaten   |
| free           | traffic  | float       | \\\things.yup.blorg.idir.yup                            | muscle     | gate        | carry     | Excluded    | butterfly  |
| reckless       | read     | transparent | ftp://watermelon                                        | prison     | photography | owe       | Excluded    | conscious  |
| sphere         | appear   | hostile     | eato.burrito (this is not a thing)                      | oh         | garbage     | reform    | Unavailable | gradient   |
| breast         | horn     | frequency   | blerf.blorf                                             | brink      | shaft       | award     | Unavailable | lawyer     |
| landowner      | suite    | gift        | https://www.facebook.com/marketplace                    | kid        | hip         | accept    | 200         | album      |
| hypothesis     |          | clerk       | https://thepooter.com/                                  | tragedy    | retain      | decrease  | 200         | reduction  |
| umbrella       | leaf     | mislead     | https://thepooter.com/                                  | conviction | wrap        | position  | 200         | reflection |
| sweet          | bike     | authority   | https://github.com/bcgov/site-status-checker            | beg        | alive       | seem      | 200         | margin     |
|                |
| 13 in / 13 out |

Sample run specifying a header that is not already present.

```bash
./count.sh sites.csv
```

| Thing#1        | Thing #2 | Thing Three | URL                                                     |            | blerf       | woog      | HTTP_STATUS    | Thing_four | CODEASUS    |
| -------------- | -------- | ----------- | ------------------------------------------------------- | ---------- | ----------- | --------- | -------------- | ---------- | ----------- |
| tribute        | balance  | population  | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar |            | needle      | effective | response       | infinite   | 503         |
| encourage      | egg      | slump       | https://www.google.ca/                                  | first      |             | urgency   | decorative     | connection | 200         |
| hammer         | slant    | tell        | https://www.google.ca/                                  | regulation | tumble      | premature | goalkeeper     | elbow      | 200         |
| adventure      | lily     | personality | https://www.google.ca/ (duplicate!)                     | pour       | proud       | lamb      | !@#$%!!http:// | threaten   | 200         |
| free           | traffic  | float       | \\\things.yup.blorg.idir.yup                            | muscle     | gate        | carry     | hover          | butterfly  | Excluded    |
| reckless       | read     | transparent | ftp://watermelon                                        | prison     | photography | owe       | barrier        | conscious  | Excluded    |
| sphere         | appear   | hostile     | eato.burrito (this is not a thing)                      | oh         | garbage     | reform    | dressing       | gradient   | Unavailable |
| breast         | horn     | frequency   | blerf.blorf                                             | brink      | shaft       | award     | agriculture    | lawyer     | Unavailable |
| landowner      | suite    | gift        | https://www.facebook.com/marketplace                    | kid        | hip         | accept    | leg            | album      | 200         |
| hypothesis     |          | clerk       | https://thepooter.com/                                  | tragedy    | retain      | decrease  | verdict        | reduction  | 200         |
| umbrella       | leaf     | mislead     | https://thepooter.com/                                  | conviction | wrap        | position  | shatter        | reflection | 200         |
| sweet          | bike     | authority   | https://github.com/bcgov/site-status-checker            | beg        | alive       | seem      | ratio          | margin     | 200         |
|                |
| 13 in / 13 out |


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