FROM heroku/cedar:14

ENV STACK=cedar-14

COPY build/build.sh /

CMD ["/build.sh"]
