# Process & Service Troubleshooting

## Commands 

`ps -ef    `  → Displays all running processes.  
`ps -ef | grep nginx` Find the nginx process.  
`top  `        → Shows real-time CPU and memory usage.  
`htop `        → Interactive process monitoring tool.  
`pgrep`        → Finds PID using process name.  
`pgrep`        → Get the PID of the nginx process.  
`kill  `       → Gracefully terminates a process.  
`kill 1234`    → Stop process with PID 1234.  
`kill -9 `     → Forcefully kills an unresponsive process.  
`kill -9 1234` → Immediately terminate process 1234.  
`systemctl `   → Manages system services.  
`systemctl status nginx` → Check nginx service status.  
`journalctl`             → Views system and service logs.  
`journalctl -u nginx`    → View logs for the nginx service.  


### Q1. Application is down. What will you check?  
`systemctl status app`  to Check service status  
`ps -ef | grep aap` to Check process  
`journalctl -u app` or `tail -100 app.log`  to Check logs  
`df -h` Check disk  
`free -m` or `top` to Check memory  
`ping`, `curl` and `nslookup` to Check network  
`systemctl restart app` Restart service if required  

### Q2. Service is consuming very high CPU.  
`top`  
`ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu `

### Q3. How to restart failed service?  
`systemctl restart nginx  `  
`systemctl status nginx ` 

---

# Disk, Memory & File System

## Commands 

`df -h `             → Checks filesystem disk space usage.  
`du -sh *`           → Shows size of files and directories.  
`du -sh /var/log/*`  → Identify which log directory is consuming the most space.  
`free -m `           → Displays RAM and swap memory usage.  
`lsblk `             → Lists disks and partitions.  
`mount `             → Shows mounted filesystems.  
`mount | grep /data` → Verify whether the /data filesystem is mounted.  
`find `              → Searches for files and directories.  

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

`ping `                       → Tests network connectivity to a host.  
`ping google.com`             → Verify whether the server can reach Google.  
`curl `                       → Sends HTTP requests to websites or APIs.  
`curl http://app.company.com`  → Check whether the application is responding.  
`wget `                       → Downloads files from URLs.  
`wget http://app.cmpany.com/file.zip` → Download a file from the internet.  
`nslookup`                      → Resolves hostname to IP using DNS.  
`nslookup app.company.com`     → Verify DNS resolution for a website.  
`dig  `                        → Performs detailed DNS queries.  
`dig app.comany.com`           → Verify DNS resolution for a website.  
`netstat  `                    → Displays network connections and listening ports.  
`netstat -tulpn`               → Check which ports are listening on the server.  
`ss  `                         → Shows socket connections and listening ports.  
`ss -tulpn`                    → List all listening TCP and UDP ports.  
`traceroute`                   → Displays the network path to a destination.  
`traceroute google.com`        → Identify where network communication is failing.  
`telnet `                      → Tests connectivity to a specific port.  
`telnet dv-server 5432`        → Verify whether PostgreSQL port 5432 is reachable.  

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

## Website not opening?
ping app.company.com  
nslookup app.company.com  
curl http://app.company.com   
ss -tulpn  
telnet app.company.com 443  
traceroute app.company.com  

> This flow alone answers many support-engineer interview scenarios like "Application is inaccessible", "DNS issue", "Port issue", or "Network issue".

