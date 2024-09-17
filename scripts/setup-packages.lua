-- Utility function to check if a command exists
function command_exists(command)
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

-- Function to run a command with a progress bar using Gum
local function run_with_progress(title, command)
	local gum_spin_command = string.format('gum spin --title "%s" --spinner dot -- %s', title, command)
	os.execute(gum_spin_command)
end

-- Functions to install packages
local function install_homebrew()
	if package_managers["Homebrew"] and command_exists("brew") then
		run_with_progress("Installing Homebrew packages", "brew bundle --file=Brewfile")
	end
end

local function install_cargo()
	if package_managers["Cargo"] and command_exists("cargo") then
		run_with_progress("Installing Cargo packages", "cat cargo.txt | xargs cargo install")
	end
end

local function install_yarn()
	if package_managers["Yarn"] and command_exists("yarn") then
		run_with_progress("Installing Yarn packages", "cat yarn.txt | xargs yarn global add")
	end
end

local function install_npm()
	if package_managers["npm"] and command_exists("npm") then
		run_with_progress("Installing npm packages", "cat npm.txt | xargs npm install -g")
	end
end

local function install_gem()
	if package_managers["Gem"] and command_exists("gem") then
		run_with_progress("Installing Gem packages", "cat gemfile | xargs gem install")
	end
end

local function install_pip3()
	if package_managers["pip3"] and command_exists("pip3") then
		run_with_progress("Installing pip3 packages", "pip3 install -r pip.txt")
	end
end

local function install_sdkman()
	if package_managers["SDKMAN"] and command_exists("sdk") then
		run_with_progress("Installing SDKMAN packages", "cat sdkman.txt | xargs -I {} sdk install {}")
	end
end

local function install_golang()
	if package_managers["Golang"] and command_exists("go") then
		run_with_progress("Installing Golang packages", "cat go.txt | xargs -I {} go install {}")
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
