# Hubot IONapp Script

[![IONapp](https://ionapp.com/static/images/logo-color.png)](https://ionapp.com)


## Installation

Run the npm install command...

    npm install hubot-ionapp


Add the script to the `external-scripts.json` file

    ["hubot-ionapp"]

## Configuration

### Set the environment variables
    export HUBOT_IONAPP_COMPANY_NAME='my_company'
    export HUBOT_IONAPP_AUTH_TOKEN='1234..'

To obtain `auth token` go to `https://<company name>.ionapp.com/api/tokens/` and generate one.

## Usage

### Returns a list of users who are absent
    hubot who's absent

### Returns a list of users who will be absent on specified day
    hubot who'll be absent tomorrow
    hubot who'll be absent on Friday
    hubot who'll be absent on Feb 28
    hubot who'll be absent on 2015-02-14
    
### Returns a list of users who requested a home office
    hubot who's at home
    hubot who's working at home
    
### Returns a list of users who requested a home office on specified day
    hubot who'll be working at home on Friday


### Displays a list of IONapp team members
    hubot show me the team


### Maps current user to the IONapp username
    hubot remember me as abogdal

    
### Adds a home office requests
    hubot I will be working at home on Monday
    hubot I will be working at home on Feb 10 to 14
    
It covers all work time windows in specified date range.