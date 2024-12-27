# NEW MAC SETUP SCRIPT

A collection of shell scripts designed to automate the setup of a new macOS environment, streamlining the installation of essential tools and configurations.

## Features

- **Automated Setup**: Simplifies the initialization of a new Mac by automating the installation of necessary software and configurations.
- **Scripted Installations**: Includes scripts to install a bunch of tools and goodies.

## Prerequisites

- **macOS**: Ensure you're running a compatible version of macOS.
- **Command Line Tools**: Install Xcode Command Line Tools if not already present:

  ```bash
  xcode-select --install
  ```

## Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/kaushald/sh-mac-setup.git
   cd sh-mac-setup
   ```

2. **Run the Orchestrator Script**:

   Execute the main setup script to initiate the installation process:

   ```bash
   ./orchestrator.sh
   ```

   > **Note**: You may be prompted to enter your password during the installation process.

## Customization

- **Fonts**: Add or modify fonts in the `fonts` directory to customize font installations.
- **iTerm2 Color Schemes**: Add or modify color schemes in the `iterm-colors` directory to customize iTerm2 appearances.

## Troubleshooting

- **Permissions**: Ensure you have the necessary permissions to execute the scripts. If you encounter permission issues, you may need to adjust the script permissions:

  ```bash
  chmod +x orchestrator.sh
  ```

- **Error Logs**: Review the terminal output for any error messages and address them accordingly.

## Contributing

Contributions are welcome! To contribute:

1. **Fork the Repository**.
2. **Create a New Branch**:

   ```bash
   git checkout -b feature-branch-name
   ```

3. **Commit Your Changes**:

   ```bash
   git commit -m "Description of changes"
   ```

4. **Push to Your Fork**:

   ```bash
   git push origin feature-branch-name
   ```

5. **Submit a Pull Request** with a detailed description of your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by various macOS setup scripts and automation tools.
