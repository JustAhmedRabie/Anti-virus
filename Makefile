DIR = monitored
MALICIOUS_DIR = malicious
INTERVAL = 5

all: pre-build antivirus

pre-build:
	mkdir -p $(DIR)
	mkdir -p $(MALICIOUS_DIR)

antivirus: pre-build
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

restore: pre-build
	./restore.sh $(DIR) $(MALICIOUS_DIR)
