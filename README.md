# Hubot IONapp Script

[![Build Status](https://travis-ci.org/bogdal/hubot-ionapp.svg?branch=master)](https://travis-ci.org/bogdal/hubot-ionapp)
[![npm version](https://badge.fury.io/js/hubot-ionapp.svg)](http://badge.fury.io/js/hubot-ionapp)

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
Some of the commands require a token generated by the administrator.

## Usage

### Returns a list of users who are absent
    hubot who's absent

### Returns a list of users who will be absent on specified day
    hubot who'll be absent tomorrow
    hubot who'll be absent on Friday
    hubot who'll be absent on Feb 28
    hubot who'll be absent on 2015-02-14


### Displays a list of IONapp team members and chat users mapped with them
    hubot show me the team


### Maps chat user to the IONapp username
    hubot remember me as abogdal


### Adds a home office requests
    hubot I will be working at home on Monday
    hubot I will be working at home on Feb 10 to 14

It covers all work time windows in specified date range. This command requires `admin` auth token.

## Docker Compose

Docker and [docker-compose](https://docs.docker.com/compose/install/) are required to be installed.

    $ docker-compose build
    $ docker-compose run hubot
    mybot> mybot who's absent
