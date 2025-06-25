#!/bin/bash
docker-compose up -d
echo "Services started!"
echo ""
echo "To get your ngrok public address for SIP over TCP, run:"
echo "  docker logs ngrok 2>&1 | grep 'url='"
echo ""
echo "Use the address shown (e.g., tcp://2.tcp.ngrok.io:xxxxx) as your SIP server (TCP transport only)."
