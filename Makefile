DIR ?= monitored
MALICIOUS_DIR ?= malicious
INTERVAL ?= 5

.PHONY: all pre-build antivirus restore

all: pre-build antivirus

pre-build:
	mkdir -p $(MALICIOUS_DIR)

antivirus: pre-build
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

