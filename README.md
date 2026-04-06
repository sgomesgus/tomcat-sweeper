# Tomcat Sweeper

![Windows](https://img.shields.io/badge/OS-Windows-blue) ![Batch](https://img.shields.io/badge/Language-Batch-green) ![Automation](https://img.shields.io/badge/Type-Automation-orange) ![Tomcat](https://img.shields.io/badge/Module-Application%20Maintenance-red)

> **Important Note:** This script forcibly terminates processes and deletes runtime directories. Use with caution and never run in critical environments without validation.

---

## Purpose

This Batch script automates maintenance routines for multiple Apache Tomcat instances running on Windows.

It is designed to:

- Free locked ports  
- Clear temporary/runtime files  
- Restart services cleanly  

Ideal for development environments, QA pipelines, and multi-instance Tomcat setups where manual cleanup becomes repetitive and error-prone.

---

## How It Works

For each configured port, the script executes a controlled maintenance workflow:

1. Process Detection: Identifies active processes bound to the target port  
2. Forced Termination: Kills the process using the detected PID  
3. Cooldown Interval: Waits for system resources to be released  
4. Directory Cleanup: Recursively clears logs, work, and temp  
5. Service Restart: Starts the corresponding Windows service  
6. Stabilization Delay: Allows the service to fully initialize  

All operations are logged with timestamps for traceability.

---

## Key Safety Practices

- Scoped Port Handling: Only acts on explicitly defined ports  
- Directory Validation: Ensures target paths exist before cleanup  
- Structured Logging: Outputs execution details to dated log files  
- Graceful Timing: Introduces delays to avoid race conditions  
- Service-Based Restart: Uses Windows Services instead of raw process execution  

---

## Configuration Options

The script is configured via internal variables:

BASE_DIR        Root directory containing Tomcat instances  
LOG_DIR         Directory where execution logs are stored  
PORTAS          List of Tomcat ports (space-separated)  
SERVICE_PREFIX  Windows service name prefix  

---

## Requirements & Usage

OS: Windows  
Tools: netstat, taskkill, findstr, timeout, net  
Permissions: Administrator  
Execution: Command Prompt or scheduled task  

---

## Usage

script.bat

Logs are automatically generated:

logs_script\limpeza_YYYY-MM-DD.log

---

## Example Workflow

PORTA: 8080  
Detecting process...  
PID found: 1234  
Killing process...  
Cleaning directories...  
Restarting service...  

---

## Logging

Each execution generates a log file:

logs_script\limpeza_2026-04-06.log

Includes:

- Start/end timestamps  
- Per-port execution status  
- Errors and warnings  

---

## Warnings

- ACTIVE PROCESSES WILL BE FORCEFULLY TERMINATED  
- FILES IN logs/work/temp WILL BE PERMANENTLY DELETED  
- Ensure the correct BASE_DIR and PORTAS are configured  
- Validate service names before execution
