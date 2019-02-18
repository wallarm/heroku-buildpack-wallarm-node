FROM heroku/heroku:16-build

ENV STACK=heroku-16

COPY build/build-nginx.sh build/build.sh /

CMD ["/build.sh"]
