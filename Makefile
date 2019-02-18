all: cedar-14 heroku-16

cedar-14:
	docker build -t wallarm/heroku:14 -f build/cedar-14.dockerfile .
	docker run --rm --userns=host -v "`pwd`:/result" wallarm/heroku:14

heroku-16:
	docker build -t wallarm/heroku:16 -f build/heroku-16.dockerfile .
	docker run --rm --userns=host -v "`pwd`:/result" wallarm/heroku:16

.PHONY: all cedar-14 heroku-16
