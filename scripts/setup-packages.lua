local function command_exists(command)
	local handle = io.popen("command -v " .. command .. " >/dev/null 2>&1; echo $?")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return tonumber(result) == 0
	end
	return false
end

local packages_dir = "packages/"

local package_managers = {
	Homebrew = {
		exists_command = "brew",
		install_command = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
		packages_file = packages_dir .. "Brewfile",
		install_packages_command = "brew bundle --file=" .. packages_dir .. "Brewfile",
	},
	Cargo = {
		exists_command = "cargo",
		install_command = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh",
		packages_file = packages_dir .. "cargo.txt",
		install_packages_command = "cat " .. packages_dir .. "cargo.txt | xargs cargo install",
	},
	Yarn = {
		exists_command = "yarn",
		install_command = "npm install --global yarn",
		packages_file = packages_dir .. "yarn.txt",
		install_packages_command = "cat " .. packages_dir .. "yarn.txt | xargs yarn global add",
	},
	npm = {
		exists_command = "npm",
		install_command = "brew install node",
		packages_file = packages_dir .. "npm.txt",
		install_packages_command = "cat " .. packages_dir .. "npm.txt | xargs npm install -g",
	},
	Gem = {
		exists_command = "gem",
		install_command = "brew install ruby",
		packages_file = packages_dir .. "gemfile",
		install_packages_command = "cat " .. packages_dir .. "gemfile | xargs gem install",
	},
	pip3 = {
		exists_command = "pip3",
		install_command = "brew install python",
		packages_file = packages_dir .. "pip.txt",
		install_packages_command = "pip3 install -r " .. packages_dir .. "pip.txt",
	},
	SDKMAN = {
		exists_command = "sdk",
		install_command = 'curl -s "https://get.sdkman.io" | bash',
		packages_file = packages_dir .. "sdkman.txt",
		install_packages_command = "cat " .. packages_dir .. "sdkman.txt | xargs -I {} sdk install {}",
	},
	Golang = {
		exists_command = "go",
		install_command = "brew install go",
		packages_file = packages_dir .. "go.txt",
		install_packages_command = "cat " .. packages_dir .. "go.txt | xargs -I {} go install {}",
	},
}

local function install_package_manager(manager_name, manager)
	if not command_exists(manager.exists_command) then
		local install_command = string.format(
			'gum spin --spinner moon --title "Installing %s..." --show-output -- %s',
			manager_name,
			manager.install_command
		)
		os.execute(install_command)
	else
		print(manager_name .. " is already installed.")
	end

	local file = manager.packages_file
	local install_packages_command = manager.install_packages_command
	local f = io.open(file, "r")
	if f then
		f:close()
		local install_command = string.format(
			'gum spin --spinner moon --title "Installing %s packages..." --show-output -- "%s"',
			manager_name,
			install_packages_command
		)
		os.execute(install_command)
	else
		print("No " .. file .. " found for " .. manager_name .. ". Skipping package installation.")
	end
end

for manager_name, manager in pairs(package_managers) do
	install_package_manager(manager_name, manager)
end

print("All package managers and their respective packages have been processed!")
