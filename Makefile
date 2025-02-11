INSTALL_DIR := /usr/local/bin
SCRIPT_NAME := wg-monitor.pl
SYSTEMD_DIR := /etc/systemd/system
SERVICE_FILE := wg-monitor.service
TIMER_FILE := wg-monitor.timer

all:
	@echo "Run 'make install' to install $(SCRIPT_NAME) and systemd timer"

install: install-script install-systemd

install-script:
	install -m 755 $(SCRIPT_NAME) $(INSTALL_DIR)/$(SCRIPT_NAME)
	@echo "Installed $(SCRIPT_NAME) to $(INSTALL_DIR)"

install-systemd:
	# Install systemd service and timer unit files
	install -m 644 $(SERVICE_FILE) $(SYSTEMD_DIR)/$(SERVICE_FILE)
	install -m 644 $(TIMER_FILE) $(SYSTEMD_DIR)/$(TIMER_FILE)
	@echo "Installed systemd service and timer files to $(SYSTEMD_DIR)"
	
	# Enable and start the systemd timer
	systemctl daemon-reload
	systemctl enable wg-monitor.timer
	@echo "Enabled wg-monitor timer"

uninstall: uninstall-script uninstall-systemd

uninstall-script:
	rm -f $(INSTALL_DIR)/$(SCRIPT_NAME)
	@echo "Uninstalled $(SCRIPT_NAME) from $(INSTALL_DIR)"

uninstall-systemd:
	# Disable the systemd timer before removing it
	systemctl disable wg-monitor.timer
	# Remove the systemd unit files
	rm -f $(SYSTEMD_DIR)/$(SERVICE_FILE)
	rm -f $(SYSTEMD_DIR)/$(TIMER_FILE)
	@echo "Uninstalled systemd timer and service from $(SYSTEMD_DIR)"

.PHONY: all install uninstall install-script install-systemd uninstall-script uninstall-systemd
