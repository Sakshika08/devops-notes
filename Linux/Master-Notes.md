### Variable
In variable do not add space before or after type `=` sign  
variable_name="you_name"

---

### set
`set -x` makes the terminal print every command it is running so you can see exactly what your script is doing step-by-step.
The `nproc` command prints the total number of processing units (CPU cores) available to the operating system or current process.
<img width="716" height="601" alt="image" src="https://github.com/user-attachments/assets/a939f8de-93ff-4e9e-b018-a5b72a87d624" />

The `set -e` command instructs the shell to exit the script instantly if any command fails or returns a non-zero exit status.
It acts as a safety net. Instead of continuing to run subsequent lines when something goes wrong (which can cause data corruption or unexpected behavior), the script stops immediately at the first error.

`set -o pipefail`
By default, in a pipeline command like dir1 | dir2 | dir3, the shell only checks if the very last command (dir3) succeeded. If a command in the middle fails (like dir2), the script completely ignores it and keeps going.Turning on pipefail forces the shell to look at the entire pipeline. If any command in the chain fails, the whole pipeline is treated as a failure. 
This is almost always combined with set -e (set -eo pipefail) to immediately stop a script if a pipeline crashes.

`set -e -o pipefail` (or set -eo pipefail): It tells the script to exit if any command fails (-e), and ensures that if a command fails inside a pipeline (like cmd1 | cmd2), the entire pipeline failure is caught.

`set -ex`: Combines exit-on-error (-e) with command tracing (-x) so you can see exactly which line crashed the script before it terminated.

---

## curl
Download a file and save it with its original name: `curl -O https://example.com`  
Use code with caution.Download a file and save it with a new name: `curl -o my_script.sh https://example.com`  
Use code with caution.View the raw HTML content or API data directly in the terminal: `curl https://github.com`  
Get the error line  from some remote location from log file: `curl <loaction of file (http)> | grep ERROR` 

### wget
Download file or website

`curl` is a flexible tool for sending and receiving data between a terminal and a server (great for APIs), while `wget` is a dedicated tool built strictly for downloading files and whole websites

---

## find
The find command is a powerful tool used to search for files and directories on a storage drive based on conditions like name, size, type, or modification date  

Syntax: `find [where to look] [how to look] [what to match]`  
Search by Name (Case-Insensitive): `find /home/user -iname "health.sh" `
Find and Delete Empty Folders:`find . -type d -empty -delete`  
Find Large Files (Greater than 100MB): `find /var/log -type f -size +100M`  


---
## sudo
`sudo -i` (Recommended): Logs you in as the root user and loads the root profile environment. It is the cleanest way to open a root shell.  
`sudo su -`: Uses your sudo privilege to execute the switch user (su) tool, changing you to the root user completely.  
`sudo -s`: Gives you a root shell, but keeps your current user environment variables (like your home directory).  
If you are trying to switch to a specific username instead of root, you would type `sudo -u username -s`.

---

## Conditions
[ condition ] is a Bash test expression used to evaluate conditions.  
Example: [ -e /etc/passwd ] checks whether the file /etc/passwd exists.  
[1 == 2] It is commonly used in if statements for decision making.  

### Common file test operators
-e file   # Exists  
-f file   # Regular file  
-d file   # Directory  
-r file   # Readable  
-w file   # Writable  
-x file   # Executable  

## `if` Loop
```
if [ condition-is-true ]
then
    echo "File exists"
elif [contion-is-true]
then
   echo "somthing"
else
    echo "File does not exist"
fi
```

Example compare two numbers using an if loop  
```
read -p "Enter first number: " num1
read -p "Enter second number: " num2

if [ $num1 > $num2 ]; then
  echo "$num1 is greater than $num2"
elif [ $num2 -gt $num1 ]; then
  echo "$num2 is greater than $num1"
esle
  echo "Both numbers are equal"
fi
```

---

## for Loop
```
for VARIABLE in ITEM1 ITEM2 ITEMN
do
    command(s)
done
```

` for i in {1,1000}; do echo $1; done`


### 1. How do you loop through all files in a directory
```
for file in *.txt
do
    cat $file
done
```
### 2. Loop Through Servers
```
for server in web1 web2 web3
do
    ssh $server "uptime"
done
```
Use case: Run commands on multiple servers.

### 3. Loop Through Kubernetes Pods
```
for pod in $(kubectl get pods -o name)
do
    kubectl describe $pod
done
```
Use case: Collect pod information.

### 4. Loop Through Docker Containers
for container in $(docker ps -q)
do
    docker inspect $container
done
``
Use case: Check running containers.

### 5. Backup Files
```
DATE=$(date +%F)

for file in *.txt
do
    cp $file ${file}-${DATE}
done
```
Interview Question: Why use $(date +%F)?
Answer: Generates the current date in YYYY-MM-DD format, useful for backups and log files.

---

## Positional Parameters
Used to pass values to a Bash script from the command line.
```
./deploy.sh prod myapp
echo "Deploying $2 to $1"
```
Output: Deploying myapp to prod

Q1: What is $0 in Bash?
$0 stores the name/path of the script being executed.

Q2: What is the difference between $0 and $1?
$0 → Script name
$1 → First argument passed to the script

$0   # Script name
$1   # First argument
$2   # Second argument
$#   # Number of arguments
$@   # All arguments

### Accept unlimited files/directories
```
#!/bin/bash

for item in "$@"
do
    if [ -f "$item" ]
    then
        echo "$item is a regular file."
    elif [ -d "$item" ]
    then
        echo "$item is a directory."
    else
        echo "$item is another type of file."
    fi

    ls -ld "$item"
    echo
done
```

## Accepting User Input (STDIN) in Bash
`read -p "Enter value: " variable`
-p → Displays a prompt message.
variable → Stores the user's input.

### Accept Multiple Inputs
```
#!/bin/bash
read -p "Enter your first and last name: " fname lname
echo "First Name: $fname"
echo "Last Name: $lname"
```

## Exit Status / Return Code ($?) 
Every command executed in Linux returns an exit status (return code) indicating whether the command succeeded or failed.
The special variable `$?` stores the exit status of the last executed command.

✅ 0 = Success,  Non-zero = Failure/Error
```
systemctl is-active docker

if [ $? -eq 0 ]
then
    echo "Docker is running"
else
    echo "Docker is not running"
fi
```
### check if google is reachable
```
if ping -c 1 google.com
then
    echo "Host reachable"
else
    echo "Host unreachable"
fi
```
### CI/CD Relevance
```
terraform apply
echo $?
```
0 → Pipeline continues
Non-zero → Pipeline fails/stops
Jenkins, GitHub Actions, GitLab CI, and Azure DevOps heavily rely on exit codes to determine stage success or failure.
Exit from a Script

###
c 1 sends 1 ICMP packet and stops
```
#!/bin/bash

HOST="google.com"

ping -c 1 $HOST

if [ "$?" -ne "0" ]                           
then
    echo "$HOST unreachable"
    exit 1
fi

exit 0
```
## Common Numeric Comparison Operators
```
-eq   Equal
-ne   Not Equal
-gt   Greater Than
-lt   Less Than
-ge   Greater Than or Equal
-le   Less Than or Equal
```

### You can return your own exit code:
```
#!/bin/bash
echo "Deployment Successful"
exit 0
```
exit 1 : Indicates the script failed.

## && and || Operators in Bash 
These are conditional execution operators used to run commands based on the success or failure of the previous command.
`&&` → AND operator
`||` → OR operator

They rely on the exit status ($?) of the previous command.

### 1. && (AND Operator)
The second command executes only if the first command succeeds (exit code = 0).

Syntax: `command1 && command2`

Example: `docker build -t myapp . && docker push myapp`
Meaning:
Build Docker image
If build succeeds, push image to registry

### 2. || (OR Operator)

The second command executes only if the first command fails (non-zero exit code).

Syntax: `command1 || command2`
Example: Ping Check
```
HOST="google.com"
ping -c 1 $HOST || echo "$HOST unreachable"
```
How it Works
If ping succeeds → nothing happens.
If ping fails → prints: google.com unreachable

### Using && and || Together
ping -c 1 google.com && echo "Reachable" || echo "Unreachable"

## Semicolon (;) in Bash (Interview-Ready Notes)
A semicolon (;) is used to separate multiple commands on the same line.

Syntax: `command1 ; command2 ; command3  

All commands are executed sequentially, regardless of whether the previous command succeeds or fails.

Example
```
git pull ; docker build -t app . ; docker run app
```
Each command runs one after another.

## Functions in Bash (Interview-Ready Notes)
A function is a reusable block of code that performs a specific task.
Instead of writing the same commands multiple times, you write them once in a function and call the function whenever needed.

Syntax Method 1
```
function hello() {
    echo "Hello"
}
```

Method 2 (More Common)
```
hello() {
    echo "Hello"
}
```
Both are valid.

### Calling a Function
```
#!/bin/bash

hello() {
    echo "Hello!"
    now
}

now() {
    echo "It's $(date)"
}

hello
```

notice `hello` function is called after the `now`
as When Bash executes hello, it tries to call now, but now() has not been defined yet so In this example, that is exactly what has happened, Although the hello function calls the now function, and the now function is below it in the script, the now function actually gets read into the script before the hello function is called.
Best practice: Place all function definitions at the top of the script and call them at the bottom.

### Check Docker Status:
```
check_docker() {
    systemctl is-active docker > /dev/null

    if [ $? -eq 0 ]
    then
        echo "Docker is running"
    else
        echo "Docker is stopped"
    fi
}

check_docker
```
### check file → create timestamped backup → verify success using exit code
```
function backup_file () {
    if [ -f "$1" ]
    then
        BACK="/tmp/$(basename ${1}).$(date +%F).$$"
        echo "Backing up $1 to ${BACK}"
        cp "$1" "$BACK"
    fi
}

backup_file /etc/hosts

if [ $? -eq 0 ]
then
    echo "Backup succeeded!"
fi
```
$1   # First argument passed to function
basename  # Extracts filename from path
date +%F  # Current date (YYYY-MM-DD)
$$   # Current process ID
$?   # Exit status of last command

Example Backup File Created: /tmp/hosts.2026-09-01.12345
``
---

## kill and trap command

`kill` sends a signal to a process (usually to stop it), while `trap` is used inside a script to catch those signals and run a specific cleanup action instead of crashing.

### The kill Command (The Sender)
kill is used to send a termination signal to a running program using its Process ID (PID).  
Graceful Kill (SIGTERM / Signal 15): Asks the program to save its work and close cleanly: `kill 1234`  
Force Kill (SIGKILL / Signal 9): Instantly forces the program to stop, bypassing any saves. `kill -9 1234`  

### The trap Command (The Catcher)
`trap` is written inside shell scripts. It intercepts signals (like someone pressing Ctrl+C or running a kill command) so your script can clean up temporary files before exiting.  
Syntax: `trap 'action_to_take' SIGNAL`  
Example (Cleanup on Exit): Deletes temporary files automatically if the script exits or gets interrupted  
`trap "rm -f /tmp/temp_file.txt; exit" SIGINT SIGTERM EXIT`  

**`trap "echo don't use the ctrl+c" SININT`**
If you don't want the procees to terminate using Ctrl + C we can use above cmd. So when someone press Ctrl + C. Instead of killing your session, the terminal will print: don't use the ctrl+c  

Interview TipThe SIGINT signal (Signal 2) stands for Signal Interrupt. It is the exact system signal triggered whenever a user hits Ctrl + C on their keyboard.
  
