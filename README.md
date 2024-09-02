# Universal System Information Script

A cross-platform Bash script to display system information on Linux, macOS, and Windows (via WSL or Git Bash).

## Features

This script provides a colorful and informative output of various system details, including:

- Operating System
- Kernel version
- Machine/Hardware information
- System uptime
- Desktop environment
- Shell information
- Screen resolution
- Installed packages
- CPU details
- GPU information
- Memory usage
- Disk usage
- Network information

## Requirements

- Bash shell environment
- For Windows: Windows Subsystem for Linux (WSL) or Git Bash

## Usage

1. Clone the repository:
   ```
   git clone https://github.com/adityavijay21/system-info-script.git
   ```

2. Navigate to the script directory:
   ```
   cd system-info-script
   ```

3. Make the script executable:
   ```
   chmod +x system_info.sh
   ```

4. Run the script:
   ```
   ./system_info.sh
   ```

## Sample Output

```
             user@hostname
OS           : Ubuntu 20.04 LTS
Kernel       : 5.4.0-42-generic x86_64
Machine      : Dell Inc. XPS 13 9380
Uptime       : up 2 days, 5:43

Desktop      : GNOME
Shell        : /bin/bash (bash version 5.0.17)
Resolution   : 3840x2160
Packages     : dpkg(2341) snap(41)

CPU          : Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz
GPU          : Intel Corporation UHD Graphics 620 (Whiskey Lake)
Memory       : 7.2GiB / 15.5GiB (46%)
Disk         : 128.9GiB / 250.9GiB (54%, /)
Network      : 192.168.1.100
```

## Compatibility

This script is designed to work on:
- Linux distributions
- macOS
- Windows (via Windows Subsystem for Linux or Git Bash)

Note: Some features may have limited functionality depending on the available commands in your environment.

## Customization

You can easily modify the script to add or remove information categories. Each function in the script corresponds to a specific piece of information displayed in the output.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](https://github.com/adityavijay21/system-info-script/issues).

## License

This project is [MIT](https://choosealicense.com/licenses/mit/) licensed.

## Author

👤 **Aditya Vijay**

* GitHub: [@adityavijay21](https://github.com/adityavijay21)
* LinkedIn: [@adityavijay21](https://linkedin.com/in/adityavijay21)

## Show your support

Give a ⭐️ if this project helped you!
