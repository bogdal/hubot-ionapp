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

### Returns a list of users who are absent at work
    hubot who's absent
    
### Returns a list of users who will be absent tomorrow
    hubot who'll be absent tomorrow
    
### Returns a list of users who will be absent on specified day (yyyy-mm-dd)
    hubot who'll be absent on <date>

