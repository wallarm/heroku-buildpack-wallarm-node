FROM heroku/heroku:16

ENV STACK=heroku-16

COPY build/build.sh /

CMD ["/build.sh"]
