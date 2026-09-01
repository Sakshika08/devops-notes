###
In variable do not add space before or after tyhe `=` sign
variable_name="you_name"


## Conditions
[ condition ] is a Bash test expression used to evaluate conditions.
Example: [ -e /etc/passwd ] checks whether the file /etc/passwd exists.
[1 == 2]
It is commonly used in if statements for decision making.

### Common file test operators
-e file   # Exists
-f file   # Regular file
-d file   # Directory
-r file   # Readable
-w file   # Writable
-x file   # Executable

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

## for Loop
```
for VARIABLE in ITEM1 ITEM2 ITEMN
do
    command(s)
done
```

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
