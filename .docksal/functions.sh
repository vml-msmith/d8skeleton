# Abort if anything fails
set -e

# PROJECT_ROOT is passed from fin.
# The following variables are configured in the '.env' file: DOCROOT, VIRTUAL_HOST.

SITE_DIRECTORY="default"
DOCROOT_PATH="${PROJECT_ROOT}/${DOCROOT}"
SITES_PATH="${DOCROOT_PATH}/sites"
SITEDIR_PATH="${DOCROOT_PATH}/sites/${SITE_DIRECTORY}"

# Console colors
red='\033[0;31m'
green='\033[0;32m'
green_bg='\033[30;42m'
yellow='\033[1;33m'
NC='\033[0m'

echo-red () { echo -e "${red}$1${NC}"; }
echo-green () { echo -e "${green}$1${NC}"; }
echo-green-bg () { echo -e "${green_bg}$1${NC}"; }
echo-yellow () { echo -e "${yellow}$1${NC}"; }


header() {
  local text="$1"
  section=$text
  echo -e "${yellow}==========[${green} ${text} ${yellow}]==========${NC}"
}

subheader() {
  local text="$1"
  section=$text
  echo -e "${green}${text}${NC}"
}

step_header() {
  local text="$1"
  echo -e "${yellow}${section} ${green}> ${yellow}Step ${step} ${green}> ${NC}${text}"
  ((step++))
}

# Copy a settings file.
# Skips if the destination file already exists.
# @param $1 source file
# @param $2 destination file
copy_settings_file() {
  local source="$1"
  local dest="$2"
  
  if [[ ! -f $dest ]]; then
    echo "Copying ${dest}..."
    cp $source $dest
  else
    echo-yellow "${dest} already in place."
  fi
}
