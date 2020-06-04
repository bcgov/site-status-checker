# Site Status Checker

The provided script uses curl to record HTTP status codes from a CSV file containing web addresses.  Results are provided in a modified version of the original CSV file.  Tested on Fedora 32 Linux.

## Installation

There is no installation.  The script can be cloned or copied.  If copied make sure the new file is executable as below.

```bash
chmod +x FILE_NAME.sh
```

## Usage

Running the script without parameters provides some basic direction.

```bash
./count.sh 

   Reads a CSV file of websites (header=URL) and outputs their statuses (header=HTTP_STATUS)

     [TIMEOUT=10] ./count.sh ./input.csv [./results.csv]
```

A CSV is required as input.  By default that CSV is expected to contain web addresses under the heading URL.  Output is placed in `results.csv`.

If the HTTP_CODE (or otherwise specified) header is not presend it will be appended as the new final column.

```bash
./count.sh sites.csv 
```

Specify an output file by providing it as a parameter.
```bash
./count.sh sites.csv output-file.csv
```

Further defaults for input header, output header and curl timeout may be changed with runtime variables.

```bash
TIMEOUT=30 HEADER_IN=URL HEADER_OUT=HTTP_CODE ./count.sh sites.csv 
```

A verbose mode is provided for troubleshooting.

```bash
./count.sh sites.csv 
```

## Sample data

Sample sites.csv

| Thing#1    | Thing #2 | Thing Three | URL                                                     |            |  blerf      | woog      | HTTP_STATUS    | Thing_four |
| ---------- | -------- | ----------- | ------------------------------------------------------- | ---------- | ----------- | --------- | -------------- | ---------- |
| tribute    | balance  | population  | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar |            | needle      | effective | response       | infinite   |
| encourage  | egg      | slump       | https://www.google.ca/                                  | first      |             | urgency   | decorative     | connection |
| hammer     | slant    | tell        | https://www.google.ca/                                  | regulation | tumble      | premature | goalkeeper     | elbow      |
| adventure  | lily     | personality | https://www.google.ca/ (duplicate!)                     | pour       | proud       | lamb      | !@#$%!!http:// | threaten   |
| free       | traffic  | float       | \\\things.yup.blorg.idir.yup                             | muscle     | gate        | carry     | hover          | butterfly  |
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

| Thing#1        | Thing #2 | Thing Three | URL                                                     |            |  blerf      | woog      | HTTP_STATUS | Thing_four |
| -------------- | -------- | ----------- | ------------------------------------------------------- | ---------- | ----------- | --------- | ----------- | ---------- |
| tribute        | balance  | population  | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar |            | needle      | effective | 503         | infinite   |
| encourage      | egg      | slump       | https://www.google.ca/                                  | first      |             | urgency   | 200         | connection |
| hammer         | slant    | tell        | https://www.google.ca/                                  | regulation | tumble      | premature | 200         | elbow      |
| adventure      | lily     | personality | https://www.google.ca/ (duplicate!)                     | pour       | proud       | lamb      | 200         | threaten   |
| free           | traffic  | float       | \\things.yup.blorg.idir.yup                             | muscle     | gate        | carry     | Excluded    | butterfly  |
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

| Thing#1        | Thing #2 | Thing Three | URL                                                     |            |  blerf      | woog      | HTTP_STATUS    | Thing_four | CODEASUS    |
| -------------- | -------- | ----------- | ------------------------------------------------------- | ---------- | ----------- | --------- | -------------- | ---------- | ----------- |
| tribute        | balance  | population  | www.amazon.ca/dp/B06XR8LS2L?keywords=parrot&pirate=yaar |            | needle      | effective | response       | infinite   | 503         |
| encourage      | egg      | slump       | https://www.google.ca/                                  | first      |             | urgency   | decorative     | connection | 200         |
| hammer         | slant    | tell        | https://www.google.ca/                                  | regulation | tumble      | premature | goalkeeper     | elbow      | 200         |
| adventure      | lily     | personality | https://www.google.ca/ (duplicate!)                     | pour       | proud       | lamb      | !@#$%!!http:// | threaten   | 200         |
| free           | traffic  | float       | \\things.yup.blorg.idir.yup                             | muscle     | gate        | carry     | hover          | butterfly  | Excluded    |
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

Of course, please test thoroughly using `sites.csv` or any other CSV data.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Team

[Derek Roberts](https://github.com/derekroberts), the original author of this tool.

[Julian Subda](https://github.com/actionanalytics) for requesting and enabling its creation.

[Shivagani Murti](https://github.com/zoyavit) for technical and administrative assistance.

## Attributions

[Matt Lewis](https://github.com/mplewis) for creating [csvtomd](https://csvtomd.com/), which formatted the CSV in this guide.  [Source](https://github.com/mplewis/csvtomd-web).

[Danny Guo](https://github.com/dguo/make-a-readme) for the starter [README.md and guide](https://www.makeareadme.com).  [Source](https://github.com/dguo/make-a-readme)

## Security concerns

Please be aware is unsafe to provide confidential data to an online tool!