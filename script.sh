#!/bin/bash
# Simple Asterisk + ngrok Docker setup (with PJSIP over TCP)
set -e

echo "Setting up Asterisk + ngrok..."

# Create directories
mkdir -p asterisk-setup/{asterisk,ngrok}
cd asterisk-setup

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  asterisk:
    image: mlan/asterisk:latest
    container_name: asterisk
    restart: unless-stopped
    ports:
      - "5060:5060/tcp"
      - "5060:5060/udp"
      - "10000-10099:10000-10099/udp"
    volumes:
      - ./asterisk:/etc/asterisk
    networks:
      - pbx-net

  ngrok:
    image: ngrok/ngrok:latest
    container_name: ngrok
    restart: unless-stopped
    environment:
      # Set your ngrok authtoken here (https://dashboard.ngrok.com/get-started/your-authtoken)
      - NGROK_AUTHTOKEN=replace_me_with_your_ngrok_token
    command: tcp asterisk:5060
    networks:
      - pbx-net

networks:
  pbx-net:
    driver: bridge
EOF

# Create main asterisk configuration
cat > asterisk/asterisk.conf << 'EOF'
[directories]
astetcdir => /etc/asterisk
astmoddir => /usr/lib/asterisk/modules
astvarlibdir => /var/lib/asterisk
astdbdir => /var/lib/asterisk
astkeydir => /var/lib/asterisk
astdatadir => /var/lib/asterisk
astagidir => /var/lib/asterisk/agi-bin
astspooldir => /var/spool/asterisk
astrundir => /var/run/asterisk
astlogdir => /var/log/asterisk

[options]
verbose = 3
debug = 0
nofork = yes
quiet = no
timestamp = yes
console = yes
systemname = docker-asterisk
maxcalls = 1000
EOF

# Create modules configuration
cat > asterisk/modules.conf << 'EOF'
[modules]
autoload=yes
EOF

# Create basic PJSIP configuration (add TCP transport for ngrok)
cat > asterisk/pjsip.conf << 'EOF'
[global]
type=global
user_agent=docker-asterisk

[transport-tcp]
type=transport
protocol=tcp
bind=0.0.0.0:5060

[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0:5060
local_net=192.168.0.0/16
external_media_address=127.0.0.1
external_signaling_address=127.0.0.1

; Endpoint 1001
[1001]
type=endpoint
context=internal
disallow=all
allow=ulaw,alaw
auth=1001-auth
aors=1001
transport=transport-tcp

[1001-auth]
type=auth
auth_type=userpass
username=1001
password=password123

[1001]
type=aor
max_contacts=1

; Endpoint 1002
[1002]
type=endpoint
context=internal
disallow=all
allow=ulaw,alaw
auth=1002-auth
aors=1002
transport=transport-tcp

[1002-auth]
type=auth
auth_type=userpass
username=1002
password=password456

[1002]
type=aor
max_contacts=1
EOF

# Create extensions configuration for PJSIP
cat > asterisk/extensions.conf << 'EOF'
[general]
static=yes
writeprotect=no

[default]
exten => _X.,1,Hangup()

[internal]
; Internal extensions
exten => 1001,1,Dial(PJSIP/1001,20)
exten => 1001,n,Hangup()

exten => 1002,1,Dial(PJSIP/1002,20)
exten => 1002,n,Hangup()

; Echo test
exten => 123,1,Answer()
exten => 123,n,Echo()
exten => 123,n,Hangup()
EOF

# Create start script
cat > start.sh << 'EOF'
#!/bin/bash
docker-compose up -d
echo "Services started!"
echo ""
echo "To get your ngrok public address for SIP over TCP, run:"
echo "  docker logs ngrok 2>&1 | grep 'url='"
echo ""
echo "Use the address shown (e.g., tcp://2.tcp.ngrok.io:xxxxx) as your SIP server (TCP transport only)."
EOF

# Fix permissions
# sudo chown -R 100:101 asterisk
sudo chmod -R 644 asterisk/*.conf
sudo chmod 755 asterisk/ ngrok/
sudo chcon -Rt svirt_sandbox_file_t asterisk ngrok #this is for selinux for those who using fedora

ls -la asterisk/

chmod +x start.sh

echo "Setup complete!"
echo "PJSIP Extensions: 1001 (password123) and 1002 (password456)"
echo "Echo test: extension 123"
echo
echo "Run ./start.sh to start services"
echo "After startup, get your ngrok TCP address with:"
echo "  docker logs ngrok 2>&1 | grep 'url='"
echo
echo "Use this TCP address as the SIP server in your remote client (TCP transport only)."