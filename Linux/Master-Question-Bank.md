# Process & Service Troubleshooting

## Commands 

`ps -ef    `  -
`top       `  -
`htop      `  -
`pgrep     `  -
`kill      `  -
`kill -9   `  -
`systemctl `  -
`journalctl`  -

### Q1. Application is down. What will you check?  
`systemctl status app`  to Check service status
`ps -ef | grep aap` to Check process
`journalctl -u app` or `tail -100 app.log`  to Check logs
`df -h` Check disk
`free -m` or `top` to Check memory
`ping`, `curl` and `nslookup` to Check network
`systemctl restart app` Restart service if required

### Q2. Service is consuming very high CPU.  
top  
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu 

### Q3. How to restart failed service?  
systemctl restart nginx  
systemctl status nginx  

---

# Disk, Memory & File System

## Commands 

`df -h   `  - 
`du -sh *`  - 
`free -m `  -
`lsblk   `  -
`mount   `  -
`find    `  -

### Disk 100% Full  
df -h  
du -sh /*

### Memory Issue
free -m  
top
Look for: 
High RAM usage  
OOM Kill  
Memory leaks  
 
### Find large files
find / -type f -size +500M  

### Find files older than 100 days
find /path -type f -mtime +100

### Delete log files older than 30 days
find /var/log -type f -mtime +30 -delete

---

# Network & Logs

## Commands 

 `ping       `  -
`curl       `  -
`wget       `  -
`nslookup   `  -
`dig        `  -
`netstat    `  -
`ss         `  -
`traceroute `  -
`telnet     `  -

### Website inaccessible.  
Check:  
ping hostname  
nslookup hostname  
curl -v hostname  

### Application can't connect to DB.  
Check port:  
`telnet db-server 5432`
or
`nc -zv db-server 5432`

### Check listening ports  
`ss -tulpn` or `netstat -tulpn`

## Log Analysis

### Search Errors:  
`grep ERROR app.log`

### Count errors:  
`grep ERROR app.log | wc -l`

### Last 100 lines:
`tail -100 app.log`


### Live monitoring:  
tail -f aap.log

---

## Application is down. What will be your approach?
