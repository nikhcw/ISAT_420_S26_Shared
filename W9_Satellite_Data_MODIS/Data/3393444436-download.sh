#!/bin/bash

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    echo "Enter your Earthdata Login or other provider supplied credentials"
    read -p "Username (tobiasgerken): " username
    username=${username:-tobiasgerken}
    read -s -p "Password: " password
    echo "machine urs.earthdata.nasa.gov login $username password $password" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2026032.061.2026072100223/MOD13C2.A2026032.061.2026072100223.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2026032.061.2026072100223/MOD13C2.A2026032.061.2026072100223.hdf -w '\n%{http_code}' | tail  -1`
    if [ "$approved" -ne "200" ] && [ "$approved" -ne "301" ] && [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w '\n%{http_code}' https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2026032.061.2026072100223/MOD13C2.A2026032.061.2026072100223.hdf | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}

fetch_urls() {
  if command -v curl >/dev/null 2>&1; then
      setup_auth_curl
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -g -o $stripped_query_params -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  elif command -v wget >/dev/null 2>&1; then
      # We can't use wget to poke provider server to get info whether or not URS was integrated without download at least one of the files.
      echo
      echo "WARNING: Can't find curl, use wget instead."
      echo "WARNING: Script may not correctly identify Earthdata Login integrations."
      echo
      setup_auth_wget
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        wget --load-cookies "$cookiejar" --save-cookies "$cookiejar" --output-document $stripped_query_params --keep-session-cookies -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  else
      exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
  fi
}

fetch_urls <<'EDSCEOF'
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2026032.061.2026072100223/MOD13C2.A2026032.061.2026072100223.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2026001.061.2026034015600/MOD13C2.A2026001.061.2026034015600.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025335.061.2026006151829/MOD13C2.A2025335.061.2026006151829.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025305.061.2025339133307/MOD13C2.A2025305.061.2025339133307.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025274.061.2025306103720/MOD13C2.A2025274.061.2025306103720.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025244.061.2025290121318/MOD13C2.A2025244.061.2025290121318.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025213.061.2025259093641/MOD13C2.A2025213.061.2025259093641.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025182.061.2025227032314/MOD13C2.A2025182.061.2025227032314.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025152.061.2025206111023/MOD13C2.A2025152.061.2025206111023.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025152.061.2025219165905/MOD13C2.A2025152.061.2025219165905.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025121.061.2025163044304/MOD13C2.A2025121.061.2025163044304.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025091.061.2025133163506/MOD13C2.A2025091.061.2025133163506.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025060.061.2025098184723/MOD13C2.A2025060.061.2025098184723.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025032.061.2025072100143/MOD13C2.A2025032.061.2025072100143.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2025001.061.2025035171541/MOD13C2.A2025001.061.2025035171541.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024336.061.2025007011400/MOD13C2.A2024336.061.2025007011400.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024306.061.2024338122222/MOD13C2.A2024306.061.2024338122222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024275.061.2024337120446/MOD13C2.A2024275.061.2024337120446.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024245.061.2024291123221/MOD13C2.A2024245.061.2024291123221.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024214.061.2024267164812/MOD13C2.A2024214.061.2024267164812.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024183.061.2024228034735/MOD13C2.A2024183.061.2024228034735.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024153.061.2024198104950/MOD13C2.A2024153.061.2024198104950.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024122.061.2024162181836/MOD13C2.A2024122.061.2024162181836.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024092.061.2024133223503/MOD13C2.A2024092.061.2024133223503.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024061.061.2024099222643/MOD13C2.A2024061.061.2024099222643.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024032.061.2024066075101/MOD13C2.A2024032.061.2024066075101.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2024001.061.2024038052740/MOD13C2.A2024001.061.2024038052740.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023335.061.2024006113611/MOD13C2.A2023335.061.2024006113611.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023305.061.2023345100120/MOD13C2.A2023305.061.2023345100120.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023274.061.2023306003339/MOD13C2.A2023274.061.2023306003339.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023244.061.2023290150310/MOD13C2.A2023244.061.2023290150310.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023213.061.2023258020153/MOD13C2.A2023213.061.2023258020153.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023182.061.2023226010223/MOD13C2.A2023182.061.2023226010223.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023152.061.2023212131942/MOD13C2.A2023152.061.2023212131942.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023121.061.2023164023309/MOD13C2.A2023121.061.2023164023309.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023091.061.2023130015805/MOD13C2.A2023091.061.2023130015805.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023060.061.2023100032443/MOD13C2.A2023060.061.2023100032443.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023032.061.2023070144624/MOD13C2.A2023032.061.2023070144624.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2023001.061.2023034191717/MOD13C2.A2023001.061.2023034191717.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022335.061.2023006093823/MOD13C2.A2022335.061.2023006093823.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022305.061.2022351055011/MOD13C2.A2022305.061.2022351055011.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022274.061.2022307143218/MOD13C2.A2022274.061.2022307143218.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022244.061.2022297185735/MOD13C2.A2022244.061.2022297185735.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022213.061.2022258145129/MOD13C2.A2022213.061.2022258145129.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022182.061.2022232164108/MOD13C2.A2022182.061.2022232164108.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022152.061.2022201123617/MOD13C2.A2022152.061.2022201123617.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022121.061.2022168105355/MOD13C2.A2022121.061.2022168105355.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022091.061.2022136120313/MOD13C2.A2022091.061.2022136120313.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022060.061.2022108194209/MOD13C2.A2022060.061.2022108194209.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022032.061.2022066011432/MOD13C2.A2022032.061.2022066011432.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2022001.061.2022035060912/MOD13C2.A2022001.061.2022035060912.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021335.061.2022005004102/MOD13C2.A2021335.061.2022005004102.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021305.061.2021338165341/MOD13C2.A2021305.061.2021338165341.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021274.061.2022066102004/MOD13C2.A2021274.061.2022066102004.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021244.061.2021322130311/MOD13C2.A2021244.061.2021322130311.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021213.061.2021258051026/MOD13C2.A2021213.061.2021258051026.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021182.061.2021226060459/MOD13C2.A2021182.061.2021226060459.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021152.061.2021194035425/MOD13C2.A2021152.061.2021194035425.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021121.061.2021165125210/MOD13C2.A2021121.061.2021165125210.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021091.061.2021133165855/MOD13C2.A2021091.061.2021133165855.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021060.061.2021098024842/MOD13C2.A2021060.061.2021098024842.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021032.061.2021068110257/MOD13C2.A2021032.061.2021068110257.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2021001.061.2021043134142/MOD13C2.A2021001.061.2021043134142.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020336.061.2021012033415/MOD13C2.A2020336.061.2021012033415.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020306.061.2020357112600/MOD13C2.A2020306.061.2020357112600.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020275.061.2020353114309/MOD13C2.A2020275.061.2020353114309.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020245.061.2020349222009/MOD13C2.A2020245.061.2020349222009.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020214.061.2020346124348/MOD13C2.A2020214.061.2020346124348.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020183.061.2020342033627/MOD13C2.A2020183.061.2020342033627.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020153.061.2020340140629/MOD13C2.A2020153.061.2020340140629.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020122.061.2020336000916/MOD13C2.A2020122.061.2020336000916.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020092.061.2020335033238/MOD13C2.A2020092.061.2020335033238.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020061.061.2020335033234/MOD13C2.A2020061.061.2020335033234.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020032.061.2020335014658/MOD13C2.A2020032.061.2020335014658.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2020001.061.2020328142931/MOD13C2.A2020001.061.2020328142931.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019335.061.2020323194535/MOD13C2.A2019335.061.2020323194535.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019305.061.2020319033001/MOD13C2.A2019305.061.2020319033001.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019274.061.2020316042726/MOD13C2.A2019274.061.2020316042726.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019244.061.2020314043412/MOD13C2.A2019244.061.2020314043412.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019213.061.2020308214657/MOD13C2.A2019213.061.2020308214657.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019182.061.2020304191154/MOD13C2.A2019182.061.2020304191154.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019152.061.2020303082503/MOD13C2.A2019152.061.2020303082503.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019121.061.2020298054312/MOD13C2.A2019121.061.2020298054312.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019091.061.2020293175428/MOD13C2.A2019091.061.2020293175428.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019060.061.2020291183248/MOD13C2.A2019060.061.2020291183248.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019032.061.2020289005752/MOD13C2.A2019032.061.2020289005752.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2019001.061.2020286183227/MOD13C2.A2019001.061.2020286183227.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018335.061.2021361152108/MOD13C2.A2018335.061.2021361152108.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018305.061.2021350201910/MOD13C2.A2018305.061.2021350201910.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018274.061.2021350202109/MOD13C2.A2018274.061.2021350202109.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018244.061.2021350201649/MOD13C2.A2018244.061.2021350201649.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018213.061.2021349074039/MOD13C2.A2018213.061.2021349074039.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018182.061.2021349073550/MOD13C2.A2018182.061.2021349073550.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018152.061.2021349073614/MOD13C2.A2018152.061.2021349073614.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018121.061.2021349073612/MOD13C2.A2018121.061.2021349073612.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018091.061.2021331172126/MOD13C2.A2018091.061.2021331172126.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018060.061.2021324085316/MOD13C2.A2018060.061.2021324085316.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018032.061.2021324001523/MOD13C2.A2018032.061.2021324001523.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2018001.061.2021316203555/MOD13C2.A2018001.061.2021316203555.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017335.061.2021295075921/MOD13C2.A2017335.061.2021295075921.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017305.061.2021293215600/MOD13C2.A2017305.061.2021293215600.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017274.061.2021289005246/MOD13C2.A2017274.061.2021289005246.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017244.061.2021289005301/MOD13C2.A2017244.061.2021289005301.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017213.061.2021285221821/MOD13C2.A2017213.061.2021285221821.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017182.061.2021283093826/MOD13C2.A2017182.061.2021283093826.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017152.061.2021283093826/MOD13C2.A2017152.061.2021283093826.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017121.061.2021276172250/MOD13C2.A2017121.061.2021276172250.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017091.061.2021272052638/MOD13C2.A2017091.061.2021272052638.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017060.061.2021271080314/MOD13C2.A2017060.061.2021271080314.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017032.061.2021267104414/MOD13C2.A2017032.061.2021267104414.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2017001.061.2021264172230/MOD13C2.A2017001.061.2021264172230.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016336.061.2021363155618/MOD13C2.A2016336.061.2021363155618.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016306.061.2021361211651/MOD13C2.A2016306.061.2021361211651.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016275.061.2021360043712/MOD13C2.A2016275.061.2021360043712.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016245.061.2021358122902/MOD13C2.A2016245.061.2021358122902.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016214.061.2021357073514/MOD13C2.A2016214.061.2021357073514.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016183.061.2021356205200/MOD13C2.A2016183.061.2021356205200.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016153.061.2021353121837/MOD13C2.A2016153.061.2021353121837.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016122.061.2021351113200/MOD13C2.A2016122.061.2021351113200.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016092.061.2021349052734/MOD13C2.A2016092.061.2021349052734.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016061.061.2021347054544/MOD13C2.A2016061.061.2021347054544.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016032.061.2021346111924/MOD13C2.A2016032.061.2021346111924.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2016001.061.2021343152903/MOD13C2.A2016001.061.2021343152903.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015335.061.2021342195654/MOD13C2.A2015335.061.2021342195654.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015305.061.2021337063703/MOD13C2.A2015305.061.2021337063703.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015274.061.2021336124250/MOD13C2.A2015274.061.2021336124250.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015244.061.2021333133827/MOD13C2.A2015244.061.2021333133827.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015213.061.2021332033308/MOD13C2.A2015213.061.2021332033308.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015182.061.2021330020931/MOD13C2.A2015182.061.2021330020931.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015152.061.2021328013520/MOD13C2.A2015152.061.2021328013520.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015121.061.2021326101400/MOD13C2.A2015121.061.2021326101400.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015091.061.2021324004230/MOD13C2.A2015091.061.2021324004230.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015060.061.2021322221735/MOD13C2.A2015060.061.2021322221735.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015032.061.2021320135738/MOD13C2.A2015032.061.2021320135738.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2015001.061.2021319205851/MOD13C2.A2015001.061.2021319205851.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014335.061.2021316140322/MOD13C2.A2014335.061.2021316140322.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014305.061.2021312012957/MOD13C2.A2014305.061.2021312012957.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014274.061.2021311014526/MOD13C2.A2014274.061.2021311014526.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014244.061.2021310111814/MOD13C2.A2014244.061.2021310111814.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014213.061.2021262091335/MOD13C2.A2014213.061.2021262091335.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014182.061.2021260094701/MOD13C2.A2014182.061.2021260094701.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014152.061.2021258080924/MOD13C2.A2014152.061.2021258080924.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014121.061.2021256110428/MOD13C2.A2014121.061.2021256110428.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014091.061.2021255121607/MOD13C2.A2014091.061.2021255121607.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014060.061.2021253011325/MOD13C2.A2014060.061.2021253011325.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014032.061.2021250065249/MOD13C2.A2014032.061.2021250065249.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2014001.061.2021248104137/MOD13C2.A2014001.061.2021248104137.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013335.061.2021246021029/MOD13C2.A2013335.061.2021246021029.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013305.061.2021243181717/MOD13C2.A2013305.061.2021243181717.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013274.061.2021242225626/MOD13C2.A2013274.061.2021242225626.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013244.061.2021241000238/MOD13C2.A2013244.061.2021241000238.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013213.061.2021239071546/MOD13C2.A2013213.061.2021239071546.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013182.061.2021235175935/MOD13C2.A2013182.061.2021235175935.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013152.061.2021233131142/MOD13C2.A2013152.061.2021233131142.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013121.061.2021231175609/MOD13C2.A2013121.061.2021231175609.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013091.061.2021230072230/MOD13C2.A2013091.061.2021230072230.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013060.061.2021228114626/MOD13C2.A2013060.061.2021228114626.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013032.061.2021226234331/MOD13C2.A2013032.061.2021226234331.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2013001.061.2021226150754/MOD13C2.A2013001.061.2021226150754.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012336.061.2021224052817/MOD13C2.A2012336.061.2021224052817.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012306.061.2021223024114/MOD13C2.A2012306.061.2021223024114.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012275.061.2021223005222/MOD13C2.A2012275.061.2021223005222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012245.061.2021218003711/MOD13C2.A2012245.061.2021218003711.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012214.061.2021215120823/MOD13C2.A2012214.061.2021215120823.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012183.061.2021213132740/MOD13C2.A2012183.061.2021213132740.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012153.061.2021211234906/MOD13C2.A2012153.061.2021211234906.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012122.061.2021210052858/MOD13C2.A2012122.061.2021210052858.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012092.061.2021208111045/MOD13C2.A2012092.061.2021208111045.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012061.061.2021206190659/MOD13C2.A2012061.061.2021206190659.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012032.061.2021204225129/MOD13C2.A2012032.061.2021204225129.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2012001.061.2021204004932/MOD13C2.A2012001.061.2021204004932.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011335.061.2021201194643/MOD13C2.A2011335.061.2021201194643.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011305.061.2021200204302/MOD13C2.A2011305.061.2021200204302.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011274.061.2021199154936/MOD13C2.A2011274.061.2021199154936.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011244.061.2021198155713/MOD13C2.A2011244.061.2021198155713.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011213.061.2021196222925/MOD13C2.A2011213.061.2021196222925.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011182.061.2021195044622/MOD13C2.A2011182.061.2021195044622.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011152.061.2021193172742/MOD13C2.A2011152.061.2021193172742.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011121.061.2021193155341/MOD13C2.A2011121.061.2021193155341.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011091.061.2021192114401/MOD13C2.A2011091.061.2021192114401.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011060.061.2021187161353/MOD13C2.A2011060.061.2021187161353.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011032.061.2021187072316/MOD13C2.A2011032.061.2021187072316.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2011001.061.2021181132917/MOD13C2.A2011001.061.2021181132917.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010335.061.2021179225837/MOD13C2.A2010335.061.2021179225837.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010305.061.2021178223956/MOD13C2.A2010305.061.2021178223956.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010274.061.2021177231747/MOD13C2.A2010274.061.2021177231747.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010244.061.2021176084729/MOD13C2.A2010244.061.2021176084729.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010213.061.2021176021958/MOD13C2.A2010213.061.2021176021958.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010182.061.2021169014610/MOD13C2.A2010182.061.2021169014610.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010152.061.2021168210043/MOD13C2.A2010152.061.2021168210043.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010121.061.2021168161803/MOD13C2.A2010121.061.2021168161803.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010091.061.2021160000444/MOD13C2.A2010091.061.2021160000444.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010060.061.2021159161652/MOD13C2.A2010060.061.2021159161652.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010032.061.2021153233803/MOD13C2.A2010032.061.2021153233803.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2010001.061.2021152184804/MOD13C2.A2010001.061.2021152184804.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009335.061.2021150011516/MOD13C2.A2009335.061.2021150011516.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009305.061.2021146222144/MOD13C2.A2009305.061.2021146222144.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009274.061.2021144101525/MOD13C2.A2009274.061.2021144101525.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009244.061.2021143181844/MOD13C2.A2009244.061.2021143181844.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009213.061.2021141150936/MOD13C2.A2009213.061.2021141150936.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009182.061.2021139153327/MOD13C2.A2009182.061.2021139153327.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009152.061.2021137221759/MOD13C2.A2009152.061.2021137221759.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009121.061.2021135004944/MOD13C2.A2009121.061.2021135004944.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009091.061.2021133124711/MOD13C2.A2009091.061.2021133124711.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009060.061.2021133124246/MOD13C2.A2009060.061.2021133124246.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009032.061.2021132142729/MOD13C2.A2009032.061.2021132142729.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2009001.061.2021125215625/MOD13C2.A2009001.061.2021125215625.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008336.061.2021114020826/MOD13C2.A2008336.061.2021114020826.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008306.061.2021112102006/MOD13C2.A2008306.061.2021112102006.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008275.061.2021112124235/MOD13C2.A2008275.061.2021112124235.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008245.061.2021108164807/MOD13C2.A2008245.061.2021108164807.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008214.061.2021106132827/MOD13C2.A2008214.061.2021106132827.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008183.061.2021104130543/MOD13C2.A2008183.061.2021104130543.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008153.061.2021100073038/MOD13C2.A2008153.061.2021100073038.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008122.061.2021098142219/MOD13C2.A2008122.061.2021098142219.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008092.061.2021097013416/MOD13C2.A2008092.061.2021097013416.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008061.061.2021096171101/MOD13C2.A2008061.061.2021096171101.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008032.061.2021089021213/MOD13C2.A2008032.061.2021089021213.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2008001.061.2021088223818/MOD13C2.A2008001.061.2021088223818.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007335.061.2021082013402/MOD13C2.A2007335.061.2021082013402.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007305.061.2021079191956/MOD13C2.A2007305.061.2021079191956.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007274.061.2021077210259/MOD13C2.A2007274.061.2021077210259.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007244.061.2021076164909/MOD13C2.A2007244.061.2021076164909.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007213.061.2021073210050/MOD13C2.A2007213.061.2021073210050.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007182.061.2021071080853/MOD13C2.A2007182.061.2021071080853.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007152.061.2021068111811/MOD13C2.A2007152.061.2021068111811.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007121.061.2021065155722/MOD13C2.A2007121.061.2021065155722.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007091.061.2021064220403/MOD13C2.A2007091.061.2021064220403.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007060.061.2021059164603/MOD13C2.A2007060.061.2021059164603.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007032.061.2021056072209/MOD13C2.A2007032.061.2021056072209.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2007001.061.2021056025227/MOD13C2.A2007001.061.2021056025227.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006335.061.2021054095818/MOD13C2.A2006335.061.2021054095818.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006305.061.2020278004628/MOD13C2.A2006305.061.2020278004628.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006274.061.2020275072421/MOD13C2.A2006274.061.2020275072421.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006244.061.2020274191908/MOD13C2.A2006244.061.2020274191908.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006213.061.2020273211520/MOD13C2.A2006213.061.2020273211520.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006182.061.2020269063804/MOD13C2.A2006182.061.2020269063804.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006152.061.2020266042143/MOD13C2.A2006152.061.2020266042143.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006121.061.2020263123942/MOD13C2.A2006121.061.2020263123942.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006091.061.2020261172955/MOD13C2.A2006091.061.2020261172955.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006060.061.2020259022711/MOD13C2.A2006060.061.2020259022711.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006032.061.2020256193922/MOD13C2.A2006032.061.2020256193922.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2006001.061.2020255033743/MOD13C2.A2006001.061.2020255033743.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005335.061.2020252202208/MOD13C2.A2005335.061.2020252202208.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005305.061.2020251065608/MOD13C2.A2005305.061.2020251065608.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005274.061.2020249085414/MOD13C2.A2005274.061.2020249085414.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005244.061.2020247170001/MOD13C2.A2005244.061.2020247170001.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005213.061.2020245191213/MOD13C2.A2005213.061.2020245191213.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005182.061.2020242020631/MOD13C2.A2005182.061.2020242020631.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005152.061.2020237103511/MOD13C2.A2005152.061.2020237103511.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005121.061.2020235093415/MOD13C2.A2005121.061.2020235093415.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005091.061.2020232205205/MOD13C2.A2005091.061.2020232205205.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005060.061.2020230014447/MOD13C2.A2005060.061.2020230014447.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005032.061.2020227203129/MOD13C2.A2005032.061.2020227203129.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2005001.061.2020216163234/MOD13C2.A2005001.061.2020216163234.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004336.061.2020213180132/MOD13C2.A2004336.061.2020213180132.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004306.061.2020211202721/MOD13C2.A2004306.061.2020211202721.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004275.061.2020209161634/MOD13C2.A2004275.061.2020209161634.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004245.061.2020206231440/MOD13C2.A2004245.061.2020206231440.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004214.061.2020205155733/MOD13C2.A2004214.061.2020205155733.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004183.061.2020196090909/MOD13C2.A2004183.061.2020196090909.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004153.061.2020196085605/MOD13C2.A2004153.061.2020196085605.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004122.061.2020125091703/MOD13C2.A2004122.061.2020125091703.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004092.061.2020124085841/MOD13C2.A2004092.061.2020124085841.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004061.061.2020122042419/MOD13C2.A2004061.061.2020122042419.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004032.061.2020120065056/MOD13C2.A2004032.061.2020120065056.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2004001.061.2020119112939/MOD13C2.A2004001.061.2020119112939.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003335.061.2020115161049/MOD13C2.A2003335.061.2020115161049.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003305.061.2020113175902/MOD13C2.A2003305.061.2020113175902.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003274.061.2020111123203/MOD13C2.A2003274.061.2020111123203.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003244.061.2020109234622/MOD13C2.A2003244.061.2020109234622.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003213.061.2020113182836/MOD13C2.A2003213.061.2020113182836.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003182.061.2020106113135/MOD13C2.A2003182.061.2020106113135.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003152.061.2020097023657/MOD13C2.A2003152.061.2020097023657.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003121.061.2020094160551/MOD13C2.A2003121.061.2020094160551.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003091.061.2020092154044/MOD13C2.A2003091.061.2020092154044.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003060.061.2020090142207/MOD13C2.A2003060.061.2020090142207.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003032.061.2020090124748/MOD13C2.A2003032.061.2020090124748.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2003001.061.2020090105033/MOD13C2.A2003001.061.2020090105033.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002335.061.2020084071911/MOD13C2.A2002335.061.2020084071911.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002305.061.2020083111657/MOD13C2.A2002305.061.2020083111657.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002274.061.2020080051447/MOD13C2.A2002274.061.2020080051447.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002244.061.2020078040745/MOD13C2.A2002244.061.2020078040745.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002213.061.2020077165707/MOD13C2.A2002213.061.2020077165707.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002182.061.2020077165858/MOD13C2.A2002182.061.2020077165858.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002152.061.2020072170528/MOD13C2.A2002152.061.2020072170528.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002121.061.2020071093416/MOD13C2.A2002121.061.2020071093416.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002091.061.2020070141838/MOD13C2.A2002091.061.2020070141838.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002060.061.2020069222028/MOD13C2.A2002060.061.2020069222028.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002032.061.2020069053710/MOD13C2.A2002032.061.2020069053710.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2002001.061.2020068122429/MOD13C2.A2002001.061.2020068122429.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001335.061.2020067144210/MOD13C2.A2001335.061.2020067144210.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001305.061.2020066211031/MOD13C2.A2001305.061.2020066211031.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001274.061.2020065235301/MOD13C2.A2001274.061.2020065235301.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001244.061.2020065100646/MOD13C2.A2001244.061.2020065100646.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001213.061.2020064140514/MOD13C2.A2001213.061.2020064140514.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001182.061.2020064131137/MOD13C2.A2001182.061.2020064131137.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001152.061.2020062121306/MOD13C2.A2001152.061.2020062121306.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001121.061.2020062111532/MOD13C2.A2001121.061.2020062111532.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001091.061.2020062091517/MOD13C2.A2001091.061.2020062091517.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001060.061.2020062062854/MOD13C2.A2001060.061.2020062062854.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001032.061.2020064164717/MOD13C2.A2001032.061.2020064164717.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2001001.061.2020061230446/MOD13C2.A2001001.061.2020061230446.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000336.061.2020058173915/MOD13C2.A2000336.061.2020058173915.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000306.061.2020056154958/MOD13C2.A2000306.061.2020056154958.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000275.061.2020056031328/MOD13C2.A2000275.061.2020056031328.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000245.061.2020052141316/MOD13C2.A2000245.061.2020052141316.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000214.061.2020051032221/MOD13C2.A2000214.061.2020051032221.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000183.061.2020051165038/MOD13C2.A2000183.061.2020051165038.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000153.061.2020048051851/MOD13C2.A2000153.061.2020048051851.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000122.061.2020045185153/MOD13C2.A2000122.061.2020045185153.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000092.061.2020042094547/MOD13C2.A2000092.061.2020042094547.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000061.061.2020041172815/MOD13C2.A2000061.061.2020041172815.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD13C2.061/MOD13C2.A2000032.061.2020042083108/MOD13C2.A2000032.061.2020042083108.hdf
EDSCEOF