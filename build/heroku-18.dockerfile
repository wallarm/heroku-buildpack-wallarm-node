FROM heroku/heroku:18-build

ENV STACK=heroku-18

COPY build/build-nginx.sh build/build.sh /

CMD ["/build.sh"]
