# proxmox-grep-lxc-ip

Extracts the IP addresses of running LXC containers from multiple Proxmox servers.

## Versions

**Current version**: `0.1.0`

## Table of Contents

- [Versions](#versions)
- [Badges](#badges)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)
- [Contributing](#contributing)

## Badges

![Language](https://img.shields.io/badge/language-bash-red)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Installation

### Tested on

- Proxmox VE 8.x

### Clone the Repository

```bash
git clone https://github.com/beecave-homelab/proxmox-grep-lxc-ip.git
cd proxmox-grep-lxc-ip
```

### Set Permissions

Make the script executable:

```bash
chmod +x grep-lxc-ip.sh
```

## Usage

Run the script to fetch the IP addresses of running LXC containers from multiple Proxmox servers.

### Basic Usage

```bash
./grep-lxc-ip.sh
```

### Arguments

| Option                 | Description                                                                                     |
|------------------------|-------------------------------------------------------------------------------------------------|
| `-o`, `--output-file`  | Specify the output file where results will be saved. Default: `lxc_ips_output.txt`.             |
| `-s`, `--subnet-prefix`| Specify the prefix for filtering IP addresses. Default: `192`.                                 |
| `-ip`, `--proxmox-ip`  | Add a Proxmox server IP to the list of servers to query. Supports multiple entries.             |
| `-h`, `--help`         | Display usage instructions and options.                                                        |

### Examples

1. **Fetch IPs and save to a custom file**:

   ```bash
   ./grep-lxc-ip.sh -o custom_output.txt
   ```

2. **Filter IPs with a custom subnet prefix**:

   ```bash
   ./grep-lxc-ip.sh -s 10
   ```

3. **Add additional Proxmox hosts dynamically**:

   ```bash
   ./grep-lxc-ip.sh -ip 192.168.20.5 -ip 192.168.20.6
   ```

4. **Combine options**:

   ```bash
   ./grep-lxc-ip.sh -o custom_output.txt -s 10 -ip 192.168.20.5
   ```

### Output

Results will be saved in the specified file or the default `lxc_ips_output.txt`. The output format is:

```plaintext
VMID    IP             
-------------------------
401     192.168.0.10   
402     192.168.1.15   
404     192.168.3.25   
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss your ideas.

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

---
