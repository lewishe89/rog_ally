### Rog Ally

# Disable Turbo Boost for All Power Plans

This PowerShell script is designed to disable the processor performance boost mode (often referred to as "Turbo Boost") for all power plans on a Windows system. By disabling this mode, the system may operate with reduced power consumption and heat generation.

## Prerequisites

- Windows operating system
- PowerShell (included with Windows)
- Administrative privileges

## How to Run the Script

### Method 1: Run from an Elevated PowerShell Prompt

1. Open PowerShell as an Administrator.
2. Navigate to the directory where the script is located.
3. Run the following command to temporarily bypass the execution policy:
   ```powershell
   PowerShell -ExecutionPolicy Bypass -File "disable_turbo_boost_for_all_power_plans.ps1"
   
### Method 2: Change Execution Policy Manually

1. Open PowerShell as an Administrator.
2. Change the execution policy to allow the script to run:
   ```powershell
   Set-ExecutionPolicy RemoteSigned
3. Navigate to the directory where the script is located.
4. Run the script by typing:
   ```powershell
   .\disable_turbo_boost_for_all_power_plans.ps1

## What the Script Does

1. Checks for administrative privileges and necessary execution policy settings.
2. Modifies a registry value related to the processor performance boost mode (if needed).
3. Queries the system's power plans and identifies the processor performance boost mode setting.
4. Disables the processor performance boost mode for each power plan, if not already disabled.

## Warning

Changing the execution policy and modifying registry values can have security implications and may affect other applications on the system. Please understand the potential risks and test the script in a controlled environment before deploying it widely.
