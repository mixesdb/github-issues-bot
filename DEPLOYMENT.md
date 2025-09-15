# GitHub Issues Bot - Deployment Guide

This guide covers multiple deployment options for running your Discord bot permanently on a server with automatic restart capabilities.

## Prerequisites

- Node.js 18+ installed on your server
- Your Discord bot token and GitHub credentials configured in `.env` file
- Server with root/sudo access

## Environment Variables

Create a `.env` file in the project root with the following variables:

```env
# Discord Bot Configuration
BOT_TOKEN=your_discord_bot_token_here
GUILD_ID=your_discord_guild_id_here

# GitHub Configuration
GITHUB_ACCESS_TOKEN=your_github_personal_access_token_here
GITHUB_USERNAME=your_github_username
GITHUB_REPOSITORY=your_repository_name
```

## Deployment Options

### Option 1: PM2 Process Manager (Recommended)

PM2 is a production-ready process manager that provides automatic restarts, monitoring, and logging.

#### Quick Deploy
```bash
# Make the deployment script executable
chmod +x deploy.sh

# Deploy with PM2
./deploy.sh pm2
```

#### Manual PM2 Setup
```bash
# Install PM2 globally
npm install -g pm2

# Install dependencies
npm install

# Build the project
npm run build

# Start the bot
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

#### PM2 Management Commands
```bash
# View logs
npm run pm2:logs

# Monitor processes
npm run pm2:monit

# Restart bot
npm run pm2:restart

# Stop bot
npm run pm2:stop

# View all processes
pm2 list

# View detailed info
pm2 show github-issues-bot
```

### Option 2: Docker Deployment

Docker provides containerized deployment with isolation and easy scaling.

#### Quick Deploy
```bash
# Deploy with Docker
./deploy.sh docker
```

#### Manual Docker Setup
```bash
# Build and start containers
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Restart containers
docker-compose restart
```

#### Docker Management Commands
```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f github-issues-bot

# Restart the bot
docker-compose restart github-issues-bot

# Update and restart
docker-compose down
docker-compose up --build -d
```

### Option 3: Systemd Service (Linux)

For Linux servers, you can use systemd for service management.

#### Setup Steps

1. **Create a dedicated user:**
```bash
sudo useradd -r -s /bin/false github-bot
```

2. **Deploy the application:**
```bash
# Create application directory
sudo mkdir -p /opt/github-issues-bot

# Copy files
sudo cp -r . /opt/github-issues-bot/

# Set ownership
sudo chown -R github-bot:github-bot /opt/github-issues-bot

# Install dependencies and build
cd /opt/github-issues-bot
sudo -u github-bot npm install
sudo -u github-bot npm run build
```

3. **Install systemd service:**
```bash
# Copy service file
sudo cp github-issues-bot.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
sudo systemctl enable github-issues-bot
sudo systemctl start github-issues-bot
```

#### Systemd Management Commands
```bash
# Check status
sudo systemctl status github-issues-bot

# View logs
sudo journalctl -u github-issues-bot -f

# Restart service
sudo systemctl restart github-issues-bot

# Stop service
sudo systemctl stop github-issues-bot

# Disable auto-start
sudo systemctl disable github-issues-bot
```

## Monitoring and Maintenance

### Health Checks

All deployment methods include health monitoring:

- **PM2**: Automatic restart on crashes, memory monitoring
- **Docker**: Health check every 30 seconds
- **Systemd**: Automatic restart with 10-second delay

### Log Management

- **PM2**: Logs stored in `./logs/` directory
- **Docker**: Use `docker-compose logs` to view logs
- **Systemd**: Use `journalctl` to view logs

### Updating the Bot

1. Pull latest changes
2. Update dependencies: `npm install`
3. Rebuild: `npm run build`
4. Restart the service:
   - PM2: `pm2 restart github-issues-bot`
   - Docker: `docker-compose restart`
   - Systemd: `sudo systemctl restart github-issues-bot`

## Troubleshooting

### Common Issues

1. **Bot not starting:**
   - Check environment variables in `.env`
   - Verify Discord bot token is valid
   - Check GitHub token permissions

2. **Permission errors:**
   - Ensure proper file ownership
   - Check user permissions for systemd

3. **Memory issues:**
   - Monitor memory usage
   - Adjust memory limits in configuration

### Debugging

```bash
# PM2 debugging
pm2 logs github-issues-bot --lines 100

# Docker debugging
docker-compose logs --tail=100 github-issues-bot

# Systemd debugging
sudo journalctl -u github-issues-bot --since "1 hour ago"
```

## Security Considerations

- Use environment variables for sensitive data
- Run services with minimal privileges
- Keep dependencies updated
- Monitor logs for suspicious activity
- Use firewall rules to restrict access

## Performance Optimization

- Monitor memory usage and adjust limits
- Use PM2 cluster mode for high availability
- Consider load balancing for multiple instances
- Implement proper logging rotation

## Backup and Recovery

- Backup your `.env` file securely
- Backup PM2 configuration: `pm2 save`
- Backup Docker volumes if using persistent data
- Document your deployment configuration
