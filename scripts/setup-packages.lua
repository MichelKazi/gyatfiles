-- Utility function to check if a command exists
local function command_exists(command)
	local handle = io.popen("command -v " .. command .. " >/dev/null 2>&1; echo $?")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return tonumber(result) == 0
	end
	return false
end

-- Table to store package managers and their install commands
local package_managers = {
	Homebrew = {
		exists_command = "brew",
		install_command = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
		packages_file = "Brewfile",
		install_packages_command = "brew bundle --file=Brewfile",
	},
	Cargo = {
		exists_command = "cargo",
		install_command = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y",
		packages_file = "cargo.txt",
		install_packages_command = "cat cargo.txt | xargs cargo install",
	},
	Yarn = {
		exists_command = "yarn",
		install_command = "npm install --global yarn",
		packages_file = "yarn.txt",
		install_packages_command = "cat yarn.txt | xargs yarn global add",
	},
	npm = {
		exists_command = "npm",
		install_command = "brew install node",
		packages_file = "npm.txt",
		install_packages_command = "cat npm.txt | xargs npm install -g",
	},
	Gem = {
		exists_command = "gem",
		install_command = "brew install ruby",
		packages_file = "gemfile",
		install_packages_command = "cat gemfile | xargs gem install",
	},
	pip3 = {
		exists_command = "pip3",
		install_command = "brew install python",
		packages_file = "pip.txt",
		install_packages_command = "pip3 install -r pip.txt",
	},
	SDKMAN = {
		exists_command = "sdk",
		install_command = 'curl -s "https://get.sdkman.io" | bash',
		packages_file = "sdkman.txt",
		install_packages_command = "cat sdkman.txt | xargs -I {} sdk install {}",
	},
	Golang = {
		exists_command = "go",
		install_command = "brew install go",
		packages_file = "go.txt",
		install_packages_command = "cat go.txt | xargs -I {} go install {}",
	},
}

-- Function to install a package manager if it doesn't exist and install its packages
local function install_package_manager(manager_name, manager)
	-- Check if the package manager exists
	if not command_exists(manager.exists_command) then
		-- Install the package manager using Gum spinner
		local install_command = string.format(
			'gum spin --spinner moon --title "Installing %s..." --show-output -- %s',
			manager_name,
			manager.install_command
		)
		os.execute(install_command)
	else
		print(manager_name .. " is already installed.")
	end

	-- Install the packages if the corresponding file exists
	local file = manager.packages_file
	local install_packages_command = manager.install_packages_command
	local f = io.open(file, "r")
	if f then
		f:close()
		-- Use Gum spinner to show package installation progress
		local install_command = string.format(
			'gum spin --title --spinner moon "Installing %s packages..." --show-output -- "%s"',
			manager_name,
			install_packages_command
		)
		os.execute(install_command)
	else
		print("No " .. file .. " found for " .. manager_name .. ". Skipping package installation.")
	end
end

-- Iterate through each package manager and install it
for manager_name, manager in pairs(package_managers) do
	install_package_manager(manager_name, manager)
end

print("All package managers and their respective packages have been processed!")
