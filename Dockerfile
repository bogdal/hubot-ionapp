FROM node:latest

RUN npm install -g yo generator-hubot
RUN useradd -ms /bin/bash hubot
USER hubot

WORKDIR /home/hubot
RUN yo hubot --defaults --name mybot

RUN echo "[\"hubot-ionapp\", \"hubot-help\"]" > external-scripts.json

RUN mkdir -p node_modules/hubot-ionapp
ADD index.coffee node_modules/hubot-ionapp/
ADD package.json node_modules/hubot-ionapp/
ADD src node_modules/hubot-ionapp/src/
ADD script node_modules/hubot-ionapp/script/

RUN cd node_modules/hubot-ionapp && npm install

CMD './bin/hubot'
