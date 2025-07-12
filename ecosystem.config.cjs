module.exports = {
  apps: [{
    name: 'procurement-assistant',
    script: 'npm',
    args: 'run preview',
    cwd: '/opt/procurement-assistant',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3855
    },
    error_file: '/var/log/pm2/procurement-assistant-error.log',
    out_file: '/var/log/pm2/procurement-assistant-out.log',
    log_file: '/var/log/pm2/procurement-assistant-combined.log',
    time: true
  }]
}; 