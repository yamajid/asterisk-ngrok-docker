# asterisk-ngrok-docker

# Asterisk + ngrok Docker Setup

A simple Docker-based Asterisk PBX setup with ngrok tunneling for public SIP access over TCP. This project provides a ready-to-use VoIP server that can be accessed remotely through ngrok's secure tunneling service.

## 🚀 Features

- **Asterisk PBX** running in Docker container
- **ngrok TCP tunnel** for public SIP access
- **Pre-configured extensions** (1001, 1002) with authentication
- **Echo test extension** (123) for testing
- **TCP transport** optimized for ngrok tunneling
- **Easy setup** with automated configuration scripts

## 📋 Prerequisites

- Docker and Docker Compose installed
- ngrok account and auth token ([Get yours here](https://dashboard.ngrok.com/get-started/your-authtoken))
- Basic understanding of SIP/VoIP concepts

## 🛠️ Quick Setup

### Option 1: Use Existing Project Files

1. **Clone this repository:**
   ```bash
   git clone <repository-url>
   cd asterisk-ngrok-docker
   ```

2. **Set your ngrok auth token:**
   ```bash
   export NGROK_AUTHTOKEN=your_ngrok_token_here
   ```
   Or edit `docker-compose.yml` and replace `${NGROK_AUTHTOKEN}` with your actual token.

3. **Start the services:**
   ```bash
   ./start.sh
   ```

### Option 2: Automated Setup from Scratch

1. **Run the setup script:**
   ```bash
   chmod +x script.sh
   ./script.sh
   ```

2. **Update ngrok token:**
   Edit `docker-compose.yml` and replace `replace_me_with_your_ngrok_token` with your actual ngrok auth token.

3. **Start services:**
   ```bash
   ./start.sh
   ```

## 📁 Project Structure

```
.
├── asterisk/
│   ├── asterisk.conf      # Main Asterisk configuration
│   ├── extensions.conf    # Dialplan and extension routing
│   ├── modules.conf       # Module loading configuration
│   └── pjsip.conf        # SIP endpoints and transport settings
├── ngrok/
│   └── ngrok.yml         # ngrok tunnel configuration
├── docker-compose.yml    # Docker services definition
├── script.sh            # Automated setup script
└── start.sh             # Service startup script
```

## 🔧 Configuration

### SIP Extensions

The setup includes two pre-configured SIP extensions:

| Extension | Username | Password    | Context  |
|-----------|----------|-------------|----------|
| 1001      | 1001     | password123 | internal |
| 1002      | 1002     | password456 | internal |

### Special Extensions

- **123**: Echo test - useful for testing audio connectivity

### Transport Configuration

- **TCP Transport**: Port 5060 (optimized for ngrok)
- **UDP Transport**: Port 5060 (local network)
- **RTP Ports**: 10000-10099 (for audio streams)

## 🌐 Getting Your Public SIP Address

After starting the services, get your public ngrok address:

```bash
docker logs ngrok 2>&1 | grep 'url='
```

You'll see output like:
```
url=tcp://2.tcp.ngrok.io:12345
```

Use this TCP address in your SIP client configuration.

## 📱 SIP Client Configuration

Configure your SIP client with:

- **Server**: Your ngrok TCP address (e.g., `2.tcp.ngrok.io:12345`)
- **Transport**: TCP only
- **Username**: 1001 or 1002
- **Password**: password123 or password456
- **Domain**: Your ngrok hostname

### Recommended SIP Clients

- **Desktop**: Linphone, Jami, X-Lite
- **Mobile**: Linphone (iOS/Android), CSipSimple (Android)
- **Web**: JsSIP-based clients

## 🔍 Troubleshooting

### Check Service Status
```bash
docker-compose ps
```

### View Asterisk Logs
```bash
docker logs asterisk
```

### View ngrok Logs
```bash
docker logs ngrok
```

### Test Internal Connectivity
```bash
# Connect to Asterisk console
docker exec -it asterisk asterisk -r

# Check SIP endpoints
pjsip show endpoints

# Check registrations
pjsip show registrations
```

### Common Issues

1. **ngrok tunnel not working**: Verify your auth token is correct
2. **SIP registration fails**: Check username/password and ensure TCP transport is used
3. **No audio**: Verify RTP port range (10000-10099) is accessible
4. **Connection refused**: Ensure Docker services are running

## 🔒 Security Considerations

- Change default passwords in `asterisk/pjsip.conf`
- Consider using strong authentication methods
- Monitor ngrok usage for unexpected traffic
- Use ngrok's access controls if needed
- Keep Docker images updated

## 🛡️ Firewall Configuration

If running behind a firewall, ensure these ports are open:

- **TCP 5060**: SIP signaling (mapped through ngrok)
- **UDP 10000-10099**: RTP media streams (local network)

## 📚 Useful Commands

```bash
# Stop services
docker-compose down

# Restart services
docker-compose restart

# Update containers
docker-compose pull
docker-compose up -d

# View real-time logs
docker-compose logs -f
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This setup is intended for development and testing purposes. For production use, implement proper security measures, monitoring, and backup strategies.

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Docker and ngrok logs
3. Open an issue in this repository
4. Consult [Asterisk documentation](https://wiki.asterisk.org/)
5. Check [ngrok documentation](https://ngrok.com/docs)

---

Made with ❤️ for the VoIP community
