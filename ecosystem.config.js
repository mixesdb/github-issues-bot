module.exports = {
  apps: [
    {
      name: 'github-issues-bot',
      script: 'dist/index.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production'
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      // Restart the app if it uses more than 1GB of memory
      max_memory_restart: '1G',
      // Restart the app if it crashes
      min_uptime: '10s',
      max_restarts: 10,
      // Wait 5 seconds before restarting
      restart_delay: 5000,
      // Kill timeout
      kill_timeout: 5000,
      // Listen timeout
      listen_timeout: 10000,
      // Graceful shutdown
      kill_retry_time: 100
    }
  ]
};
