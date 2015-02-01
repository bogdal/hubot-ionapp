# Hubot IONAPP Script

## Installation

Run the npm install command...

    npm install hubot-ionapp


Add the script to the `external-scripts.json` file

    ["hubot-ionapp"]

## Configuration

### Set the environment variables
    export HUBOT_IONAPP_COMPANY_NAME='my_company'
    export HUBOT_IONAPP_AUTH_TOKEN='1234..'

## Usage

### Returns a list of users who are absent today
    hubot who's absent

### Returns a list of users who will be absent on specified day
    hubot who'll be absent tomorrow
    hubot who'll be absent on Friday
    hubot who'll be absent on Feb 28
    hubot who'll be absent on 2015-02-14
