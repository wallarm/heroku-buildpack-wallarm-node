all: heroku-16 heroku-18

heroku-16:
	docker build -t wallarm/heroku:16 -f build/heroku-16.dockerfile .
	docker run --rm --userns=host -v "`pwd`:/result" wallarm/heroku:16

heroku-18:
	docker build -t wallarm/heroku:18 -f build/heroku-18.dockerfile .
	docker run --rm --userns=host -v "`pwd`:/result" wallarm/heroku:18

.PHONY: all heroku-16 heroku-18
