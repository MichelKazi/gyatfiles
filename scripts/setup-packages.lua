-- Utility local function to check if a command exists
local function command_exists(command)
	local handle = io.popen("command -v " .. command .. " >/dev/null 2>&1; echo $?")
	local result = handle:read("*a")
	handle:close()
	return tonumber(result) == 0
end

-- Table to store package managers and whether they should be installed
local package_managers = {
	Homebrew = false,
	Cargo = false,
	Yarn = false,
	npm = false,
	Gem = false,
	pip3 = false,
	SDKMAN = false,
	Golang = false,
}

-- List of package managers to present to the user for selection
local package_manager_list = {
	"Homebrew",
	"Cargo",
	"Yarn",
	"npm",
	"Gem",
	"pip3",
	"SDKMAN",
	"Golang",
}

-- Use Gum to allow the user to select which package managers to install
local gum_command = "gum choose --no-limit --cursor.foreground='#00ff00' "
for _, manager in ipairs(package_manager_list) do
	gum_command = gum_command .. "'" .. manager .. "' "
end

-- Get the selected package managers
local handle = io.popen(gum_command)
local selected_managers = handle:read("*a")
handle:close()

-- Set the corresponding boolean values in the package_managers table to true for the selected ones
for manager in string.gmatch(selected_managers, "[^\n]+") do
	package_managers[manager] = true
end

-- local function to run a command for each package with a progress bar
local function run_with_progress(title, package_list_command, install_command_template)
	-- Capture the list of packages to install
	local handle = io.popen(package_list_command)
	local packages = {}
	for package in handle:lines() do
		table.insert(packages, package)
	end
	handle:close()

	-- Install each package with the spinner showing progress
	for _, package in ipairs(packages) do
		local gum_command = string.format('gum spin --title "Installing %s... %s" --spinner dot -- "', title, package)
		local install_command = install_command_template:gsub("{package}", package)
		os.execute(gum_command .. install_command .. '"')
	end
end

-- local functions to install packages with the spinner updating per package
local function install_homebrew()
	if package_managers["Homebrew"] and command_exists("brew") then
		run_with_progress(
			"Homebrew packages",
			"brew list", -- Command to list installed brew packages
			"brew install {package}" -- Command to install brew packages
		)
	end
end

local function install_cargo()
	if package_managers["Cargo"] and command_exists("cargo") then
		run_with_progress(
			"Cargo packages",
			"cat cargo.txt", -- Command to list packages from cargo.txt
			"cargo install {package}" -- Command to install Cargo packages
		)
	end
end

local function install_yarn()
	if package_managers["Yarn"] and command_exists("yarn") then
		run_with_progress(
			"Yarn packages",
			"cat yarn.txt", -- Command to list packages from yarn.txt
			"yarn global add {package}" -- Command to install Yarn packages
		)
	end
end

local function install_npm()
	if package_managers["npm"] and command_exists("npm") then
		run_with_progress(
			"npm packages",
			"cat npm.txt", -- Command to list packages from npm.txt
			"npm install -g {package}" -- Command to install npm packages
		)
	end
end

local function install_gem()
	if package_managers["Gem"] and command_exists("gem") then
		run_with_progress(
			"Gem packages",
			"cat gemfile", -- Command to list packages from gemfile
			"gem install {package}" -- Command to install Ruby gems
		)
	end
end

local function install_pip3()
	if package_managers["pip3"] and command_exists("pip3") then
		run_with_progress(
			"pip3 packages",
			"cat pip.txt", -- Command to list packages from pip.txt
			"pip3 install {package}" -- Command to install pip3 packages
		)
	end
end

local function install_sdkman()
	if package_managers["SDKMAN"] and command_exists("sdk") then
		run_with_progress(
			"SDKMAN packages",
			"cat sdkman.txt", -- Command to list packages from sdkman.txt
			"sdk install {package}" -- Command to install SDKMAN packages
		)
	end
end

local function install_golang()
	if package_managers["Golang"] and command_exists("go") then
		run_with_progress(
			"Golang packages",
			"cat go.txt", -- Command to list packages from go.txt
			"go install {package}" -- Command to install Go packages
		)
	end
end

-- Execute the installations
install_homebrew()
install_cargo()
install_yarn()
install_npm()
install_gem()
install_pip3()
install_sdkman()
install_golang()

print("All selected package managers and packages have been installed!")
