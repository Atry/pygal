include Makefile.config
-include Makefile.custom.config

all: install lint check check-outdated

install:
	test -d $(VENV) || virtualenv $(VENV) -p $(PYTHON_VERSION)
	$(PIP) install --upgrade --no-cache --no-use-wheel pip setuptools -e .[test,docs] devcore

clean:
	rm -fr $(VENV)
	rm -fr *.egg-info

lint:
	$(PYTEST) --flake8 -m flake8 $(PROJECT_NAME)
	$(PYTEST) --isort -m isort $(PROJECT_NAME)

check:
	$(PYTEST) $(PROJECT_NAME) $(PYTEST_ARGS) --cov-report= --cov=pygal

check-outdated:
	$(PIP) list --outdated --format=columns

visual-check:
	$(PYTHON) demo/moulinrouge.py

gen-docs:
	cd docs && PYTHON_PATH=$(VENV) PATH=$(VENV)/bin:$(PATH) $(MAKE) rst html

release:
	git pull
	$(eval VERSION := $(shell PROJECT_NAME=$(PROJECT_NAME) $(VENV)/bin/devcore bump $(LEVEL)))
	git commit -am "Bump $(VERSION)"
	git tag $(VERSION)
	$(PYTHON) setup.py sdist bdist_wheel upload
	git push
	git push --tags
